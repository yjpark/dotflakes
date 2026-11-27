# The public hub for Kudo nodes and shims, with TLS terminated by Caddy.
{ flake, config, ... }:
{
  imports = [
    flake.inputs.hub.nixosModules.hub
    (flake.inputs.self + /mixins/nixos/services/kudo-hub-keys.nix)
  ];

  services.hub = {
    enable = true;
    address = "127.0.0.1:15400";
    websocketAddress = "127.0.0.1:15401";
    environmentFile = config.sops.secrets."hub.env".path;
    privateKeyFile = config.sops.secrets."hub.key".path;
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

  sops.secrets."hub.key" = {
    sopsFile = ./secrets/hub.key;
    format = "binary";
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
