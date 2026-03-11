if test -d ~/.cargo/bin
    set -x PATH ~/.cargo/bin $PATH
end

if test -d ~/.npm/bin
    set -x PATH ~/.npm/bin $PATH
end

if test -d ~/.dotnet/tools
    set -x PATH ~/.dotnet/tools $PATH
end

if test -d ~/.local/bin
    set -x PATH ~/.local/bin $PATH
end

uname -v | grep NixOS > /dev/null
if [ $status -eq 0 ]
    if test -d ~/.local/bin/nixos
        set -x PATH ~/.local/bin/nixos $PATH
    end
end

if test -L ~/.local/bin/private
    set -x PATH ~/.local/bin/private $PATH
    if test -f ~/.local/bin/private/.secret.init.fish
      source ~/.local/bin/private/.secret.init.fish
    end
end


