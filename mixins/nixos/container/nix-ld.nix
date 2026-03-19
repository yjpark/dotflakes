{pkgs, ...}: {
  # Enable nix-ld to allow running dynamically linked binaries (e.g. npm-installed CLIs)
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];
}
