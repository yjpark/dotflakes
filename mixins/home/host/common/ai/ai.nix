{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pkgs.bun # needed by ccusage statusline
    pkgs.nodejs_25 # needed by context7
  ];
}
