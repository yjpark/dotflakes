#!/usr/bin/env bash

incus launch yolo yolo

incus config set yolo security.nesting true
incus config set yolo raw.lxc "lxc.cap.keep = net_raw"

incus config device add yolo agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true
