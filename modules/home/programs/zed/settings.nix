{ pkgs, ... }: {
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    extensions = [
      "just" "nix" "fish" "toml" "yaml" "lua"
    ];
    extraPackages = [ pkgs.nixd ];
  };
  programs.zed-editor.userSettings = {
    assistant.enabled = false;
    title_bar = {
      show_branch_icon= true;
      show_branch_name = true;
      show_project_items = true;
      show_sign_in = false;
      show_user_picture = true;
      show_onboarding_banner = false;
      show_menus = false;
    };
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
