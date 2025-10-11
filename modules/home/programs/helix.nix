{ config, pkgs, ... }: {
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = "papercolar-dark";
    editor = {
      bufferline = "always";
      cursorline = true;
      cursorcolumn = true;
      trim-final-newlines = true;
      trim-trailing-whitespace = true;
    };
    keys.normal = {
      ";" = "command_palette";
      "A-," = "command_palette";
      "A-." = "global_search";
      "A-p" = "file_picker";
      "C-s" = ":write";
      "C-n" = "goto_next_buffer";
      "C-p" = "goto_previous_buffer";
    };
  };
}
