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
        # Full theme using ANSI 256 indexed colors (16-255) — terminal-independent.
        # IndexedColor passes through unchanged in both ANSI256 and TrueColor modes.
        # One Dark-inspired palette mapped to nearest ANSI 256 equivalents.

        # --- Core ---
        dimmed = "241";           # #5c6370 → #626262
        title = { fg = "176"; bold = true; };  # #c678dd → #d787d7
        shortcut = "176";         # #c678dd → #d787d7
        matched = "73";           # #56b6c2 → #5fafaf
        selected = { fg = "73"; bg = "236"; };  # #56b6c2, #2c313c → #5fafaf, #303030
        target_marker = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046 → #1c1c1c, #af5f5f
        source_marker = { fg = "234"; bg = "73"; };  # #1a1a1a, #56b6c2 → #1c1c1c, #5fafaf
        success = "114";          # #98c379 → #87d787
        error = "167";            # #e06c75 → #d75f5f

        # --- Flash ---
        "flash selected" = "73";  # #56b6c2
        "flash text" = "249";     # #abb2bf → #b2b2b2
        "flash success" = "114";  # #98c379
        "flash error" = "167";    # #e06c75
        "flash matched" = "73";   # #56b6c2

        # --- Confirmation dialog ---
        "confirmation text" = { fg = "176"; bold = true; };  # #c678dd
        "confirmation selected" = { fg = "255"; bg = "68"; bold = true; };  # #ebebeb, #3d78c0 → #eeeeee, #5f87d7
        "confirmation dimmed" = "248";  # #9da5b4 → #a8a8a8

        # --- Help panel ---
        "help title" = { fg = "114"; bold = true; };  # #98c379
        "help dimmed" = "241";    # #5c6370
        "help shortcut" = "176";  # #c678dd
        "help desc" = "249";      # #abb2bf

        # --- Revisions list ---
        "revisions text" = "249"; # #abb2bf
        "revisions dimmed" = "241";  # #5c6370
        "revisions matched" = { underline = false; reverse = true; };
        "revisions selected" = { fg = "73"; bg = "236"; };  # #56b6c2, #2c313c

        # --- Revision detail panel ---
        "revisions details text" = "249";     # #abb2bf
        "revisions details selected" = { bg = "236"; };  # #2c313c
        "revisions details dimmed" = "241";   # #5c6370
        "revisions details added" = "114";    # #98c379
        "revisions details modified" = "180"; # #e5c07b → #d7af87
        "revisions details renamed" = "75";   # #61afef → #5fafff
        "revisions details copied" = "73";    # #56b6c2
        "revisions details deleted" = "167";  # #e06c75
        "revisions details conflict" = { fg = "167"; bold = true; };  # #e06c75

        # --- Revset bar ---
        "revset title" = "176";   # #c678dd
        "revset text" = { fg = "114"; bold = true; };  # #98c379

        # --- Revset completion popup ---
        "revset completion" = { bg = "235"; };  # #21252b → #262626
        "revset completion dimmed" = { fg = "241"; };   # #5c6370
        "revset completion text" = { fg = "114"; };     # #98c379
        "revset completion matched" = { fg = "114"; underline = true; bold = true; };  # #98c379
        "revset completion selected" = { bg = "97"; };  # #6e40b5 → #875faf

        # --- Status bar ---
        "status title" = { fg = "234"; bg = "176"; bold = true; };  # #1a1a1a, #c678dd
        "status text" = "249";    # #abb2bf
        "status dimmed" = "241";  # #5c6370
        "status shortcut" = "176";  # #c678dd

        # --- Menu ---
        "menu title" = { fg = "230"; bg = "62"; bold = true; };  # #ffffd7, #5f5fd7 (already ANSI 256)
        "menu subtitle" = { fg = "230"; bold = true; };  # #ffffd7
        "menu matched" = { fg = "176"; bold = true; };   # #c678dd
        "menu selected" = { fg = "73"; bold = true; underline = false; };  # #56b6c2

        # --- Picker ---
        "picker text" = "249";    # #abb2bf
        "picker dimmed" = "241";  # #5c6370
        "picker matched" = "73";  # #56b6c2
        "picker selected" = { fg = "73"; bold = true; underline = false; };  # #56b6c2
        "picker bookmark" = "180";  # #e5c07b

        # --- Operation log ---
        "oplog text" = "249";     # #abb2bf
        "oplog matched" = { underline = false; reverse = true; };
        "oplog selected" = { fg = "73"; bg = "236"; };  # #56b6c2, #2c313c

        # --- Evolution log ---
        "evolog text" = "249";    # #abb2bf
        "evolog dimmed" = "241";  # #5c6370
        "evolog selected" = { fg = "73"; bg = "236"; };  # #56b6c2, #2c313c
        "evolog target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046
        "evolog change_id" = "176";   # #c678dd
        "evolog commit_id" = "75";    # #61afef

        # --- Interactive rebase / squash / etc. ---
        "rebase dimmed" = "241";  # #5c6370
        "rebase shortcut" = "176";  # #c678dd
        "rebase source_marker" = { fg = "234"; bg = "73"; };   # #1a1a1a, #56b6c2
        "rebase target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046
        "rebase change_id" = "176";  # #c678dd

        "squash dimmed" = "241";  # #5c6370
        "squash source_marker" = { fg = "234"; bg = "73"; };   # #1a1a1a, #56b6c2
        "squash target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046

        "duplicate dimmed" = "241";  # #5c6370
        "duplicate source_marker" = { fg = "234"; bg = "73"; };  # #1a1a1a, #56b6c2
        "duplicate target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046
        "duplicate change_id" = "176";  # #c678dd

        "revert dimmed" = "241";  # #5c6370
        "revert shortcut" = "176";  # #c678dd
        "revert source_marker" = { fg = "234"; bg = "73"; };   # #1a1a1a, #56b6c2
        "revert target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046
        "revert change_id" = "176";  # #c678dd

        "set_parents dimmed" = "241";  # #5c6370
        "set_parents source_marker" = { fg = "234"; bg = "73"; };  # #1a1a1a, #56b6c2
        "set_parents target_marker" = { fg = "234"; bg = "131"; bold = true; };  # #1a1a1a, #be5046

        # --- Input / password ---
        "input text" = "249";     # #abb2bf
        "input title" = { fg = "176"; bold = true; };   # #c678dd
        "password title" = { fg = "176"; bold = true; };  # #c678dd

        # --- Choose ---
        "choose text" = "249";    # #abb2bf
        "choose title" = { fg = "176"; bold = true; };  # #c678dd
        "choose selected" = { fg = "73"; bg = "236"; };  # #56b6c2, #2c313c
        "choose input" = "249";   # #abb2bf
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
