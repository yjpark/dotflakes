{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    extensions = [
      "just"
      "nix"
      "fish"
      "toml"
      "yaml"
      "lua"
    ];
    extraPackages = [pkgs.nixd];
  };
  programs.zed-editor.userSettings = {
    agent.enabled = false;
    title_bar = {
      show_branch_icon = true;
      show_branch_name = true;
      show_project_items = true;
      show_sign_in = false;
      show_user_picture = true;
      show_onboarding_banner = false;
      show_menus = false;
    };
    vim_mode = true;
    vim.use_smartcase_find = true;
    theme = "Gruvbox Dark";
    tab_bar.show = true;
    indent_guides = {
      enabled = true;
      coloring = "indent_aware";
    };
    inlay_hints.enabled = true;
    auto_install_extensions = true;
    auto_update = false;
    ui_font_size = 18;
    ui_font_family = "Hurmit Nerd Font Mono";
    terminal.font_family = "Hurmit Nerd Font Mono";
    buffer_line_height = "comfortable";
    tab_size = 4;
  };
}
