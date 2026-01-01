#!/usr/bin/env bash

cd `dirname $0`

sudo mkdir -p /run/systemd/system/nix-daemon.service.d/
cat << EOF >/tmp/nix-daemon.service.d.override.conf
[Service]
Environment="http_proxy=$http_proxy"
Environment="https_proxy=$https_proxy"
Environment="all_proxy=$all_proxy"
Environment="NIX_CURL_FLAGS=$NIX_CURL_FLAGS"
EOF

sudo cp /tmp/nix-daemon.service.d.override.conf /run/systemd/system/nix-daemon.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

./show-proxy_nix-daemon
