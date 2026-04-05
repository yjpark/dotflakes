{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kubectx
    kubeshark
    kubespy
    kompose
    kubevela
  ];
}
