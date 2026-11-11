{ config, ... }: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "829deb72-9870-4b61-9120-bf748d85fbd2" = {
        credentialsFile = "${config.sops.secrets."cloudflared.cred.json".path}";
        ingress = {
          "kudo_pc.yjpark.org" = {
            service = "http://10.100.0.100:80";
            originRequest.httpHostHeader = "8080.yolo.incus";
          };
          "yolo-8080.pc.yjpark.org" = {
            service = "http://10.100.0.100:80";
            originRequest.httpHostHeader = "8080.yolo.incus";
          };
        };
        default = "http_status:404";
      };
    };
  };
  # https://wiki.nixos.org/wiki/Cloudflared
  services.openssh.settings.Macs = [
    "hmac-sha2-256"
  ];
}
