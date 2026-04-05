{ config, pkgs, ... }: {
    programs.vscode.profiles.default.userSettings = {
      # "rust-analyzer.checkOnSave" = false;
      "rust-analyzer.files.excludeDirs" = [
        "**/external"
      ];
    };
}

