activate-home *ARGS:
    nix run {{ARGS}}

show:
    om show .

run *ARGS:
    nix run {{ARGS}}

update *ARGS:
    nix flake update {{ARGS}}
