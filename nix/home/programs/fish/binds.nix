{ pkgs, ... }: {
  programs.fish.binds = {
    ctrl-l.command = ["clear-buffer" "repaint"];
  };
}
