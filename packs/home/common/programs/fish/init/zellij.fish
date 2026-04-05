# Resolve project name: git repo root basename, fallback to basename of PWD
function zellij_project_name
    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$toplevel"
        basename $toplevel
    else
        basename $PWD
    end
end

# Get unique project names in visual order from the focused tab's layout.
# Parses pane names (set by zellij_update_panename as "<project> ...") from
# dump-layout, which lists panes in their visual position order.
function zellij_visual_projects
    zellij action dump-layout 2>/dev/null \
        | sed -n '/tab .*focus=true/,/^    }/p' \
        | string match -rg 'name="<([^>]+)>' \
        | awk '!seen[$0]++'
end

# Palette of subtle Tokyo Night-adjacent background tints (base: #1a1b26)
set -g ZELLIJ_PANE_COLORS \
    '#261a1e' \
    '#1a2620' \
    '#1a1e2e' \
    '#26241a' \
    '#241a26' \
    '#1a2426' \
    '#26201a' \
    '#1a2624'

# Simple string hash → palette index (deterministic per project name)
function zellij_project_color_index
    set -l name "$argv[1]"
    set -l palette_size (count $ZELLIJ_PANE_COLORS)
    set -l hash 0
    for i in (string split '' "$name")
        set -l ord (printf '%d' "'$i")
        set hash (math --scale=0 "($hash * 31 + $ord) % 1000000007")
    end
    math --scale=0 (math --scale=0 "abs($hash)") % $palette_size
end

# Set pane background color based on project
function zellij_update_pane_color
    if set -q ZELLIJ
        set -l project (zellij_project_name)
        set -l idx (zellij_project_color_index "$project")
        set -l color_idx (math --scale=0 "$idx + 1")
        set -l color $ZELLIJ_PANE_COLORS[$color_idx]
        nohup zellij action set-pane-color --bg "$color" >/dev/null 2>&1
    end
end

function zellij_update_tabname
    if set -q ZELLIJ
        set -l projects (zellij_visual_projects)
        set -l tab_name
        if test (count $projects) -le 1
            # Single project or empty — use project name or cwd
            if test $PWD = $HOME
                set tab_name "~"
            else
                set tab_name (zellij_project_name)
            end
        else
            # Multiple projects — join with " | "
            set tab_name (string join " | " $projects)
        end
        nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
    end
end

function zellij_update_panename
    if set -q ZELLIJ
        set -l project (zellij_project_name)
        if test -n "$argv"
            nohup zellij action rename-pane "<$project> $argv" >/dev/null 2>&1
        else
            nohup zellij action rename-pane "<$project>" >/dev/null 2>&1
        end
    end
end

# Resolve layout file for the current project root.
# Priority: .zellij-layout.kdl in project root > ZELLIJ_LAYOUT_{USER} > ZELLIJ_LAYOUT
function zellij_resolve_layout
    set -l project_root "$argv[1]"

    # 1. Inline layout in project root
    if test -f "$project_root/.zellij-layout.kdl"
        echo "$project_root/.zellij-layout.kdl"
        return 0
    end

    # 2. User-specific preset (e.g., ZELLIJ_LAYOUT_yj)
    set -l user_var "ZELLIJ_LAYOUT_$USER"
    if set -q $user_var
        set -l preset_name $$user_var
        set -l preset_file "$HOME/.config/zellij/layouts/$preset_name.kdl"
        if test -f "$preset_file"
            echo "$preset_file"
            return 0
        end
    end

    # 3. Generic preset
    if set -q ZELLIJ_LAYOUT
        set -l preset_file "$HOME/.config/zellij/layouts/$ZELLIJ_LAYOUT.kdl"
        if test -f "$preset_file"
            echo "$preset_file"
            return 0
        end
    end

    return 1
end

# Apply project layout to the current Zellij tab.
function zellij_apply_layout
    set -l project_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$project_root"
        set project_root $PWD
    end

    set -l layout_file (zellij_resolve_layout "$project_root")
    if test -z "$layout_file"
        echo "No layout found for $project_root"
        return 1
    end

    zellij action override-layout "$layout_file" --apply-only-to-active-tab
    zellij action clear
end

# ct: switch to claude_terminal layout
function ct
    set -gx ZELLIJ_LAYOUT_$USER claude_terminal
    zellij_apply_layout
end

# cc: switch to claude_claude layout
function cc
    set -gx ZELLIJ_LAYOUT_$USER claude_claude
    zellij_apply_layout
end

# zz: inside Zellij → apply project layout; outside → attach/create session
function zz
    if set -q ZELLIJ
        zellij_apply_layout
    else
        zellij attach --create (basename $PWD)
    end
end

# On directory change: rename pane first (so dump-layout sees it), then update tab name
function zellij_update_on_pwd --on-variable PWD
    if set -q ZELLIJ
        zellij_update_panename
        zellij_update_pane_color
        zellij_update_tabname
    end
end

# On command execution: only update pane name
function zellij_update_on_preexec --on-event fish_preexec
    zellij_update_panename "$argv"
end

function zellij_cleanup --on-event fish_exit
    if set -q ZELLIJ
        zellij_update_tabname
    end
end

# --- Initialization ---
if set -q ZELLIJ
    # Rename pane first so dump-layout reflects it when computing tab name
    zellij_update_panename
    zellij_update_pane_color
    zellij_update_tabname
end
