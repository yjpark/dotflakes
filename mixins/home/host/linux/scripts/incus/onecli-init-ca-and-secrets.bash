#!/usr/bin/env bash

# Re-run the OneCLI init service on the host: seeds secrets, pushes CA cert
# and proxy auth to agent containers. Use this after container reboot or when
# onecli-check-proxy reports CA/proxy issues inside a container.

set -eu

sudo systemctl start onecli-init-ca-and-secrets
journalctl -u onecli-init-ca-and-secrets --no-pager -n 30
