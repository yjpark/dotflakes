activate-home *ARGS:
    jj status
    nix run {{ARGS}}

show:
    jj status
    om show .

update *ARGS:
    nix flake update {{ARGS}}
    jj status

build-host command="build" *ARGS:
    jj status
    nixos-rebuild {{command}} --flake .#`hostname` {{ARGS}}

switch-host *ARGS:
    jj status
    sudo nixos-rebuild switch --flake .#`hostname` {{ARGS}}
