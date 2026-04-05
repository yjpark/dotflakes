#!/usr/bin/env bash

incus snapshot create hermes --reuse latest
incus stop hermes
incus snapshot restore hermes latest
incus start hermes
