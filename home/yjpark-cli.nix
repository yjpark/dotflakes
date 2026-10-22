{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  # Headless yjpark: everything but the GUI pack. Used as-is on WSL
  # (`yjpark@wsl`), where the GUI pack would only build niri, VSCode, etc.
  imports = [
    (self + /packs/home/host)
  ];

  home.stateVersion = "25.05";

  # Defined by /packs/home/common/options.nix
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
