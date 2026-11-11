{ config, ... }: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "829deb72-9870-4b61-9120-bf748d85fbd2" = {
        credentialsFile = "${config.sops.secrets."cloudflared.cred.json".path}";
        # This tunnel is remotely managed. Add kudo_pc.yjpark.org as a public
        # hostname in Cloudflare Zero Trust with service http://10.100.0.100:80
        # and HTTP Host header 8080.yolo.incus; local ingress is ignored.
        default = "http_status:404";
      };
    };
  };
  # https://wiki.nixos.org/wiki/Cloudflared
  services.openssh.settings.Macs = [
    "hmac-sha2-256"
  ];
}
