#!/usr/bin/env bash

set -euxo pipefail

# Install system packages
sudo apt-get update -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y caddy dnsmasq python3

# Create directories (caddy dir must be world-readable for ingress status script)
sudo mkdir -p /var/lib/caddy /var/lib/ingress/hub
sudo chmod 755 /var/lib/caddy

# Deploy hub HTML from Home Manager profile
HUB_HTML=""
for profile_dir in "$HOME/.nix-profile" "/etc/profiles/per-user/$USER"; do
  if [ -f "$profile_dir/share/ingress/hub-index.html" ]; then
    HUB_HTML="$profile_dir/share/ingress/hub-index.html"
    break
  fi
done
if [ -n "$HUB_HTML" ]; then
  sudo cp "$HUB_HTML" /var/lib/ingress/hub/index.html
else
  echo "ERROR: Could not find hub-index.html in Nix profile. Run home-manager activation first."
  exit 1
fi

# Write static Caddyfile
sudo tee /etc/caddy/Caddyfile > /dev/null <<'EOF'
{
  log {
    level ERROR
  }
  auto_https disable_redirects
}
import /var/lib/caddy/*.conf
EOF

# Configure dnsmasq on port 5354 (avoid conflicting with systemd-resolved on 53)
sudo tee /etc/dnsmasq.d/ingress.conf > /dev/null <<'EOF'
address=/.incus/127.0.0.1
local=/.incus/
port=5354
listen-address=127.0.0.1
bind-interfaces
no-resolv
EOF

# Configure DNS forwarding for .incus domain
if systemctl is-active systemd-resolved &>/dev/null || systemctl is-enabled systemd-resolved &>/dev/null; then
  # systemd-resolved is available: forward .incus queries to dnsmasq
  sudo mkdir -p /etc/systemd/resolved.conf.d
  sudo tee /etc/systemd/resolved.conf.d/ingress.conf > /dev/null <<'EOF'
[Resolve]
DNS=127.0.0.1:5354
Domains=~incus
EOF
else
  # No systemd-resolved (typical in LXC containers): run dnsmasq on port 53 instead
  # and add it to /etc/resolv.conf
  sudo sed -i 's/^port=5354$/port=53/' /etc/dnsmasq.d/ingress.conf
  if ! grep -q '127.0.0.1' /etc/resolv.conf 2>/dev/null; then
    sudo sed -i '1i nameserver 127.0.0.1' /etc/resolv.conf
  fi
fi

# Resolve script paths (from Nix profile on PATH)
GEN_CMD=$(command -v generate-ingress-config)
SYNC_API_CMD=$(command -v ingress-sync-api)

# Systemd unit: ingress-sync-api (long-running Python HTTP server)
sudo tee /etc/systemd/system/ingress-sync-api.service > /dev/null <<EOF
[Unit]
Description=HTTP API for triggering ingress sync
After=caddy.service

[Service]
ExecStart=$SYNC_API_CMD
Restart=always
RestartSec=5
Environment=PATH=$PATH

[Install]
WantedBy=multi-user.target
EOF

# Systemd unit: ingress-sync (oneshot config regeneration)
sudo tee /etc/systemd/system/ingress-sync.service > /dev/null <<EOF
[Unit]
Description=Regenerate Caddy ingress config from listening ports
After=caddy.service
Requires=caddy.service

[Service]
Type=oneshot
ExecStart=$GEN_CMD
Environment=PATH=$PATH
EOF

# Systemd unit: init-ingress-ca (bootstrap CA bundle at boot)
sudo tee /etc/systemd/system/init-ingress-ca.service > /dev/null <<'EOF'
[Unit]
Description=Initialize ingress CA bundle
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt /var/lib/ingress/ca-bundle.crt

[Install]
WantedBy=sysinit.target
EOF

# Sudo rule: allow sudo group to restart ingress-sync without password
sudo tee /etc/sudoers.d/ingress > /dev/null <<'EOF'
%sudo ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart ingress-sync.service
EOF
sudo chmod 0440 /etc/sudoers.d/ingress

# SSL environment variables (for all users)
sudo tee /etc/profile.d/ingress-ssl.sh > /dev/null <<'EOF'
export SSL_CERT_FILE=/var/lib/ingress/ca-bundle.crt
export NIX_SSL_CERT_FILE=/var/lib/ingress/ca-bundle.crt
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now caddy dnsmasq ingress-sync-api init-ingress-ca
if systemctl is-active systemd-resolved &>/dev/null; then
  sudo systemctl restart systemd-resolved
fi

echo "Ingress setup complete. Run 'ingress-sync' to generate initial config."
