{config, ...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "3a3e8b82-37a0-41e3-8e4c-3c2de9bc0469" = {
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
