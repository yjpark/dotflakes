{
  flake,
  ...
}: {
  home.file.".config/starship.toml".source = (flake.inputs.self + /packs/home/common/programs/starship/tokyo-night.toml);
}
