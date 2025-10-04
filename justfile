activate-home *ARGS:
    nix run

show:
    om show .

run *ARGS:
    nix run {{ARGS}}

install-om:
    nix profile install nixpkgs#omnix

install-om_latest:
    # Install omnix (using om.cachix.org Nix cache)
    nix --accept-flake-config profile install github:juspay/omnix
