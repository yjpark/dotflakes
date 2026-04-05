#!/usr/bin/env bash

source `which color-logging`

set +eu

INFO=$(cos-cli info --json)

if [ ! $1 ] ; then
    echo "$INFO" | jq '[.apps[].app_id]'
    printf "%s " "${MAGENTA}Please specify a app-id${NO_COLOR}"
    exit -1
fi

INDEX=$(echo "$INFO" | jq --arg app_id "$1" '[.apps[].app_id] | index($app_id)')
if [ "$INDEX" = "null" ] || [ -z "$INDEX" ]; then
    PARTIAL=$(echo "$INFO" | jq --arg app_id "$1" \
        '[.apps[].app_id] | to_entries | map(select(.value | ascii_downcase | contains($app_id | ascii_downcase)))')
    COUNT=$(echo "$PARTIAL" | jq 'length')
    if [ "$COUNT" = "1" ]; then
        INDEX=$(echo "$PARTIAL" | jq '.[0].key')
        MATCHED=$(echo "$PARTIAL" | jq -r '.[0].value')
        info "Matched '$MATCHED' for '$1'"
    elif [ "$COUNT" -gt "1" ]; then
        warn "Multiple apps match '$1':"
        echo "$PARTIAL" | jq '[.[].value]'
        exit 1
    else
        echo "$INFO" | jq '[.apps[].app_id]'
        warn "App-id '$1' not found"
        exit 1
    fi
fi
cos-cli activate -i $INDEX
