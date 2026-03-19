{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    (self + /mixins/home/container)
  ];

  home.stateVersion = "26.05";

  # Defined by /modules/home/options.nix
  me = {
    username = "yj";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
