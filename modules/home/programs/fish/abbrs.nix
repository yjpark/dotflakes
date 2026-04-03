{
  programs.fish.shellAbbrs = {
    a = "rg --smart-case";
    bc = "bacon";
    bn = "beans";
    bw = "beans-serve";
    bt = "beans-tui";
    cat = "bat";
    catcmd = "catwhich";
    dig = "doggo";
    du = "dust";
    e = "vim";
    f = "fd";
    d = "dotnet";
    g = "git";
    gu = "gitu";
    gl = "lazygit";
    gwp = "git-commit-wip-and-push";
    gsp = "git-commit-sync-and-push";
    h = "hx";
    # j is handled by _j_expand bound to Space in mise.nix (triggers completion after expansion)
    jl = {
      function = "_jl_abbr";
    };
    m = "mise";
    mr = "mise run";
    ml = "mise tasks";
    ju = "jjui";
    jz = "lazyjj";
    k = "kubectl";
    kn = "kubens";
    lg = "lazygit";
    p = "podman";
    ps = "procs";
    s = "shadowenv";
    sg = "ast-grep";
    sp = "sync-pass";
    top = "btm";
    tree = "exa -T";
    t = "clear-buffer ; tv --show-remote";
    tc = "clear-buffer ; tv-cliphist";
    tm = "clear-buffer ; tv-mise-tasks";
    tn = "clear-buffer ; tv nix-search-tv";
    "t." = "clear-buffer ; tv text";
    tp = "clear-buffer ; tv files";
    w = "workspace-cd";
    wc = "workspace-create";
    wl = "workspace-list";
    z = "zellij";
    za = "zellij action";
    zt = "zellij attach --create";
    zl = "zellij list-sessions";
    # ct, cc, zz are defined as functions in init/zellij.fish
  };
}
