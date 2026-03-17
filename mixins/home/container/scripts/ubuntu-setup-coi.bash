#!/usr/bin/env bash

set -euxo pipefail

#newgrp incus-admin
curl -fsSL https://raw.githubusercontent.com/mensfeld/code-on-incus/master/install.sh | bash

