{
  flake,
  ...
}: {
  home.file.".config/starship.toml".source = (flake.inputs.self + /modules/home/programs/starship/gruvbox-rainbow.toml);
}
