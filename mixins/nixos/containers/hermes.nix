{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;

    settings = {
      model = {
        default = "gemini-2.5-flash";
        provider = "gemini";
        base_url = "https://generativelanguage.googleapis.com/v1beta";
      };
      # Discord platform settings
      discord = {
        require_mention = true;
      };
    };

    # GEMINI_API_KEY and DISCORD_BOT_TOKEN etc. pushed from host
    environmentFiles = [
      "/etc/onecli-proxy-auth"
      "/etc/hermes-env"          # pushed from host by onecli-init-ca-and-secrets
    ];
  };
}
