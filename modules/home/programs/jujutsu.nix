{
  flake,
  config,
  pkgs,
  ...
}:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = "blt";
      user = {
        email = config.me.email;
        name = config.me.fullname;
      };
      git = {
        push = "yjpark";
        fetch = [
          "origin"
          "yjpark"
        ];
      };
      # https://github.com/jj-vcs/jj/blob/main/docs/config.md#set-of-immutable-commits
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };

      aliases = {
        try-resolve = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            # 1. Let mergiraf try to solve it automatically first
            jj resolve --tool mergiraf "$@"

            # 2. Fallback to Neovim (jj-diffconflicts) for anything left over
            jj resolve --tool diffconflicts "$@"
          ''
          "" # (Required) This acts as $0 so any extra arguments map correctly
        ];
        bl = [
          "bookmark"
          "list"
        ];
        bla = [
          "bookmark"
          "list"
          "--all"
        ];
        blt = [
          "bookmark"
          "list"
          "--tracked"
        ];
      };

      merge-tools.diffconflicts = {
        program = "nvim";
        merge-args = [
          "-c"
          "let g:jj_diffconflicts_marker_length=$marker_length"
          "-c"
          "JJDiffConflicts!"
          "$output"
          "$base"
          "$left"
          "$right"
        ];
        # This tells jj that the plugin handles the markers natively
        merge-tool-edits-conflict-markers = true;
      };
    };
  };
  programs.jjui = {
    enable = true;
    package = flake.inputs.jjui.packages.${pkgs.stdenv.hostPlatform.system}.jjui;
    settings = {
      ui.colors = {
        # Full theme using only hex/ANSI256 colors — works on any dark terminal.
        # Avoids ANSI 0-15 (terminal-dependent); uses One Dark-inspired palette.

        # --- Core ---
        dimmed = "#5c6370";
        title = { fg = "#c678dd"; bold = true; };
        shortcut = "#c678dd";
        matched = "#56b6c2";
        selected = { fg = "#56b6c2"; bg = "#2c313c"; };
        target_marker = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };
        source_marker = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        success = "#98c379";
        error = "#e06c75";

        # --- Flash ---
        "flash selected" = "#56b6c2";
        "flash text" = "#abb2bf";
        "flash success" = "#98c379";
        "flash error" = "#e06c75";
        "flash matched" = "#56b6c2";

        # --- Confirmation dialog ---
        "confirmation text" = { fg = "#c678dd"; bold = true; };
        "confirmation selected" = { fg = "#ebebeb"; bg = "#3d78c0"; bold = true; };
        "confirmation dimmed" = "#9da5b4";

        # --- Help panel ---
        "help title" = { fg = "#98c379"; bold = true; };
        "help dimmed" = "#5c6370";
        "help shortcut" = "#c678dd";
        "help desc" = "#abb2bf";

        # --- Revisions list ---
        "revisions text" = "#abb2bf";
        "revisions dimmed" = "#5c6370";
        "revisions matched" = { underline = false; reverse = true; };
        "revisions selected" = { fg = "#56b6c2"; bg = "#2c313c"; };

        # --- Revision detail panel ---
        "revisions details text" = "#abb2bf";
        "revisions details selected" = { bg = "#2c313c"; };
        "revisions details dimmed" = "#5c6370";
        "revisions details added" = "#98c379";
        "revisions details modified" = "#e5c07b";
        "revisions details renamed" = "#61afef";
        "revisions details copied" = "#56b6c2";
        "revisions details deleted" = "#e06c75";
        "revisions details conflict" = { fg = "#e06c75"; bold = true; };

        # --- Revset bar ---
        "revset title" = "#c678dd";
        "revset text" = { fg = "#98c379"; bold = true; };

        # --- Revset completion popup ---
        "revset completion" = { bg = "#21252b"; };
        "revset completion dimmed" = { fg = "#5c6370"; };
        "revset completion text" = { fg = "#98c379"; };
        "revset completion matched" = { fg = "#98c379"; underline = true; bold = true; };
        "revset completion selected" = { bg = "#6e40b5"; };

        # --- Status bar ---
        "status title" = { fg = "#1a1a1a"; bg = "#c678dd"; bold = true; };
        "status text" = "#abb2bf";
        "status dimmed" = "#5c6370";
        "status shortcut" = "#c678dd";

        # --- Menu ---
        "menu title" = { fg = "#ffffd7"; bg = "#5f5fd7"; bold = true; };
        "menu subtitle" = { fg = "#ffffd7"; bold = true; };
        "menu matched" = { fg = "#c678dd"; bold = true; };
        "menu selected" = { fg = "#56b6c2"; bold = true; underline = false; };

        # --- Picker ---
        "picker text" = "#abb2bf";
        "picker dimmed" = "#5c6370";
        "picker matched" = "#56b6c2";
        "picker selected" = { fg = "#56b6c2"; bold = true; underline = false; };
        "picker bookmark" = "#e5c07b";

        # --- Operation log ---
        "oplog text" = "#abb2bf";
        "oplog matched" = { underline = false; reverse = true; };
        "oplog selected" = { fg = "#56b6c2"; bg = "#2c313c"; };

        # --- Evolution log ---
        "evolog text" = "#abb2bf";
        "evolog dimmed" = "#5c6370";
        "evolog selected" = { fg = "#56b6c2"; bg = "#2c313c"; };
        "evolog target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };
        "evolog change_id" = "#c678dd";
        "evolog commit_id" = "#61afef";

        # --- Interactive rebase / squash / etc. ---
        "rebase dimmed" = "#5c6370";
        "rebase shortcut" = "#c678dd";
        "rebase source_marker" = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        "rebase target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };
        "rebase change_id" = "#c678dd";

        "squash dimmed" = "#5c6370";
        "squash source_marker" = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        "squash target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };

        "duplicate dimmed" = "#5c6370";
        "duplicate source_marker" = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        "duplicate target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };
        "duplicate change_id" = "#c678dd";

        "revert dimmed" = "#5c6370";
        "revert shortcut" = "#c678dd";
        "revert source_marker" = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        "revert target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };
        "revert change_id" = "#c678dd";

        "set_parents dimmed" = "#5c6370";
        "set_parents source_marker" = { fg = "#1a1a1a"; bg = "#56b6c2"; };
        "set_parents target_marker" = { fg = "#1a1a1a"; bg = "#be5046"; bold = true; };

        # --- Input / password ---
        "input text" = "#abb2bf";
        "input title" = { fg = "#c678dd"; bold = true; };
        "password title" = { fg = "#c678dd"; bold = true; };

        # --- Choose ---
        "choose text" = "#abb2bf";
        "choose title" = { fg = "#c678dd"; bold = true; };
        "choose selected" = { fg = "#56b6c2"; bg = "#2c313c"; };
        "choose input" = "#abb2bf";
      };
    };
  };
  programs.mergiraf = {
    enable = true;
    enableJujutsuIntegration = true;
    enableGitIntegration = true;
  };
  programs.difftastic = {
    enable = true;
    jujutsu.enable = true; # Injects the difftastic config into jj automatically
    options.display = "inline";
  };
}
