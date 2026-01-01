{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    rustup
    clang
    #dprint
  ];
}


