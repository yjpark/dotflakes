{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    # Kitty doesn't set COLORTERM by default; apps like jjui (lipgloss) use it
    # to detect 24-bit color support. Without it, hex colors fall back to ANSI 16.
    environment.COLORTERM = "truecolor";
    settings = {
      font_family = "Hurmit Nerd Font Mono";
      font_size = "16";
      hide_window_decorations = "yes";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_title_template = "  [{index}] {title.partition(' | ')[0]}  ";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
    keybindings = {
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";
      "ctrl+left" = "previous_tab";
      "ctrl+right" = "next_tab";
      "ctrl+alt+left" = "move_tab_backward";
      "ctrl+alt+right" = "move_tab_forward";
      "ctrl+backslash" = ''combine : send_text all \x20 : send_text all \\ : sleep 0.05 : send_text all \n'';
    };
  };
  home.packages = [
    (pkgs.writeShellScriptBin "kitty-themes" ''
      #!/usr/bin/env bash
      echo "Select the theme, save for Dark/Light, will take effect afterwards"
      kitty +kitten themes

      # Note: on OSX, it's not auto loading some time, force a reload here
      killall -USR1 kitty

      echo "On OSX, the shortcut to reload config is <Ctrl+Cmd+Comma>"
    '')
  ];
}
