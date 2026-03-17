#!/usr/bin/env bash

set -eu

cd `dirname $0`

sudo apt update
sudo apt install -y curl just

# https://nixos.org/download/#nix-install-linux
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

mkdir -p ~/.config/nix
cp nix.conf ~/.config/nix
