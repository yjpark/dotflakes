#!/usr/bin/env bash

WITH_SHADOWENV=$(shadowenv prompt-widget | wc -w)

if (( $WITH_SHADOWENV > 0 )); then
    exit 0
fi

exit 1
