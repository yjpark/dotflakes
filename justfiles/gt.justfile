push-dolt:
  cd moco ; bd dolt push --verbose
  cd kinora ; bd dolt push --verbose
  cd tsui ; bd dolt push --verbose
  cd hub ; bd dolt push --verbose

show-dolt-remotes:
  cd moco ; bd dolt remote list
  cd kinora ; bd dolt remote list
  cd tsui ; bd dolt remote list
  cd hub ; bd dolt remote list

setup-dolt-remotes:
  cd moco ; bd dolt remote add origin git+https://github.com/edger-dev/moco.git
  cd kinora ; bd dolt remote add origin git+https://github.com/edger-dev/kinora.git
  cd tsui ; bd dolt remote add origin git+https://github.com/edger-dev/tsui.git
  cd hub ; bd dolt remote add origin git+https://github.com/edger-dev/hub.git

init-gastown:
  gt install ~/gt --git
  cp gt.justfile ~/gt/justfile

add-rigs:
  git rig add moco https://github.com/edger-dev/moco.git
  git rig add kinora https://gitkinora.com/edger-dev/kinora.git
  git rig add tsui https://github.com/edger-dev/tsui.git
  git rig add hub https://github.com/edger-dev/hub.git
