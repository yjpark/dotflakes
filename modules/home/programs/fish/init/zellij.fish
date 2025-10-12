function zellij_update_tabname
    if set -q ZELLIJ
        set current_dir $PWD
        if test $current_dir = $HOME
            set current_dir "~"
        else
            set current_dir (basename $current_dir)
        end
        nohup zellij action rename-tab "$current_dir" >/dev/null 2>&1
    end
end

function zellij_update_panename
    if set -q ZELLIJ
        nohup zellij action rename-pane "$argv" >/dev/null 2>&1
    end
end

function zellij_update_tabname_pwd --on-variable PWD
    zellij_update_tabname
end

function zellij_update_panename_cmd --on-event fish_preexec
    zellij_update_panename "$argv"
end

zellij_update_tabname
zellij_update_panename
