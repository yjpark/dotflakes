apply-extras host:
    jj new
    cp config.common.kdl config.kdl
    cat extras.{{host}}.kdl >> config.kdl

flakes-apply-extras host:
    jj new
    cp ~/.flakes/modules/home/settings/niri/config/config.common.kdl config.kdl
    cat ~/.flakes/modules/home/settings/niri/config/extras.{{host}}.kdl >> config.kdl

