{
  programs.nushell.shellAliases = {
    a = "rg --smart-case";
    cat = "bat";
    e = "vim";
    g = "git";
    h = "hx";
    j = "just";
    jl = "just -l";
    jj = "just --justfile ~/.config/justfile --working-directory .";
    jt = "just --justfile ~/projects/edger-dev/templates/justfile";
    k = "kubectl";
    kn = "kubens";
    lg = "lazygit";
    l = "ls";
    ll = "ls -l";
    p = "podman";
    r = "tv --show-remote";
    tn = "tv nix-search-tv";
    y = "yazi";
    z = "zellij";
    za = "zellij action";
    zt = "zellij attach";
    zl = "zellij list-sessions";
  };
}
