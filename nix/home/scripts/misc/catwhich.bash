#!/usr/bin/env bash

source `which color-logging`

set +eu

if [ ! $1 ] ; then
    printf "%s " "${MAGENTA}Please specify a name${NO_COLOR}"
    exit -1
fi

cmd=`which $1`

if [ $cmd ] ; then
    printf '%s\n' "${GREEN}${cmd}${NO_COLOR}"
    echo ""
    bat $cmd
else
    error "This cmd does not exist: $1"
fi
