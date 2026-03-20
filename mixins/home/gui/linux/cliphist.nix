{...}: {
  programs.fish.functions.clip = ''
    set -l result (tv cliphist)
    and echo $result | cliphist decode | wl-copy
  '';

  xdg.configFile."television/cable/cliphist.toml".text = ''
    [metadata]
    name = "cliphist"
    description = "Clipboard history (via cliphist)"

    [source]
    command = "cliphist list"

    [preview]
    command = "cliphist decode '{}'"
  '';
}
