{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-ms-dotnettools-csharp"
      "vscode-extension-ms-vscode-remote-remote-ssh"
      "vscode-extension-fill-labs-dependi"
      "vscode-extension-visualjj-visualjj"
      "discord"
      "google-chrome"
      "microsoft-edge"
      "obsidian"
    ];
}
