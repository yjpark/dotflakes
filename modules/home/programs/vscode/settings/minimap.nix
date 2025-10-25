{ config, pkgs, ... }: {
    programs.vscode.profiles.default.userSettings = {
        "editor.minimap.enabled" = true;
        "editor.minimap.side" = "right";
        "editor.minimap.showSlider" = "always";
        "editor.minimap.renderCharacters" = false;
        "editor.minimap.maxColumn" = 80;
    };
}

