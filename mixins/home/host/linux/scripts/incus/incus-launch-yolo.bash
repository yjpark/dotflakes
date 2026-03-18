#!/usr/bin/env bash

incus launch yolo yolo

incus config set yolo security.nesting true

incus config device add yolo agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true
