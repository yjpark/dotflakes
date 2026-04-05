{ config, pkgs, ... }: {
    programs.vscode.profiles.default.userSettings = {
        "vim.neovimPath" = "/etc/profiles/per-user/yjpark/bin/nvim";
        "vim.enableNeovim" = true;
        "vim.disableAnnoyingNeovimMessage" = true;
        "vim.useSystemClipboard" = true;
        "vim.sneak" = true;
        "vim.easymotion" = true;
        "vim.easymotionKeys" = "aoeuidhtnspyfgcrlqjkxbmwvz;";
        "vim.normalModeKeyBindings" = [
            {
                "before" = [";"];
                "after" = [":"];
            } {
                "before" = ["<Enter>"];
                "after" = ["i"];
            } {
                "before" = ["<Backspace>"];
                "after" = ["i" "<Backspace>"];
            } {
                "before" = ["<C-w>"];
                "after" = [];
                "commands" = [
                    {
                        "command" = "workbench.action.closeActiveEditor";
                        "args" = [];
                    }
                ];
            } {
                "before" = ["<C-n>"];
                "after" = [];
                "commands" = [
                    {
                        "command" = ":tabnext";
                        "args" = [];
                    }
                ];
            } {
                "before" = ["<C-p>"];
                "after" = [];
                "commands" = [
                    {
                        "command" = ":tabprevious";
                        "args" = [];
                    }
                ];
            } {
                "before" = ["<C-s>"];
                "after" = [];
                "commands" = [
                    {
                        "command" = "workbench.action.files.save";
                        "args" = [];
                    }
                ];
            }
        ];
        "vim.insertModeKeyBindings" = [
            {
                "before" = ["<C-s>"];
                "after" = [];
                "commands" = [
                    {
                        "command" = "workbench.action.files.save";
                        "args" = [];
                    }
                ];
            }
        ];
        "vim.visualModeKeyBindingsNonRecursive" = [
            {
                "before" = [";"];
                "after" = [":"];
            } {
                "before" = [">"];
                "commands" = [
                    {
                        "command" = "editor.action.indentLines";
                    }
                ];
            } {
                "before" = ["<"];
                "commands" = [
                    {
                        "command" = "editor.action.outdentLines";
                    }
                ];
            }
        ];
    };
}
