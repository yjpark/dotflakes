{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    (self + /mixins/home/versions/25.05.nix)
    (self + /mixins/home/linux)
  ];

  # Defined by /modules/home/options.nix
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
