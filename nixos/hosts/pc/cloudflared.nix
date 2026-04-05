{config, ...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "829deb72-9870-4b61-9120-bf748d85fbd2" = {
        credentialsFile = "${config.sops.secrets."cloudflared.cred.json".path}";
        default = "http_status:404";
      };
    };
  };
  # https://wiki.nixos.org/wiki/Cloudflared
  services.openssh.settings.Macs = [
    "hmac-sha2-256"
  ];
}
