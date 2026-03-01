{...}: {
  programs.vscode.profiles.default.userSettings = {
    "terminal.integrated.fontFamily" = "Hurmit Nerd Font Mono";
    "terminal.integrated.commandsToSkipShell" = [
      # Terminal find widget - pass ctrl+f to shell (readline forward-char)
      "-workbench.action.terminal.focusFindWidget"
      "-workbench.action.terminal.focusFind"

      # Terminal scrolling - let terminal programs own their own scrolling
      "-workbench.action.terminal.scrollUp"
      "-workbench.action.terminal.scrollDown"
      "-workbench.action.terminal.scrollUpPage"
      "-workbench.action.terminal.scrollDownPage"
      "-workbench.action.terminal.scrollToTop"
      "-workbench.action.terminal.scrollToBottom"

      # Terminal navigation mode
      "-workbench.action.terminal.navigationModeExit"
      "-workbench.action.terminal.navigationModeUp"
      "-workbench.action.terminal.navigationModeDown"

      # Global VS Code commands that intercept common shell/readline shortcuts
      "-workbench.action.quickOpen" # ctrl+p (bash: prev-history)
      "-workbench.action.showCommands" # ctrl+shift+p
      "-workbench.action.findInFiles" # ctrl+shift+f
      "-workbench.action.gotoLine" # ctrl+g (bash: forward in history)
      "-workbench.action.toggleSidebarVisibility" # ctrl+b (vim: page-down, tmux prefix)

      # NOTE: "workbench.action.terminal.toggleTerminal" is intentionally absent
      # so that ctrl+` still toggles/hides the terminal panel
    ];
  };
}
