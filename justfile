activate-home *ARGS:
    jj status
    nix run {{ARGS}}

show:
    jj status
    om show .

flake-update-llm-agents:
    @just flake-update llm-agents

flake-update *ARGS:
    nix flake update {{ARGS}}
    jj status

# Sometime stuck with nurHash not matched issue, need to remove flake.lock to fix this
flake-reset:
    rm flake.lock
    nix flake update
    jj new

build-host command="build" *ARGS:
    jj status
    nixos-rebuild {{command}} --flake .#`hostname` {{ARGS}}

switch-host *ARGS:
    jj status
    sudo nixos-rebuild switch --flake .#`hostname` {{ARGS}}
    sudo chown yjpark:wheel flake.lock
