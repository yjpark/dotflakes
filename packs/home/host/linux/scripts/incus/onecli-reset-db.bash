#!/usr/bin/env bash

# Reset OneCLI's database by wiping postgres data and restarting the onecli container.
# Use when OneCLI fails to start due to a Prisma migration error (P3009).

set -eu

source `which color-logging`

ONECLI_CONTAINER="onecli"
BASE_URL="http://10.100.0.2:10254"

info "Stopping OneCLI service in container $ONECLI_CONTAINER..."
incus exec "$ONECLI_CONTAINER" -- systemctl stop podman-onecli.service 2>/dev/null || true

info "Stopping PostgreSQL in container $ONECLI_CONTAINER..."
incus exec "$ONECLI_CONTAINER" -- systemctl stop postgresql.service 2>/dev/null || true

info "Wiping OneCLI postgres data..."
incus exec "$ONECLI_CONTAINER" -- bash -c 'rm -rf /var/lib/postgresql/*'

info "Starting PostgreSQL..."
incus exec "$ONECLI_CONTAINER" -- systemctl start postgresql.service
sleep 3

info "Starting OneCLI..."
incus exec "$ONECLI_CONTAINER" -- systemctl start podman-onecli.service

info "Waiting for OneCLI to be ready..."
for i in $(seq 1 30); do
    if curl -sf "$BASE_URL/api/auth/session" > /dev/null 2>&1; then
        info "OneCLI is up at $BASE_URL"
        exit 0
    fi
    echo "  waiting... ($i/30)"
    sleep 2
done

error "OneCLI did not come up in time. Check: incus exec $ONECLI_CONTAINER -- journalctl -u podman-onecli"
exit 1
