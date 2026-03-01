function fish_title
    if not set -q KITTY_WINDOW_ID
        return
    end
    if test $PWD = $HOME
        echo "~"
    else
        basename $PWD
    end
end
