{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    (self + /mixins/home/versions/26.05.nix)
    (self + /mixins/home/container)
  ];

  # Defined by /modules/home/options.nix
  me = {
    username = "yj";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
