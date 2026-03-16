#!/usr/bin/env bash

incus launch images:ubuntu/noble/cloud yolo --config cloud-init.user-data="$(cat << YAML_EOF
#cloud-config
packages:
  - xz_utils
  - curl
  - just
  - git
  - tig
  - lazygit
users:
  - name: yj
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
YAML_EOF
)"

incus config device add yolo agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true
