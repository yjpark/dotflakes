set -x EDITOR nvim

set -x fish_greeting ""

set -x FLOX_SHELL fish
set -x FLOX_PROMPT_DISABLE 1

set -x KUBECONFIG ~/.kube/config
set -x RUSTC_WRAPPER sccache

~/.nix-profile/bin/shadowenv init fish | source

# television fish integration is using the shared version instead of the version after custimization
#source /nix/store/0vxxc4ifpdk28hiakxagnnfzs2hihkki-television-0.15.0/share/television/completion.fish
source ~/.config/fish/completions/television-completion.fish
alias update-television-completion "tv init fish > ~/.flakes/modules/fish/completions/television-completion.fish"

