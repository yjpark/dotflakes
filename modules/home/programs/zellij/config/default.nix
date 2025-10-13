{flake, ...}: {
  home.file.".config/zellij/config.kdl".text = flake.inputs.autowire.concatContents_kdl ./.;
}
