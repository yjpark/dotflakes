{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    (self + /mixins/home/host)
    (self + /mixins/home/gui)
  ];

  home.stateVersion = "25.05";

  # Defined by /modules/home/options.nix
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
