{
  programs.fish.shellAbbrs = {
    i = "incus";
    ii = "incus image";
    il = "incus list";
    is = "incus shell";
    ic = "incus completion fish | source";
    u = "TERM=xterm-256color incus exec ubuntu -- login -f yj";
    y = "TERM=xterm-256color incus exec yolo -- login -f yj";
  };
}
