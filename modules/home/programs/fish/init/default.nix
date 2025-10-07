{ flake, ... }:
{
  programs.fish.interactiveShellInit = flake.inputs.autowire.concatContents_fish ./.;
}
