#!/usr/bin/env bash

set -euxo pipefail

# Skip if incus is already installed and initialized
if command -v incus &>/dev/null && incus storage list &>/dev/null 2>&1; then
  echo "Incus already initialized, skipping provisioning."
  exit 0
fi

# Install incus from Ubuntu native repos
sudo apt-get update -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y incus

# Add lima user to incus-admin group
sudo usermod -aG incus-admin yj 2>/dev/null || true

# Initialize Incus with preseed
cat > /tmp/incus-preseed.yaml <<EOF
config: {}
networks:
  - name: incusbr0
    type: bridge
    config:
      ipv4.address: 10.100.0.1/24
      ipv4.nat: "true"
      ipv6.address: none
storage_pools:
  - name: default
    driver: dir
    config: {}
profiles:
  - name: default
    devices:
      eth0:
        name: eth0
        network: incusbr0
        type: nic
      root:
        path: /
        pool: default
        type: disk
EOF

sudo incus admin init --preseed < /tmp/incus-preseed.yaml
rm -f /tmp/incus-preseed.yaml

# Enable and start incus
sudo systemctl enable incus
sudo systemctl start incus

echo "Incus provisioning complete."
newgrp incus-admin

