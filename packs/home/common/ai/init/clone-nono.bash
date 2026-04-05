#!/usr/bin/env bash

mkdir -p ~/tools/
cd ~/tools/
git clone git@github.com:always-further/nono.git
cd beans
git remote add yjpark git@github.com:yjpark/nono.git
jj git init --colocate
