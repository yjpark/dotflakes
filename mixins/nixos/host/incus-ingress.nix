{pkgs, lib, ...}: let
  # Fixed Incus bridge IP (set in incus.nix preseed)
  bridgeIp = "10.100.0.1";

  # Containers that have ingress enabled — add names here to support more
  ingressContainers = ["yolo"];

  pullCaCertScript = pkgs.writeShellApplication {
    name = "incus-pull-ca";
    runtimeInputs = with pkgs; [incus coreutils];
    text = ''
      CADDY_CA_PATH=".local/share/caddy/pki/authorities/local/root.crt"
      SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
      COMBINED="/var/lib/ingress/ca-bundle.crt"

      mkdir -p "$(dirname "$COMBINED")"
      cp "$SYSTEM_CA" "$COMBINED"

      CONTAINERS=(${lib.concatStringsSep " " ingressContainers})
      for CONTAINER in "''${CONTAINERS[@]}"; do
        if ! incus info "$CONTAINER" 2>/dev/null | grep -q "Status: RUNNING"; then
          echo "SKIP: $CONTAINER is not running"
          continue
        fi
        TMPFILE=$(mktemp)
        if incus file pull "$CONTAINER/var/lib/caddy/$CADDY_CA_PATH" "$TMPFILE" 2>/dev/null; then
          cat "$TMPFILE" >> "$COMBINED"
          echo "OK: Added CA from $CONTAINER"
        else
          echo "SKIP: $CONTAINER has no Caddy CA yet (run ingress-sync inside it first)"
        fi
        rm -f "$TMPFILE"
      done

      echo "CA bundle updated at $COMBINED. Restart your browser to pick up changes."
    '';
  };
in {
  # dnsmasq on port 5354 for *.incus wildcard DNS resolution.
  # Forwards .incus queries to the Incus bridge DNS, with wildcard CNAMEs
  # so 3000.yolo.incus → yolo.incus → container's bridge IP.
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5354;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-resolv = true;
      server = ["/.incus/${bridgeIp}"];
      cname = map (c: "*.${c}.incus,${c}.incus") ingressContainers;
    };
  };

  # systemd-resolved as primary resolver, forwarding .incus to dnsmasq
  services.resolved = {
    enable = true;
  };

  services.resolved.settings.Resolve = {
    DNS = "127.0.0.1:5354";
    Domains = "~incus";
    DNSOverTLS = "opportunistic";
    FallbackDNS = "1.1.1.1 8.8.8.8";
  };

  # Create ingress state dir and copy system CAs to bundle on every boot
  systemd.tmpfiles.rules = ["d /var/lib/ingress 0755 root root -"];

  systemd.services.init-ingress-ca = {
    description = "Initialize ingress CA bundle";
    wantedBy = ["sysinit.target"];
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt /var/lib/ingress/ca-bundle.crt";
    };
  };

  # Point SSL tools at combined bundle; run incus-pull-ca to add Caddy's CA
  environment.variables = {
    SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
  };

  environment.systemPackages = [pullCaCertScript];
}
