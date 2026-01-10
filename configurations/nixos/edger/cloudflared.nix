{config, ...}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "f62c3a91-d7b5-48c3-921d-f22e0f0cd0e9" = {
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
