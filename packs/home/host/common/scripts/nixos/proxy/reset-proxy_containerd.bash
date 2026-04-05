#!/usr/bin/env bash

cd `dirname $0`

sudo rm /run/systemd/system/containerd.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart containerd

./show-proxy_containerd