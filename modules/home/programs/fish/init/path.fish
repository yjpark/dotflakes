if test -d ~/.nix/bin/common
    set -x PATH ~/.nix/bin/common $PATH
end

if test -d ~/.nix.private/bin/common
    set -x PATH ~/.nix.private/bin/common $PATH
end

uname -v | grep NixOS > /dev/null
if [ $status -eq 0 ]
    if test -d ~/.nix/bin/nixos
        set -x PATH ~/.nix/bin/nixos $PATH
    end
    if test -d ~/.nix.private/bin/nixos
        set -x PATH ~/.nix.private/bin/nixos $PATH
    end
end

uname -v | grep Darwin > /dev/null
if [ $status -eq 0 ]
    set -x PATH ~/.nix-profile/bin $PATH
end

uname -v | grep Ubuntu > /dev/null
if [ $status -eq 0 ]
    set -x PATH ~/.nix-profile/bin $PATH
    if test -d ~/.nix/bin/ubuntu
        set -x PATH ~/.nix/bin/ubuntu $PATH
    end
    if test -d ~/.nix.private/bin/ubuntu
        set -x PATH ~/.nix.private/bin/ubuntu $PATH
    end
end

uname -a | grep amzn > /dev/null
if [ $status -eq 0 ]
    set -x PATH ~/.nix-profile/bin $PATH
    set -x PATH /nix/var/nix/profiles/default/bin $PATH
end

uname | grep Linux > /dev/null
if [ $status -eq 0 ]
    if test -d ~/.nix/bin/linux
        set -x PATH ~/.nix/bin/linux $PATH
    end
    if test -d ~/.nix.private/bin/linux
        set -x PATH ~/.nix.private/bin/linux $PATH
    end
end

if test -d ~/.cargo/bin
    set -x PATH ~/.cargo/bin $PATH
end

if test -d ~/.npm/bin
    set -x PATH ~/.npm/bin $PATH
end

if test -d ~/.dotnet/tools
    set -x PATH ~/.dotnet/tools $PATH
end

if test -d ~/.krew/bin
    set -x PATH ~/.krew/bin $PATH
end

if test -d ~/bin
    set -x PATH ~/bin $PATH
end

if test -d ~/bin/host
    set -x PATH ~/bin/host $PATH
end
