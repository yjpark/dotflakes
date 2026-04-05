{flake, ...}: {
  programs.fish.functions = flake.inputs.autowire.gatherContents_fish ./.;
}
