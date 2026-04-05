{pkgs, ...}: {
  home.packages = with pkgs; [
    incus
  ];

  programs.fish.interactiveShellInit = ''
    if type -q incus
      incus completion fish | source
    end
  '';
}
