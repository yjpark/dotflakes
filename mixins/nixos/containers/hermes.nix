{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    settings.model.default = "anthropic/claude-sonnet-4";
    # Data dir is mounted from host via incus disk device (see incus-launch-hermes.bash).
    # Host dir is owned by yjpark (UID 1000), shift=true maps to yj (UID 1000) inside container.
    user = "yj";
    group = "users";
    # OneCLI proxy injects API credentials
    environmentFiles = [ "/etc/onecli-proxy-auth" ];
  };
}
