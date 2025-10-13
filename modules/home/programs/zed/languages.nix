{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
  ];
  programs.zed-editor.userSettings.languages = {
    Nix = {
      formatter.external = {
        command = "alejandra";
        arguments = ["--quiet" "--"];
      };
    };
  };
  programs.zed-editor.userSettings.language_overrides = {
    Nix.tab_size = 2;
    #JavaScript.tab_size = 2;
  };
}
