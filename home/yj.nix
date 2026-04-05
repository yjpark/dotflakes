{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/home/container)
  ];

  home.stateVersion = "26.05";

  # Defined by /packs/home/common/options.nix
  me = {
    username = "yj";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
