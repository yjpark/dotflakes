{ config, pkgs, ... }: {
  sops.secrets."cloudflared.cred.json" = {
    sopsFile = ./cloudflared.cred.json;
    format = "json";
    key = "";
    #owner = "cloudflared";
    #group = "cloudflared";
    #mode = "0444";
  };
}

