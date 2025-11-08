{...}: {
  # https://discourse.nixos.org/t/open-firewall-ports-only-towards-local-network/13037
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 10.0.0.0/8 --dport 1000:65535 -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source 10.0.0.0/8 --dport 1000:65535 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --source 10.0.0.0/8 --dport 1000:65535 -j nixos-fw-accept || true
    iptables -D nixos-fw -p udp --source 10.0.0.0/8 --dport 1000:65535 -j nixos-fw-accept || true
  '';
}
