{ config, pkgs, ... }: {
    programs.vscode.profiles.default.keybindings = [
        {
            key = "ctrl+a";
            command = "cursorLineStart";
        }
        {
            key = "ctrl+e";
            command = "cursorLineEnd";
        }
    ];
}

