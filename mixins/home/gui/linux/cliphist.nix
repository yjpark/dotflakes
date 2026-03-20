{...}: {
  programs.fish.functions.tv-cliphist = ''
    set -l result (tv cliphist)
    and echo $result | cliphist decode | wl-copy
  '';

  programs.television.channels.cliphist = {
    metadata = {
      name = "cliphist";
      description = "Clipboard history (via cliphist)";
    };
    source.command = "cliphist list";
    preview.command = "cliphist decode '{}'";
  };
}
