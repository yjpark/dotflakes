{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Only run in interactive sessions to prevent breaking SCP/SFTP/scripts
      if [[ $- == *i* && -z "$ZSH" ]]; then
        # Replace the current Zsh process with Fish
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
