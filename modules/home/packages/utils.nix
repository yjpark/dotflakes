{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Most useful
    ripgrep                 # rg
    fd
    just
    shadowenv

    # Legacy, might remove later
    devenv

    # Basic utils
    sd                      # sed alternative
    gnused                  # sed
    dust                    # du alternative
    dysk                    # df alternative
    procs                   # ps alternative
    pv                      # add progress bar for console apps

    # Network utils
    mosh
    axel
    curl
    inetutils
    dogdns                  # dig alternative
    bandwhich               # show network usage by process

    # Secret
    age
    sops
    ssh-to-age

    # For nix and flakes
    omnix

    # Git tools
    tig
    git-extras
    tokei                   # source line calculater

    # Wayland tools
    wl-clipboard
  ];
}
