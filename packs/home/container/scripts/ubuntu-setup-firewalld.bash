#!/usr/bin/env bash

set -euxo pipefail

# Install incus from Ubuntu native repos
sudo apt-get update -y

DEBIAN_FRONTEND=noninteractive sudo apt-get install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --zone=trusted --add-interface=incusbr0 --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=trusted --list-interfaces

echo "firewalld config complete."


