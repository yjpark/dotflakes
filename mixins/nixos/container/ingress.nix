{ pkgs
, ...
}:
let
  # Ports <=1000 are filtered by awk; only exclude 2019 (Caddy admin API) above that threshold
  portFilter = "| awk '$1 > 1000' | grep -vE '^(2019|5354|5355|9999)$'";

  # Dynamic config lives here; Caddy imports it at reload time
  dynamicConf = "/var/lib/caddy/ingress.conf";
  hubConf = "/var/lib/caddy/hub.conf";
  hubDir = "/var/lib/ingress/hub";
  hubHtml = pkgs.writeText "hub-index.html" ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ingress Hub</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>&#x1f310;</text></svg>">
    <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { display: flex; height: 100vh; font-family: system-ui, -apple-system, sans-serif; background: #0f0f0f; color: #e0e0e0; }
    #sidebar { width: 260px; min-width: 120px; max-width: 50vw; background: #1a1a1a; flex-shrink: 0; display: flex; flex-direction: column; }
    #resize-handle { width: 4px; cursor: col-resize; background: #333; flex-shrink: 0; transition: background 0.15s; }
    #resize-handle:hover, #resize-handle.dragging { background: #7aa2f7; }
    #sidebar header { padding: 12px 16px; border-bottom: 1px solid #333; display: flex; align-items: center; justify-content: space-between; }
    #sidebar header h1 { font-size: 14px; color: #888; text-transform: uppercase; letter-spacing: 2px; font-weight: 500; }
    #compact-btn { background: none; border: none; color: #555; cursor: pointer; font-size: 18px; padding: 0; line-height: 1; }
    #compact-btn:hover { color: #aaa; }
    #service-list { flex: 1; overflow-y: auto; }
    .service { padding: 10px 16px; cursor: pointer; border-bottom: 1px solid #222; transition: background 0.1s; }
    .service:hover { background: #252525; }
    .service.active { background: #2a2a2a; border-left: 2px solid #7aa2f7; padding-left: 14px; }
    .service .cwd { font-size: 13px; color: #c0c0c0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .service .info { font-size: 11px; color: #666; margin-top: 2px; }
    .service .info .process { color: #bb9af7; }
    .service .info .port { color: #7aa2f7; }
    body.compact #sidebar { width: 64px !important; min-width: 64px; }
    body.compact #sidebar header h1, body.compact #sidebar footer span, body.compact #resize-handle { display: none; }
    body.compact #sidebar header { justify-content: center; padding: 12px 8px; }
    body.compact #sidebar footer { justify-content: center; padding: 8px; }
    body.compact .service { padding: 10px 0; display: flex; flex-direction: column; align-items: center; text-align: center; }
    body.compact .service.active { padding-left: 0; border-left: 2px solid #7aa2f7; }
    body.compact .service .cwd { display: none; }
    body.compact .service .info { margin-top: 0; }
    body.compact .service .info .process { display: none; }
    body.compact .service .info .port { font-size: 13px; font-weight: 500; }
    body.compact .service .svc-icon { display: flex; width: 28px; height: 28px; border-radius: 6px; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #fff; margin-bottom: 2px; overflow: hidden; }
    body.compact .service .svc-icon img { width: 22px; height: 22px; object-fit: contain; }
    .service .svc-icon { display: none; }
    #sidebar footer { padding: 10px 16px; border-top: 1px solid #333; font-size: 12px; color: #888; display: flex; align-items: center; gap: 8px; }
    #main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
    #toolbar { height: 32px; background: #1a1a1a; border-bottom: 1px solid #333; display: flex; align-items: center; padding: 0 12px; gap: 8px; font-size: 12px; }
    #toolbar #current-url { color: #666; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    #toolbar a { color: #7aa2f7; text-decoration: none; font-size: 11px; }
    #toolbar a:hover { text-decoration: underline; }
    #frame-container { flex: 1; position: relative; background: #000; }
    #frame-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
    #empty { display: flex; align-items: center; justify-content: center; height: 100%; color: #333; font-size: 16px; }
    #error { display: none; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: #666; }
    #error a { color: #7aa2f7; }
    .no-services { padding: 24px 16px; text-align: center; color: #444; font-size: 13px; line-height: 1.6; }
    #service-count { flex: 1; }
    #sync-btn { background: #252525; border: 1px solid #444; color: #aaa; padding: 5px 14px; border-radius: 4px; cursor: pointer; font-size: 12px; }
    #sync-btn:hover { background: #333; color: #e0e0e0; }
    #sync-btn.loading { opacity: 0.5; pointer-events: none; }
    #modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.7); z-index: 100; align-items: center; justify-content: center; }
    #modal-overlay.visible { display: flex; }
    #modal { background: #1a1a1a; border: 1px solid #333; border-radius: 8px; padding: 20px; max-width: 600px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
    #modal header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    #modal header h2 { font-size: 14px; color: #888; font-weight: 500; }
    #modal-close { background: none; border: none; color: #666; cursor: pointer; font-size: 18px; padding: 0 4px; }
    #modal-close:hover { color: #c0c0c0; }
    #modal pre { flex: 1; overflow: auto; font-size: 12px; color: #c0c0c0; background: #0f0f0f; padding: 12px; border-radius: 4px; white-space: pre-wrap; word-break: break-all; }
    </style>
    </head>
    <body>
    <div id="sidebar">
      <header><h1>Ingress Hub</h1><button id="compact-btn" onclick="toggleCompact()" title="Toggle compact mode">&#x2630;</button></header>
      <div id="service-list"></div>
      <footer><span id="service-count"></span><button id="sync-btn" onclick="doSync()">sync</button></footer>
    </div>
    <div id="resize-handle"></div>
    <div id="main">
      <div id="toolbar">
        <span id="current-url"></span>
        <a id="reload-frame" href="#" style="display:none" onclick="reloadFrame(); return false;">reload</a>
        <a id="open-new-tab" href="#" target="_blank" style="display:none">new tab</a>
      </div>
      <div id="frame-container">
        <div id="empty">Select a service</div>
      </div>
    </div>
    <script>
    var services = [];

    function loadServices() {
      fetch("/services.json?" + Date.now())
        .then(function(res) { return res.json(); })
        .then(function(data) {
          services = data.sort(function(a, b) { return a.port - b.port; });
          renderList();
        })
        .catch(function() {
          document.getElementById("service-list").innerHTML =
            '<div class="no-services">Failed to load services.<br>Run <code>ingress-sync</code> to generate.</div>';
        });
    }

    function iconFallback(img) {
      var parent = img.parentNode;
      parent.removeChild(img);
      parent.textContent = parent.getAttribute("data-label");
    }

    function esc(s) {
      var d = document.createElement("div");
      d.textContent = s;
      return d.innerHTML;
    }

    function renderList() {
      var list = document.getElementById("service-list");
      var count = document.getElementById("service-count");
      if (services.length === 0) {
        list.innerHTML = '<div class="no-services">No services detected.<br>Run <code>ingress-sync</code> to refresh.</div>';
        count.textContent = "";
        return;
      }
      count.textContent = services.length + " service" + (services.length !== 1 ? "s" : "");
      var html = "";
      for (var i = 0; i < services.length; i++) {
        var s = services[i];
        var label = esc((s.process || "?")[0].toUpperCase());
        var hue = (s.port * 137) % 360;
        var bg = "hsl(" + hue + ",40%,30%)";
        html += '<div class="service" data-idx="' + i + '" onclick="selectService(' + i + ')">' +
          '<div class="svc-icon" data-label="' + label + '" style="background:' + bg + '">' +
          '<img src="/api/icon/' + s.port + '?v=' + Date.now() + '" onerror="iconFallback(this)">' +
          '</div>' +
          '<div class="cwd">' + esc(s.cwd || "?") + '</div>' +
          '<div class="info"><span class="process">' + esc(s.process || "?") + '</span> ' +
          '<span class="port">:' + s.port + '</span></div>' +
          '</div>';
      }
      list.innerHTML = html;
    }

    function getServiceUrl(port) {
      var host = window.location.hostname;
      // External: yolo-hub.edger.yjpark.org → https://yolo-<port>.edger.yjpark.org
      var m = host.match(/^(\w+)-hub\.(.+)$/);
      if (m) return "https://" + m[1] + "-" + port + "." + m[2];
      // Internal: hub.yolo.incus → http://<port>.yolo.incus
      m = host.match(/^hub\.(.+)$/);
      if (m) return "http://" + port + "." + m[1];
      return "http://" + port + "." + host;
    }

    var activePort = null;

    function proxyPath(port) {
      return "/s/" + port + "/";
    }

    function proxyToRealUrl(proxyHref) {
      // Convert /s/<port>/path → real service URL
      var m = proxyHref.match(/\/s\/(\d+)(\/.*)?$/);
      if (!m) return proxyHref;
      return getServiceUrl(parseInt(m[1])) + (m[2] || "/").substring(1);
    }

    function updateToolbarUrl(url) {
      document.getElementById("current-url").textContent = url;
      var openBtn = document.getElementById("open-new-tab");
      openBtn.href = url;
    }

    function onFrameLoad() {
      var frame = activePort ? document.getElementById("frame-" + activePort) : null;
      if (!frame) return;
      try {
        var loc = frame.contentWindow.location.pathname + frame.contentWindow.location.search + frame.contentWindow.location.hash;
        updateToolbarUrl(proxyToRealUrl(loc));
      } catch(e) { /* fallback: keep current URL */ }
    }

    function selectService(idx) {
      var s = services[idx];
      var els = document.querySelectorAll(".service");
      for (var i = 0; i < els.length; i++) els[i].classList.remove("active");
      els[idx].classList.add("active");

      updateToolbarUrl(getServiceUrl(s.port));
      document.getElementById("open-new-tab").style.display = "inline";
      document.getElementById("reload-frame").style.display = "inline";

      var container = document.getElementById("frame-container");
      var empty = document.getElementById("empty");
      if (empty) empty.style.display = "none";

      // Hide all iframes
      var frames = container.querySelectorAll("iframe");
      for (var i = 0; i < frames.length; i++) frames[i].style.display = "none";

      // Find or create iframe for this port
      var frameId = "frame-" + s.port;
      var frame = document.getElementById(frameId);
      if (!frame) {
        frame = document.createElement("iframe");
        frame.id = frameId;
        frame.src = proxyPath(s.port);
        frame.addEventListener("load", onFrameLoad);
        container.appendChild(frame);
      }
      frame.style.display = "block";
      activePort = s.port;

      onFrameLoad();
    }

    function reloadFrame() {
      if (activePort) {
        var f = document.getElementById("frame-" + activePort);
        if (f) f.src = f.src;
      }
    }

    function doSync() {
      var btn = document.getElementById("sync-btn");
      btn.classList.add("loading");
      btn.textContent = "syncing...";
      fetch("/api/sync", { method: "POST" })
        .then(function(res) { return res.json(); })
        .then(function(data) {
          showModal(data.ok ? "Sync complete" : "Sync failed", data.output);
        })
        .catch(function(e) {
          showModal("Sync error", e.message);
        })
        .finally(function() {
          btn.classList.remove("loading");
          btn.textContent = "sync";
        });
    }

    function showModal(title, text) {
      var overlay = document.getElementById("modal-overlay");
      overlay.querySelector("h2").textContent = title;
      overlay.querySelector("pre").textContent = text;
      overlay.classList.add("visible");
    }

    function closeModal() {
      document.getElementById("modal-overlay").classList.remove("visible");
      loadServices();
    }

    // Compact mode (default: on)
    function toggleCompact() {
      document.body.classList.toggle("compact");
      var isCompact = document.body.classList.contains("compact");
      document.getElementById("compact-btn").innerHTML = isCompact ? "&#x2630;" : "&#xab;";
      document.getElementById("compact-btn").title = isCompact ? "Expand sidebar" : "Collapse sidebar";
      localStorage.setItem("hub-compact", isCompact ? "1" : "0");
    }
    if (localStorage.getItem("hub-compact") !== "0") {
      document.body.classList.add("compact");
    } else {
      document.getElementById("compact-btn").innerHTML = "&#xab;";
      document.getElementById("compact-btn").title = "Collapse sidebar";
    }

    // Resizable sidebar
    (function() {
      var handle = document.getElementById("resize-handle");
      var sidebar = document.getElementById("sidebar");
      var dragging = false;
      handle.addEventListener("mousedown", function(e) {
        e.preventDefault();
        dragging = true;
        handle.classList.add("dragging");
        document.body.style.cursor = "col-resize";
        document.body.style.userSelect = "none";
      });
      document.addEventListener("mousemove", function(e) {
        if (!dragging) return;
        var w = Math.min(Math.max(e.clientX, 120), window.innerWidth * 0.5);
        sidebar.style.width = w + "px";
      });
      document.addEventListener("mouseup", function() {
        if (!dragging) return;
        dragging = false;
        handle.classList.remove("dragging");
        document.body.style.cursor = "";
        document.body.style.userSelect = "";
        localStorage.setItem("hub-sidebar-width", sidebar.style.width);
      });
      var saved = localStorage.getItem("hub-sidebar-width");
      if (saved) sidebar.style.width = saved;
    })();

    loadServices();
    </script>
    <div id="modal-overlay" onclick="if(event.target===this)closeModal()">
      <div id="modal">
        <header><h2></h2><button id="modal-close" onclick="closeModal()">&times;</button></header>
        <pre></pre>
      </div>
    </div>
    </body>
    </html>
  '';

  caddyConfigScript = pkgs.writeShellApplication {
    name = "generate-ingress-config";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname systemd coreutils jq gnugrep ];
    text = ''
      DOMAIN="$(hostname).incus"
      mkdir -p "${hubDir}"

      CONFIG=""
      HUB_ROUTES=""
      SERVICES="[]"

      while IFS=$'\t' read -r PORT PID PNAME; do
        [[ -z "$PORT" ]] && continue

        # Get working directory from /proc
        CWD=""
        if [[ -n "$PID" && -d "/proc/$PID" ]]; then
          CWD=$(readlink -f "/proc/$PID/cwd" 2>/dev/null || true)
          # Shorten: strip /home/<user>/ prefix
          CWD=''${CWD#/home/*/}
        fi

        URL="http://''${PORT}.''${DOMAIN}"

        # Same-origin proxy route for hub iframe
        HUB_ROUTES+="
        handle_path /s/''${PORT}/* {
          reverse_proxy localhost:''${PORT} {
            header_down -X-Frame-Options
            header_down -Content-Security-Policy
            header_down -Content-Security-Policy-Report-Only
          }
        }
      "

        CONFIG+="
      ''${PORT}.''${DOMAIN} {
        tls internal
        reverse_proxy localhost:''${PORT} {
          header_down -X-Frame-Options
          header_down -Content-Security-Policy
          header_down -Content-Security-Policy-Report-Only
        }
      }
      http://''${PORT}.''${DOMAIN} {
        reverse_proxy localhost:''${PORT} {
          header_down -X-Frame-Options
          header_down -Content-Security-Policy
          header_down -Content-Security-Policy-Report-Only
        }
      }
      "

        SERVICES=$(echo "$SERVICES" | jq \
          --argjson port "$PORT" \
          --arg process "$PNAME" \
          --arg cwd "$CWD" \
          --arg url "$URL" \
          '. + [{port: $port, process: $process, cwd: $cwd, url: $url}]')
      done < <(ss -tlnp | awk 'NR>1 {
        n = split($4, a, ":");
        port = a[n];
        if (port+0 <= 1000 || port+0 == 2019 || port+0 == 5354 || port+0 == 5355 || port+0 == 9999) next;
        pid = ""; pname = "";
        if (match($0, /pid=([0-9]+)/, m)) pid = m[1];
        if (match($0, /"([^"]+)"/, m)) pname = m[1];
        print port "\t" pid "\t" pname;
      }' | sort -t$'\t' -k1,1 -un)

      echo "$CONFIG" > "${dynamicConf}"

      # Write services.json for hub page
      echo "$SERVICES" > "${hubDir}/services.json"

      # Generate hub Caddy config
      cat > "${hubConf}" <<HUBEOF
      hub.$DOMAIN {
        tls internal
      $HUB_ROUTES
        handle /api/* {
          reverse_proxy localhost:9999
        }
        handle {
          root * ${hubDir}
          file_server
        }
      }
      http://hub.$DOMAIN {
      $HUB_ROUTES
        handle /api/* {
          reverse_proxy localhost:9999
        }
        handle {
          root * ${hubDir}
          file_server
        }
      }
      HUBEOF

      systemctl reload caddy.service 2>/dev/null || systemctl restart caddy.service

      # Update combined CA bundle so wget/curl trust Caddy's internal CA
      CADDY_CA="/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
      SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
      COMBINED="/var/lib/ingress/ca-bundle.crt"
      if [ -f "$CADDY_CA" ]; then
        cat "$SYSTEM_CA" "$CADDY_CA" > "$COMBINED"
      fi
    '';
  };

  syncApiScript = pkgs.writeScriptBin "ingress-sync-api" ''
    #!${pkgs.python3}/bin/python3
    from http.server import HTTPServer, BaseHTTPRequestHandler
    import subprocess, json, http.client, re

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
                r = subprocess.run(
                    ["${caddyConfigScript}/bin/generate-ingress-config"],
                    capture_output=True, text=True, timeout=30
                )
                r2 = subprocess.run(
                    ["${ingressScript}/bin/ingress"],
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
  '';

  ingressSyncScript = pkgs.writeShellApplication {
    name = "ingress-sync";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      /run/wrappers/bin/sudo systemctl restart ingress-sync.service
      ${ingressScript}/bin/ingress
    '';
  };

  ingressScript = pkgs.writeShellApplication {
    name = "ingress";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname gnugrep ];
    text = ''
      DOMAIN="$(hostname).incus"

      # Collect listening ports (excluding system/caddy ports)
      LISTENING=$(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un ${portFilter} || true)

      # Collect ports from dynamic config
      CADDY_PORTS=""
      if [ -f "${dynamicConf}" ]; then
        CADDY_PORTS=$(grep -oP '^\d+(?=\.)' "${dynamicConf}" | sort -un || true)
      fi

      echo "Local listening ports:"
      if [ -z "$LISTENING" ]; then
        echo "  (none)"
      else
        while IFS= read -r PORT; do
          echo "  127.0.0.1:$PORT"
        done <<< "$LISTENING"
      fi

      echo ""
      echo "Active ingress routes (from Caddy config):"
      if [ -z "$CADDY_PORTS" ]; then
        echo "  (none)"
      else
        while IFS= read -r PORT; do
          echo "  https://$PORT.$DOMAIN  →  127.0.0.1:$PORT"
        done <<< "$CADDY_PORTS"
      fi

      echo ""
      echo "Hub: http://hub.$DOMAIN"

      # Warn on divergences
      WARNINGS=""
      while IFS= read -r PORT; do
        [ -z "$PORT" ] && continue
        if ! grep -qx "$PORT" <<< "$CADDY_PORTS" 2>/dev/null; then
          WARNINGS+="  WARNING: port $PORT is listening but not in Caddy config (run ingress-sync?)\n"
        fi
      done <<< "$LISTENING"
      while IFS= read -r PORT; do
        [ -z "$PORT" ] && continue
        if ! grep -qx "$PORT" <<< "$LISTENING" 2>/dev/null; then
          WARNINGS+="  WARNING: port $PORT is in Caddy config but not currently listening\n"
        fi
      done <<< "$CADDY_PORTS"

      if [ -n "$WARNINGS" ]; then
        echo ""
        echo "Divergences:"
        echo -e "$WARNINGS"
      fi
    '';
  };
in
{
  # Static Caddyfile that imports our dynamically-generated config
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      {
        log {
          level ERROR
        }
        auto_https disable_redirects
      }
      import /var/lib/caddy/*.conf
    '';
  };

  # Wildcard DNS for *.$(hostname).incus → 127.0.0.1 so wget/curl work inside the container.
  # Run dnsmasq on port 5354 to avoid conflicting with systemd-resolved on port 53,
  # and tell resolved to forward .incus queries to dnsmasq.
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [ "/.incus/127.0.0.1" ];
      local = [ "/.incus/" ];
      port = 5354;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-resolv = true;
    };
  };

  services.resolved.settings = {
    Resolve = {
      DNS = "127.0.0.1:5354";
      Domains = "~incus";
    };
  };

  systemd.services.ingress-sync-api = {
    description = "HTTP API for triggering ingress sync";
    wantedBy = [ "multi-user.target" ];
    after = [ "caddy.service" ];
    serviceConfig = {
      ExecStart = "${syncApiScript}/bin/ingress-sync-api";
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.services.ingress-sync = {
    description = "Regenerate Caddy ingress config from listening ports";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${caddyConfigScript}/bin/generate-ingress-config";
    };
    after = [ "caddy.service" ];
    requires = [ "caddy.service" ];
  };

  # Allow wheel group to restart ingress-sync without a password
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl restart ingress-sync.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Create ingress state dir, hub dir, and symlink hub HTML from Nix store
  systemd.tmpfiles.rules = [
    "d /var/lib/ingress 0755 root root -"
    "d ${hubDir} 0755 root root -"
    "L+ ${hubDir}/index.html - - - - ${hubHtml}"
  ];

  systemd.services.init-ingress-ca = {
    description = "Initialize ingress CA bundle";
    wantedBy = [ "sysinit.target" ];
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt /var/lib/ingress/ca-bundle.crt";
    };
  };

  # Point SSL tools at combined bundle (system CAs + Caddy internal CA)
  environment.variables = {
    SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
  };

  environment.systemPackages = [
    ingressScript
    ingressSyncScript
  ];
}
