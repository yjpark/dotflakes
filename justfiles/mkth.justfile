show-git-remotes:
  cd moco ; git remote -v
  cd kinora ; git remote -v
  cd tsui ; git remote -v
  cd hub ; git remote -v

add-repos:
  git clone git@github.com:edger-dev/moco.git
  git clone git@github.com:edger-dev/kinora.git
  git clone git@github.com:edger-dev/tsui.git
  git clone git@github.com:edger-dev/hub.git

add-git-remotes:
  cd moco ; git remote add yjpark git@github.com:yjpark/moco.git ; git fetch yjpark
  cd kinora ; git remote add yjpark git@github.com:yjpark/kinora.git ; git fetch yjpark
  cd tsui ; git remote add yjpark git@github.com:yjpark/tsui.git ; git fetch yjpark
  cd hub ; git remote add yjpark git@github.com:yjpark/hub.git ; git fetch yjpark

remove-git-remotes:
  cd moco ; git remote remove yjpark
  cd kinora ; git remote remove yjpark
  cd tsui ; git remote remove yjpark
  cd hub ; git remote remove yjpark

init-mkth:
  cd ~/agents ; mkdir -p mkth ; ln -s ~/.flakes/justfiles/mkth.justfile mkth/.justfile
  
