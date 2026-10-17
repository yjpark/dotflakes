from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from concurrent.futures import ThreadPoolExecutor
import http.client, json, os, re, subprocess

CONFIG = json.load(open(os.environ["HUB_CONFIG"]))
CONTAINERS = {c["name"]: c for c in CONFIG["containers"]}
HIDDEN = set(CONFIG["hiddenPorts"])

# Run inside the container: its listening sockets, then each owning pid's cwd.
# NixOS containers keep their tools under /run/current-system/sw/bin, which
# incus exec does not put on PATH by itself.
PROBE = r"""
export PATH=/run/current-system/sw/bin:$PATH
ss -tlnpH
echo ---
for p in $(ss -tlnpH | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
  echo "$p $(readlink /proc/$p/cwd)"
done
"""


def running():
    r = subprocess.run(
        ["incus", "list", "--format", "json"],
        capture_output=True, text=True, timeout=10,
    )
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip() or f"exit {r.returncode}")
    return {c["name"] for c in json.loads(r.stdout) if c.get("status") == "Running"}


def shorten(cwd):
    # /home/<user>/agents/edger/hub -> agents/edger/hub
    return re.sub(r"^/home/[^/]+/?", "", cwd) or cwd


def ports(name):
    r = subprocess.run(
        ["incus", "exec", "-T", name, "--", "/bin/sh", "-c", PROBE],
        capture_output=True, text=True, timeout=10,
    )
    if r.returncode != 0:
        raise RuntimeError((r.stderr or r.stdout).strip() or f"exit {r.returncode}")
    sockets, _, cwds = r.stdout.partition("---\n")
    cwd = {}
    for line in cwds.splitlines():
        pid, _, path = line.partition(" ")
        cwd[pid] = shorten(path)
    found = {}
    for line in sockets.splitlines():
        cols = line.split()
        if len(cols) < 4:
            continue
        port = int(cols[3].rsplit(":", 1)[-1])
        if port <= 1000 or port in HIDDEN or port in found:
            continue
        pid = re.search(r"pid=(\d+)", line)
        proc = re.search(r'"([^"]+)"', line)
        found[port] = {
            "port": port,
            "process": proc.group(1) if proc else "",
            "cwd": cwd.get(pid.group(1), "") if pid else "",
        }
    return sorted(found.values(), key=lambda p: p["port"])


def containers():
    try:
        up = running()
    except Exception as e:
        return [{"name": n, "error": f"incus: {e}"} for n in CONTAINERS]

    def one(name):
        if name not in up:
            return {"name": name, "error": "not running"}
        try:
            return {"name": name, "ports": ports(name)}
        except Exception as e:
            return {"name": name, "error": str(e)}

    with ThreadPoolExecutor(max_workers=8) as pool:
        return list(pool.map(one, CONTAINERS))


def _get(container, port, path, timeout=2):
    # Same route the host Caddy uses, so services bound to the container's
    # localhost are reachable too.
    if container.get("viaCaddy", True):
        conn = http.client.HTTPConnection(container["ip"], 80, timeout=timeout)
        host = f"{port}.{container['name']}.incus"
    else:
        conn = http.client.HTTPConnection(container["ip"], port, timeout=timeout)
        host = f"{container['ip']}:{port}"
    conn.request("GET", path, headers={"Host": host, "User-Agent": "Mozilla/5.0"})
    r = conn.getresponse()
    data = r.read()
    ct = r.getheader("Content-Type", "")
    conn.close()
    return r.status, ct, data


def _is_html(ct, data):
    return ct.startswith("text/html") or data[:5] in (b"<!DOC", b"<html")


def favicon(container, port):
    # Try /favicon.ico first
    try:
        status, ct, data = _get(container, port, "/favicon.ico")
        if status == 200 and not _is_html(ct, data):
            return data, ct or "image/x-icon"
    except Exception:
        pass
    # Parse HTML for <link rel="icon" href="...">
    try:
        status, ct, data = _get(container, port, "/", timeout=3)
        if status != 200:
            return None, None
        html = data.decode("utf-8", errors="ignore")
        m = re.search(r'<link[^>]*rel=["\x27]?[^"\']*icon[^>]*href=["\x27]([^"\']+)', html, re.I)
        if not m:
            m = re.search(r'<link[^>]*href=["\x27]([^"\']+)[^>]*rel=["\x27]?[^"\']*icon', html, re.I)
        if m:
            href = m.group(1)
            if href.startswith("http"):
                return None, None  # skip external URLs for simplicity
            status2, ct2, data2 = _get(container, port, "/" + href.lstrip("/"))
            if status2 == 200 and not _is_html(ct2, data2):
                return data2, ct2 or "image/x-icon"
    except Exception:
        pass
    return None, None


class Handler(BaseHTTPRequestHandler):
    def send(self, status, body=b"", ct=None, cache=None):
        self.send_response(status)
        if ct:
            self.send_header("Content-Type", ct)
        if cache:
            self.send_header("Cache-Control", cache)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/api/containers":
            body = json.dumps(containers()).encode()
            return self.send(200, body, "application/json", "no-store")
        m = re.fullmatch(r"/api/icon/([\w-]+)/(\d+)", path)
        if m and m.group(1) in CONTAINERS:
            data, ct = favicon(CONTAINERS[m.group(1)], int(m.group(2)))
            if data:
                return self.send(200, data, ct, "public, max-age=3600")
        self.send(404)

    def log_message(self, format, *args):
        pass


ThreadingHTTPServer(("127.0.0.1", CONFIG["port"]), Handler).serve_forever()
