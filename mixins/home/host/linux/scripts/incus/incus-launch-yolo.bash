#!/usr/bin/env bash

incus launch yolo yolo

incus config set yolo security.nesting true
incus config set yolo raw.lxc "lxc.cap.keep = net_raw"

# Static IP for ingress DNS (see mixins/nixos/host/incus-ingress.nix)
incus config device override yolo eth0 ipv4.address=10.100.0.100

incus config device add yolo agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true
