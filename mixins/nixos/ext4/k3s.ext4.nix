{...}: {
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };
  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000" = {
        endpoint = [
          "http://localhost:5000"
        ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    6443
    80
    443
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 30000;
      to = 32767;
    }
  ];
}
