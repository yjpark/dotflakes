{flake, pkgs, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.spacebot.nixosModules.default
  ];

  environment.systemPackages = [
    inputs.spacebot.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.spacebot = {
    enable = true;
    # Data dir is mounted from host via incus disk device (see incus-launch-spacebot.bash).
    # Host dir is owned by yjpark (UID 1000), shift=true maps to yj (UID 1000) inside container.
    dataDir = "/var/lib/spacebot";
    user = "yj";
    group = "users";
    # Use yj's Nix profile so spacebot workers can find tools installed via Home Manager
    pathUser = "yj";
    # OneCLI proxy injects API credentials
    environmentFile = "/etc/onecli-proxy-auth";
    # Bind to all interfaces so the host can reach the web UI
    bind = "0.0.0.0";
  };
}
