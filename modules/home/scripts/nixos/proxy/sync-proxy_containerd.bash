#!/usr/bin/env bash

cd `dirname $0`

sudo mkdir -p /run/systemd/system/containerd.service.d/
cat << EOF >/tmp/containerd.service.d.override.conf
[Service]
Environment="http_proxy=$http_proxy"
Environment="https_proxy=$https_proxy"
Environment="all_proxy=$all_proxy"
EOF

sudo cp /tmp/containerd.service.d.override.conf /run/systemd/system/containerd.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart containerd

./show-proxy_containerd