folder:
    with builtins;
    map
      (file: "${folder}/${file}")
      (filter (file: file != "default.nix") (attrNames (readDir folder)))
