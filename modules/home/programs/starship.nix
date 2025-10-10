{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$fill $time $fill $cmd_duration\n$all";
      right_format = "\${env_var}\${custom.shadowenv}";
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
      env_var = {
        variable = "FLOX_PROMPT_ENVIRONMENTS";
        format = "[$env_value]($style)";
        default = "";
        style = "purple bold";
      };
      custom.shadowenv = {
        command = "echo -n";
        symbol = " *";
        when = "with-shadowenv";
      };
    };
  };
}
