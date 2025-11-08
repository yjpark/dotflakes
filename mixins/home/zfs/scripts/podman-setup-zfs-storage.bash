#!/usr/bin/env bash
# https://nixos.wiki/wiki/Podman

sudo zfs create -o mountpoint=/var/lib/containers/storage rpool/state/podman
sudo zfs set acltype=posixacl rpool/state/podman

