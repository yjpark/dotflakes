{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    ../../mixins/home/versions/25.05.nix
  ];

  # Defined by /modules/home/options.nix
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
