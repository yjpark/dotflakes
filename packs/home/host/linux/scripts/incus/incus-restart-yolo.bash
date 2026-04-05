#!/usr/bin/env bash

incus snapshot create yolo --reuse latest
incus stop yolo
incus snapshot restore yolo latest
incus start yolo
