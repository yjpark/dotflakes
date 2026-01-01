#!/usr/bin/env bash

sudo cp /etc/rancher/k3s/k3s.yaml .secret.k3s.yaml
sudo chown ${USER}:users .secret.k3s.yaml
sudo chmod 400 .secret.k3s.yaml
cp .secret.k3s.yaml ~/.kube/config
