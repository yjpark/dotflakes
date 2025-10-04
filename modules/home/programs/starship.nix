{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$fill $time $fill $cmd_duration\n$all";
      add_newline = false;
      aws = {
        disabled = true;
      };
      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "gray";
      };
      cmd_duration = {
        min_time = 0;
        format = "[$duration]($style)";
        show_milliseconds = true;
        style = "yellow";
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      fill = {
        symbol = "═";
        style = "gray";
      };
    };
  };
}
