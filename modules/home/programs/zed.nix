{ pkgs, ... }: {
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    extensions = [
      "just" "nix" "fish" "toml" "yaml" "lua"
    ];
    extraPackages = [ pkgs.nixd ];
  };
  programs.zed-editor.userKeymaps = [
    {
      context = "EmptyPane || SharedScreen || Workspace";
      bindings = {
        "alt-," = "command_palette::Toggle";
        "alt-." = "pane::DeploySearch";
        "alt-p" = "file_finder::Toggle";
        "alt-b" = "workspace::ToggleLeftDock";
        "alt-\\" = "workspace::ToggleRightDock";
        "alt-t" = "terminal_panel::ToggleFocus";
      };
    }
    {
      context = "Terminal";
      bindings = {
        "alt-t" = "terminal_panel::Toggle";
      };
    }
    {
      context = "Editor && (vim_mode == normal || vim_mode == visual)";
      bindings = {
        ";" = "command_palette::Toggle";
        "\\ g h d" = "editor::ToggleHunkDiff";
        "\\ g h r" = "editor::RevertSelectedHunks";
        "\\ t i" = "editor::ToggleInlayHints";
        "\\ u w" = "editor::ToggleSoftWrap";
        "\\ c z" = "workspace::ToggleCenteredLayout";
        "\\ m p" = "markdown::OpenPreview";
        "\\ m P" = "markdown::OpenPreviewToTheSide";
        "\\ f p" = "projects::OpenRecent";
        "\\ f m" = "editor::Format";
        "\\ f M" = "editor::FormatSelections";
        "\\ s w" = "pane::DeploySearch";
        "\\ a c" = "assistant::ToggleFocus";
        "g f" = "editor::OpenExcerpts";
      };
    }
    {
      context = "Editor && vim_mode == normal && !VimWaiting && !menu";
      bindings = {
        "alt-," = "command_palette::Toggle";
        "alt-." = "pane::DeploySearch";
        "alt-p" = "file_finder::Toggle";
        "alt-b" = "workspace::ToggleLeftDock";
        "alt-\\" = "workspace::ToggleRightDock";
        "alt-t" = "terminal_panel::ToggleFocus";
        # Close active panel
        "ctrl-w" = "pane::CloseActiveItem";
        # Close other items
        "shift-alt-w" = "pane::CloseInactiveItems";
        # Save file
        "ctrl-s" = "workspace::Save";
        # Show project panel with current file
        "alt-e" = "pane::RevealInProjectPanel";
        # Go to
        "g d" = "editor::GoToDefinition";
        "g D" = "editor::GoToDefinitionSplit";
        "g i" = "editor::GoToImplementation";
        "g I" = "editor::GoToImplementationSplit";
        "g t" = "editor::GoToTypeDefinition";
        "g T" = "editor::GoToTypeDefinitionSplit";
        "g r" = "editor::FindAllReferences";
        "s s" = "outline::Toggle";
        "s S" = "project_symbols::Toggle";
        "] d" = "editor::GoToDiagnostic";
        "[ d" = "editor::GoToPreviousDiagnostic";
        # Git prev/next hunk
        "] h" = "editor::GoToHunk";
        "[ h" = "editor::GoToPreviousHunk";
        # Switch between buffers
        "ctrl-p" = "pane::ActivatePreviousItem";
        "ctrl-n" = "pane::ActivateNextItem";
      };
    }
  ];
  programs.zed-editor.userSettings = {
    vim_mode = true;
    vim.enable_vim_sneak = true;
    theme = "Gruvbox Dark";
    tab_bar.show = true;
    indent_guides = {
      enabled = true;
      coloring = "indent_aware";
    };
    inlay_hints.enable = true;
    auto_install_extensions = true;
    hour_format = "hour24";
    auto_update = false;
    ui_font_size = 18;
    font_family = "FiraCode Nerd Font Mono";
    font_features = null;
    line_height = "comfortable";
  };
}
