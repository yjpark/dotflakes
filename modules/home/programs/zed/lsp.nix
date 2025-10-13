{
  programs.zed-editor.userSettings.languages = {
    rust = {
      language_servers = [
        "rust-analyzer"
        "tailwindcss-language-server"
      ];
    };
  };
  programs.zed-editor.userSettings.lsp = {
    tailwindcss-language-server.settings = {
      includeLanguages = {
        "rust" = "html";
      };
      experimental = {
        classRegex = [
          "class=\"([^\"]*)"
          "class={\"([^\"}]*)"
          "class=format!({\"([^\"}]*)"
        ];
      };
    };
  };
}
