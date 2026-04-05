#!/usr/bin/env bash

incus snapshot create spacebot --reuse latest
incus restart spacebot
incus snapshot restore spacebot latest
