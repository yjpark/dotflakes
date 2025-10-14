{
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
