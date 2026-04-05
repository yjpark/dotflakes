{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/home/host)
    (self + /packs/home/gui)
  ];

  home.stateVersion = "25.05";

  # Defined by /packs/home/common/options.nix
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
