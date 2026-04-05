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


