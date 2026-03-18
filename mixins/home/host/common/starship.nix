{
  flake,
  ...
}: {
  home.file.".config/starship.toml".source = (flake.inputs.self + /modules/home/programs/starship/tokyo-night.toml);
}
