{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    ../../options/home/versions/25.05.nix
  ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "yjpark";
    fullname = "YJ Park";
    email = "yjpark@gmail.com";
  };
}
