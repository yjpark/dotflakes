#!/usr/bin/env bash

incus snapshot create yolo --reuse latest
incus restart yolo
incus snapshot restore yolo latest
