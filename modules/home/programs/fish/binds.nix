{pkgs, ...}: {
  programs.fish.binds = {
    ctrl-l.command = ["clear-buffer" "repaint"];
    alt-1.command = "zellij action go-to-tab 1";
    alt-2.command = "zellij action go-to-tab 2";
    alt-3.command = "zellij action go-to-tab 3";
    alt-4.command = "zellij action go-to-tab 4";
    alt-5.command = "zellij action go-to-tab 5";
    alt-6.command = "zellij action go-to-tab 6";
    alt-7.command = "zellij action go-to-tab 7";
    alt-8.command = "zellij action go-to-tab 8";
    alt-9.command = "zellij action go-to-tab 9";
  };
}
