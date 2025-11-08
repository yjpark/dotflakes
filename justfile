activate-home *ARGS:
    nix run {{ARGS}}

show:
    om show .

run *ARGS:
    nix run {{ARGS}}

update *ARGS:
    nix flake update {{ARGS}}

build-host command="build" *ARGS:
    nixos-rebuild {{command}} --flake .#`hostname` {{ARGS}}

switch-host *ARGS:
    sudo nixos-rebuild switch --flake .#`hostname` {{ARGS}}
