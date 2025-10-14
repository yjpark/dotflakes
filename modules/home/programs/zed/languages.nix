{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
  ];
  programs.zed-editor.userSettings.languages.Rust = {
    language_servers = [
      "rust-analyzer"
      "tailwindcss-language-server"
    ];
  };
  programs.zed-editor.userSettings.languages.Nix = {
    tab_size = 2;
    formatter.external = {
      command = "alejandra";
      arguments = ["--quiet" "--"];
    };
  };
}
