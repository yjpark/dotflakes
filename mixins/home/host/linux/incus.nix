pkgs, ...}: {
  home.packages = with pkgs; [
    incus
  ];

  programs.fish.shellInit = ''
    if type -q incus
      incus completion fish | source
    end
  '';
}
