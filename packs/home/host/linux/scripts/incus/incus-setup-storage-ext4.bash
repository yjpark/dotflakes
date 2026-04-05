#!/usr/bin/env bash

incus storage create zfs-pool zfs size=200GiB
incus profile device set default root pool=zfs-pool
