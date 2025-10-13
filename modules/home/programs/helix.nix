{
  config,
  pkgs,
  ...
}: {
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = "papercolor-dark";
    editor = {
      bufferline = "always";
      cursorline = true;
      cursorcolumn = false;
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
