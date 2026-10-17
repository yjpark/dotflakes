{
  programs.fish.shellAbbrs = {
    i = "incus";
    ii = "incus image";
    il = "incus list";
    is = "incus shell";
    ic = "incus completion fish | source";
    y = "TERM=xterm-256color incus exec yolo -- login -f yj";
    onecli = "TERM=xterm-256color incus exec onecli -- login -f yj";
    searxng = "TERM=xterm-256color incus exec searxng -- login -f yj";
  };
}
