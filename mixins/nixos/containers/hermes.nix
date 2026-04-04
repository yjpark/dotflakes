{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    settings.model.default = "anthropic/claude-sonnet-4";
    # OneCLI proxy injects API credentials
    environmentFiles = [ "/etc/onecli-proxy-auth" ];
  };
}
