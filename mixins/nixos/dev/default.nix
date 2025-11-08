{ config, pkgs, ... }: {
  imports = [
    ./ports.nix
    #./k3s.nix
    ./postgresql.nix
    ./nix-ld.nix
  ];
}
