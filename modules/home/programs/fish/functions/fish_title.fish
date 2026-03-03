function fish_title
    if test $PWD = $HOME
        echo "~"
    else
        basename $PWD
    end
end
