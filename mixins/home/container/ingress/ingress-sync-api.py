from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess, json, http.client, re, shutil

def _get(port, path, timeout=2):
    conn = http.client.HTTPConnection("localhost", int(port), timeout=timeout)
    conn.request("GET", path, headers={"Host": f"localhost:{port}", "User-Agent": "Mozilla/5.0"})
    r = conn.getresponse()
    data = r.read()
    ct = r.getheader("Content-Type", "")
    conn.close()
    return r.status, ct, data

def _is_html(ct, data):
    return ct.startswith("text/html") or data[:5] in (b"<!DOC", b"<html")

def fetch_favicon(port):
    # Try /favicon.ico first
    try:
        status, ct, data = _get(port, "/favicon.ico")
        if status == 200 and not _is_html(ct, data):
            return data, ct or "image/x-icon"
    except Exception:
        pass
    # Parse HTML for <link rel="icon" href="...">
    try:
        status, ct, data = _get(port, "/", timeout=3)
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
            status2, ct2, data2 = _get(port, "/" + href.lstrip("/"))
            if status2 == 200 and not _is_html(ct2, data2):
                return data2, ct2 or "image/x-icon"
    except Exception:
        pass
    return None, None

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/api/icon/"):
            port = self.path.split("/")[-1].split("?")[0]
            if not port.isdigit():
                self.send_response(400)
                self.end_headers()
                return
            data, ct = fetch_favicon(port)
            if data:
                self.send_response(200)
                self.send_header("Content-Type", ct)
                self.send_header("Cache-Control", "public, max-age=3600")
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        try:
            gen_cmd = shutil.which("generate-ingress-config") or "generate-ingress-config"
            ingress_cmd = shutil.which("ingress") or "ingress"
            r = subprocess.run(
                [gen_cmd],
                capture_output=True, text=True, timeout=30
            )
            r2 = subprocess.run(
                [ingress_cmd],
                capture_output=True, text=True, timeout=10
            )
            output = r2.stdout
            if r.returncode != 0:
                output = "ERRORS:\n" + r.stdout + r.stderr + "\n\n" + output
            body = json.dumps({"ok": r.returncode == 0, "output": output.strip()})
        except Exception as e:
            body = json.dumps({"ok": False, "output": str(e)})
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body.encode())
        self.wfile.flush()

    def log_message(self, format, *args):
        pass

HTTPServer(("127.0.0.1", 9999), Handler).serve_forever()
