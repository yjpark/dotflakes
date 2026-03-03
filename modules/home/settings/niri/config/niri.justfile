apply-extras host:
    cp config.common.kdl config.kdl
    cat extras.{{host}}.kdl >> config.kdl
