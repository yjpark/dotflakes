#!/usr/bin/env bash

incus launch images:ubuntu/noble/cloud ubuntu --config cloud-init.user-data="$(cat << YAML_EOF
#cloud-config
packages:
  - xz_utils
  - curl
  - just
  - git
  - tig
  - gitu
  - lazygit
users:
  - name: yj
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
YAML_EOF
)"

incus config set ubuntu security.nesting true

incus config device add ubuntu agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true
