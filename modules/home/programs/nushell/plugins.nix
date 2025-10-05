{pkgs, ...}: {
  programs.nushell.plugins = with pkgs.nushellPlugins; [
    polars
    semver
    gstat
    query
    units
    formats
    highlight
  ];
}
