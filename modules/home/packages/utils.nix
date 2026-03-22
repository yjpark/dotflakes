{pkgs, ...}: {
  home.packages = with pkgs; [
    # Most useful
    ripgrep # rg
    fd
    just
    shadowenv

    # Basic utils
    sd # sed alternative
    gnused # sed
    dust # du alternative
    dysk # df alternative
    procs # ps alternative
    pv # add progress bar for console apps

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
