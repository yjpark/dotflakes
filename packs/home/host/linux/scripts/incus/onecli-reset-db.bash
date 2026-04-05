#!/usr/bin/env bash

# Reset OneCLI's database by wiping the postgres volume and restarting.
# Use when OneCLI fails to start due to a Prisma migration error (P3009).

set -eu

source `which color-logging`

info "Stopping OneCLI containers..."
podman stop onecli onecli-postgres 2>/dev/null || true
podman rm onecli onecli-postgres 2>/dev/null || true

info "Removing postgres data volume..."
podman volume rm onecli-pgdata 2>/dev/null || true

info "Starting postgres..."
systemctl start podman-onecli-postgres.service
sleep 5

info "Starting OneCLI..."
systemctl start podman-onecli.service

info "Waiting for OneCLI to be ready..."
for i in $(seq 1 30); do
    if curl -sf http://10.100.0.1:10254/healthz > /dev/null 2>&1; then
        info "OneCLI is up at http://10.100.0.1:10254"
        exit 0
    fi
    echo "  waiting... ($i/30)"
    sleep 2
done

error "OneCLI did not come up in time. Check: podman logs onecli"
exit 1
