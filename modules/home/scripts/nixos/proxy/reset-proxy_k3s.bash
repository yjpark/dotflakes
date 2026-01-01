#!/usr/bin/env bash

cd `dirname $0`

sudo rm /run/systemd/system/k3s.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart k3s

./show-proxy_k3s
