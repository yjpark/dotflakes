# Resolve project name: git repo root basename, fallback to basename of PWD
function zellij_project_name
    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$toplevel"
        basename $toplevel
    else
        basename $PWD
    end
end

# Get the current tab's stable ID from Zellij
function zellij_tab_id
    zellij action current-tab-info --json 2>/dev/null | string match -rg '"tab_id":\s*(\d+)'
end

# State directory: /tmp/zellij-tabs-$SESSION/$TAB_ID/$PANE_ID
# Each pane owns its own file — no concurrent writes to shared files.
function zellij_state_dir
    echo "/tmp/zellij-tabs-$ZELLIJ_SESSION_NAME"
end

# Write this pane's project to its own state file under the current tab
function zellij_state_write
    set -l tab_id (zellij_tab_id)
    if test -z "$tab_id"; return; end
    set -l state_dir (zellij_state_dir)
    # If tab changed (pane was moved), remove old pane file
    if test -n "$ZELLIJ_CURRENT_TAB_ID" -a "$ZELLIJ_CURRENT_TAB_ID" != "$tab_id"
        rm -f "$state_dir/$ZELLIJ_CURRENT_TAB_ID/$ZELLIJ_PANE_ID"
        rmdir "$state_dir/$ZELLIJ_CURRENT_TAB_ID" 2>/dev/null
    end
    mkdir -p "$state_dir/$tab_id"
    zellij_project_name >"$state_dir/$tab_id/$ZELLIJ_PANE_ID"
    set -g ZELLIJ_CURRENT_TAB_ID $tab_id
end

# Remove this pane's state file on exit
function zellij_state_remove
    set -l state_dir (zellij_state_dir)
    if test -n "$ZELLIJ_CURRENT_TAB_ID"
        rm -f "$state_dir/$ZELLIJ_CURRENT_TAB_ID/$ZELLIJ_PANE_ID"
        rmdir "$state_dir/$ZELLIJ_CURRENT_TAB_ID" 2>/dev/null
    end
end

# Read unique project names from the current tab (sorted by pane ID for stable order)
function zellij_state_projects
    set -l tab_id (zellij_tab_id)
    if test -z "$tab_id"; return; end
    set -l tab_dir (zellij_state_dir)"/$tab_id"
    if test -d "$tab_dir"
        for f in (ls "$tab_dir" | sort -n)
            cat "$tab_dir/$f"
        end | awk '!seen[$0]++'
    end
end

# Clean up stale tab directories that no longer correspond to open tabs
function zellij_state_cleanup
    set -l state_dir (zellij_state_dir)
    if not test -d "$state_dir"; return; end
    set -l valid_ids (zellij action list-tabs --json 2>/dev/null | string match -rga '"tab_id":\s*(\d+)')
    if test (count $valid_ids) -eq 0; return; end
    for tab_dir in "$state_dir"/*/
        set -l dir_id (basename "$tab_dir")
        if not contains "$dir_id" $valid_ids
            rm -rf "$tab_dir"
        end
    end
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
    set -l hash 0
    for i in (string split '' "$name")
        set -l ord (printf '%d' "'$i")
        set hash (math "$hash * 31 + $ord")
    end
    set -l palette_size (count $ZELLIJ_PANE_COLORS)
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
        set -l projects (zellij_state_projects)
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

# On directory change: update state, tab name, pane name, and color
function zellij_update_tabname_pwd --on-variable PWD
    if set -q ZELLIJ
        zellij_state_write
        zellij_update_tabname
        zellij_update_panename
        zellij_update_pane_color
    end
end

# On command execution: only update pane name (no shared state I/O)
function zellij_update_panename_cmd --on-event fish_preexec
    zellij_update_panename "$argv"
end

function zellij_cleanup --on-event fish_exit
    if set -q ZELLIJ
        zellij_state_remove
        zellij_update_tabname
    end
end

# --- Initialization ---
if set -q ZELLIJ
    # Clean up stale state from closed tabs or previous sessions
    zellij_state_cleanup

    # Register this pane and update names (also sets ZELLIJ_CURRENT_TAB_ID)
    zellij_state_write
    zellij_update_tabname
    zellij_update_panename
    zellij_update_pane_color
end
