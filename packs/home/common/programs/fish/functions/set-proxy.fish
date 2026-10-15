set -gx https_proxy http://$argv[1]:$argv[2];
set -gx http_proxy http://$argv[1]:$argv[2];
set -gx all_proxy http://$argv[1]:$argv[2];
# Keep local, LAN, incus and ZeroTier traffic off the proxy (same list as
# mixins/nixos/cn/proxy-env.nix). Without it, clients like Claude Code send
# requests for the monitoring hubs' MCP servers to clash, which returns 502.
set -gx no_proxy localhost,127.0.0.1,::1,mirrors.tuna.tsinghua.edu.cn,cache.nixos.org,10.0.0.0/8,172.22.0.0/16,.yjpark.org,.yjpark.zerotier,.incus;
set -gx NIX_CURL_FLAGS -x http://$argv[1]:$argv[2]
