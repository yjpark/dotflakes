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

build-image-yolo:
    nixos-rebuild build-image --image-variant lxc --flake .#yolo
    mkdir -p images/yolo/
    rm -vf images/yolo/*
    cp -v result/tarball/*.tar.xz images/yolo/
    rm result

build-metadata-yolo:
    nixos-rebuild build-image --image-variant lxc-metadata --flake .#yolo
    mkdir -p images/yolo-metadata/
    rm -vf images/yolo-metadata/*
    cp -v result/tarball/*.tar.xz images/yolo-metadata/
    rm result

incus-import-yolo:
    incus image import images/yolo-metadata/*.tar.xz images/yolo/*.tar.xz --alias yolo

beans-serve:
    beans-serve --cors-origin "*"
