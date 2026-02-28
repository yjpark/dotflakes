activate-home *ARGS:
    jj status
    nix run {{ARGS}}

show:
    om show .

update *ARGS:
    nix flake update {{ARGS}}

build-host command="build" *ARGS:
    nixos-rebuild {{command}} --flake .#`hostname` {{ARGS}}

switch-host *ARGS:
    sudo nixos-rebuild switch --flake .#`hostname` {{ARGS}}
