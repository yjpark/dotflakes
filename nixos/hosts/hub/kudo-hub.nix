# The public hub for Kudo nodes and shims, with TLS terminated by Caddy.
{ flake, config, ... }:
{
  imports = [ flake.inputs.hub.nixosModules.hub ];

  services.hub = {
    enable = true;
    address = "127.0.0.1:15400";
    websocketAddress = "127.0.0.1:15401";
    environmentFile = config.sops.secrets."hub.env".path;
    name = "hub";
  };

  # The encrypted dotenv file contains HUB_AUTH_TOKEN=<shared-token>.
  # The VPS decrypts with its SSH host key; no separate age key file is needed.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets."hub.env" = {
    sopsFile = ./secrets/hub.env.txt;
    format = "dotenv";
    key = "";
  };

  services.caddy = {
    enable = true;
    virtualHosts."hub.yjpark.org".extraConfig = ''
      reverse_proxy 127.0.0.1:15401
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
