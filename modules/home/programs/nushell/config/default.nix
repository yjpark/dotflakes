{flake, ...}: {
  programs.nushell.extraConfig = flake.inputs.autowire.concatContents_nu ./.;
}
