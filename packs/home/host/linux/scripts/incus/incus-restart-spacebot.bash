#!/usr/bin/env bash

incus snapshot create spacebot --reuse latest
incus stop spacebot
incus snapshot restore spacebot latest
incus start spacebot
