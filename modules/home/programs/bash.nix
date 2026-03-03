{
  programs.bash = {
    enable = true;
    enableCompletion = false;
    initExtra = ''
      if [[ $- == *i* ]]; then
        exec fish
      fi
    '';
  };
}
