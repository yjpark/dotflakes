{ pkgs, ... }: {
  programs.fish.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    reset-proxy = "set -ge https_proxy; set -ge http_proxy; set -ge all_proxy; set -ge NIX_CURL_FLAGS";
    show-proxy = "env | grep _proxy; env | grep NIX_CURL_FLAGS";
    set-proxy-verge = "set-proxy 127.0.0.1 1102";
    set-proxy-trojan = "set-proxy 127.0.0.1 31102";
    set-proxy-mitm = "set-proxy 127.0.0.1 1111";
    set-proxy-edger = "set-proxy 172.22.1.2 31102";
    set-proxy-edger_lan = "set-proxy 10.0.1.2 31102";
    #gemini = "npx https://github.com/google-gemini/gemini-cli";
    install-specify = "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git";
    specify = "uv tool run --from specify-cli specify";
  };
}
