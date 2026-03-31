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

show-git-remotes:
  cd moco/crew/yj ; git remote -v
  cd kinora/crew/yj ; git remote -v
  cd tsui/crew/yj ; git remote -v
  cd hub/crew/yj ; git remote -v

init-gastown:
  gt install ~/gt --git
  cp gt.justfile ~/gt/justfile

add-rigs:
  gt rig add moco https://github.com/edger-dev/moco.git
  gt rig add kinora https://github.com/edger-dev/kinora.git
  gt rig add tsui https://github.com/edger-dev/tsui.git
  gt rig add hub https://github.com/edger-dev/hub.git

add-dolt-remotes:
  cd moco ; bd dolt remote add origin git+https://github.com/edger-dev/moco.git
  cd kinora ; bd dolt remote add origin git+https://github.com/edger-dev/kinora.git
  cd tsui ; bd dolt remote add origin git+https://github.com/edger-dev/tsui.git
  cd hub ; bd dolt remote add origin git+https://github.com/edger-dev/hub.git

force-push-dolt:
  cd moco ; bd dolt push --verbose --force
  cd kinora ; bd dolt push --verbose --force
  cd tsui ; bd dolt push --verbose --force
  cd hub ; bd dolt push --verbose --force


add-crew:
  gt crew add yj --rig moco
  gt crew add yj --rig kinora
  gt crew add yj --rig tsui
  gt crew add yj --rig hub

add-git-remotes:
  cd moco/crew/yj ; git remote add yjpark https://github.com/yjpark/moco.git
  cd kinora/crew/yj ; git remote add yjpark https://github.com/yjpark/kinora.git
  cd tsui/crew/yj ; git remote add yjpark https://github.com/yjpark/tsui.git
  cd hub/crew/yj ; git remote add yjpark https://github.com/yjpark/hub.git

