#!/usr/bin/env bash

cd `dirname $0`

sudo rm /run/systemd/system/nix-daemon.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

./show-proxy_nix-daemon
