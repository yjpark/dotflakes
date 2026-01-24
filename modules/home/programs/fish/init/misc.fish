set -x EDITOR nvim

set -x fish_greeting ""

set -x FLOX_SHELL fish
set -x FLOX_PROMPT_DISABLE 1

set -x KUBECONFIG ~/.kube/config
set -x RUSTC_WRAPPER sccache

~/.nix-profile/bin/shadowenv init fish | source
