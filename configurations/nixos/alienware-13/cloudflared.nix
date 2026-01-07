{config, ...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "6aa685b7-9d42-4ad3-9aa6-8c6bf32acd94" = {
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
