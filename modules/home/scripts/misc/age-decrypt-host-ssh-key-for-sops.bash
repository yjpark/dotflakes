#!/usr/bin/env bash

mkdir -p ~/.config/sops/age
sudo cat /etc/ssh/ssh_host_ed25519_key | ssh-to-age -private-key > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age > ~/.config/sops/age/host.pub.txt

echo "~/.config/sops/age/"
ls -l ~/.config/sops/age/
cat ~/.config/sops/age/host.pub.txt

