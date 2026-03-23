#!/usr/bin/env bash

mkdir -p ~/tools/
cd ~/tools/
git clone https://github.com/hmans/beans.git
cd beans
git remote add yjpark git@github.com:yjpark/beans.git
jj git init --colocate
