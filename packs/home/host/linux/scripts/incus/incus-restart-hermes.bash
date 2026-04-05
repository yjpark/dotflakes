#!/usr/bin/env bash

incus snapshot create hermes --reuse latest
incus restart hermes
incus snapshot restore hermes latest
