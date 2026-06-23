{flake, pkgs, ...}: {
  home.packages = with pkgs; [
    # Most useful
    ripgrep # rg
    fd
    just
    shadowenv
    omnix
    mdbook
    flake.inputs.mdbook-beans.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Basic utils
    sd # sed alternative
    gnused # sed
    dust # du alternative
    dysk # df alternative
    procs # ps alternative
    pv # add progress bar for console apps
    witr # ps and port utils

    # Network utils
    axel
    curl
    wget
    inetutils
    dig
    doggo     # dig alternative

    # Secret
    age

    # Git tools
    tig
    tokei # source line calculater

    mmv
  ];
}
