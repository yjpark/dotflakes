activate-home *ARGS:
    jj status
    nix run {{ARGS}}

show:
    jj status
    om show .

flake-lock-niri:
    nix flake lock --update-input niri

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

build-yolo:
    nixos-rebuild build-image --image-variant lxc --flake .#yolo

launch-yolo:
    nix run .#incus-yolo-launch
    incus exec yolo -- nixos-rebuild switch --option experimental-features "nix-command flakes" --flake /root/yolo-flake#yolo

reset-wip:
    git fetch origin
    git reset --hard
    git checkout origin/wip
    git branch -D wip
    git checkout -b wip
