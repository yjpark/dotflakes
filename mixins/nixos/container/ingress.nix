{ pkgs
, ...
}:
let
  hubDir = "/var/lib/ingress/hub";
  hubHtml = pkgs.writeText "hub-index.html" (builtins.readFile ./ingress-scripts/hub-index.html);

  caddyConfigScript = pkgs.writeShellApplication {
    name = "generate-ingress-config";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname systemd coreutils jq gnugrep ];
    text = builtins.readFile ./ingress-scripts/generate-ingress-config.bash;
  };

  syncApiScript = pkgs.writeScriptBin "ingress-sync-api" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./ingress-scripts/ingress-sync-api.py}
  '';

  ingressScript = pkgs.writeShellApplication {
    name = "ingress";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname gnugrep ];
    text = builtins.readFile ./ingress-scripts/ingress.bash;
  };

  ingressSyncScript = pkgs.writeShellApplication {
    name = "ingress-sync";
    runtimeInputs = with pkgs; [ systemd ];
    text = builtins.readFile ./ingress-scripts/ingress-sync.bash;
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
