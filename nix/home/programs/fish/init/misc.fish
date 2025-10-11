set -x EDITOR nvim

set -x fish_greeting ""

set -x FLOX_SHELL fish
set -x FLOX_PROMPT_DISABLE 1

shadowenv init fish | source
