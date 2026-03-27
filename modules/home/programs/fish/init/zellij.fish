# Resolve project name: git repo root basename, fallback to basename of PWD
function zellij_project_name
    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$toplevel"
        basename $toplevel
    else
        basename $PWD
    end
end

# State file path for tracking pane→project mappings in this session
function zellij_state_file
    echo "/tmp/zellij-tab-$ZELLIJ_SESSION_NAME"
end

# Write this pane's project to the state file
function zellij_state_write
    set -l state_file (zellij_state_file)
    set -l project (zellij_project_name)
    # Remove existing entry for this pane, then append
    if test -f "$state_file"
        grep -v "^$ZELLIJ_PANE_ID=" "$state_file" >"$state_file.tmp" 2>/dev/null
        mv "$state_file.tmp" "$state_file"
    end
    echo "$ZELLIJ_PANE_ID=$project" >>"$state_file"
end

# Remove this pane's entry from the state file
function zellij_state_remove
    set -l state_file (zellij_state_file)
    if test -f "$state_file"
        grep -v "^$ZELLIJ_PANE_ID=" "$state_file" >"$state_file.tmp" 2>/dev/null
        mv "$state_file.tmp" "$state_file"
    end
end

# Read unique project names from state file
function zellij_state_projects
    set -l state_file (zellij_state_file)
    if test -f "$state_file"
        # Extract project names, deduplicate while preserving pane order
        cut -d= -f2 "$state_file" | awk '!seen[$0]++'
    end
end

# Palette of subtle Gruvbox-adjacent background tints
set -g ZELLIJ_PANE_COLORS \
    '#2e1a1a' \
    '#1a2e1a' \
    '#1a1a2e' \
    '#2e2e1a' \
    '#2e1a2e' \
    '#1a2e2e' \
    '#2e241a' \
    '#1a2e24'

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
        if test "$project" != "$ZELLIJ_SESSION_PROJECT"
            set -l idx (zellij_project_color_index "$project")
            set -l color_idx (math --scale=0 "$idx + 1")
            set -l color $ZELLIJ_PANE_COLORS[$color_idx]
            nohup zellij action set-pane-color --bg "$color" >/dev/null 2>&1
        else
            nohup zellij action set-pane-color --reset >/dev/null 2>&1
        end
    end
end

function zellij_update_tabname
    if set -q ZELLIJ
        set -l projects (zellij_state_projects)
        if test (count $projects) -le 1
            # Single project or empty — use project name or cwd
            set -l current_dir $PWD
            if test $current_dir = $HOME
                set current_dir "~"
            else
                set current_dir (zellij_project_name)
            end
            nohup zellij action rename-tab "$current_dir" >/dev/null 2>&1
        else
            # Multiple projects — join with " | "
            set -l tab_name (string join " | " $projects)
            nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
        end
    end
end

function zellij_update_panename
    if set -q ZELLIJ
        set -l project (zellij_project_name)
        if test "$project" != "$ZELLIJ_SESSION_PROJECT"
            if test -n "$argv"
                nohup zellij action rename-pane "<$project> $argv" >/dev/null 2>&1
            else
                nohup zellij action rename-pane "<$project>" >/dev/null 2>&1
            end
        else
            nohup zellij action rename-pane "$argv" >/dev/null 2>&1
        end
    end
end

function zellij_update_tabname_pwd --on-variable PWD
    if set -q ZELLIJ
        zellij_state_write
        zellij_update_tabname
        # Update pane name and color on directory change
        zellij_update_panename
        zellij_update_pane_color
    end
end

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
    # Capture session's home project (only set once per pane)
    if not set -q ZELLIJ_SESSION_PROJECT
        set -gx ZELLIJ_SESSION_PROJECT (zellij_project_name)
    end

    # Register this pane and update names
    # Note: stale entries from crashed panes are naturally overwritten when
    # pane IDs are reused. Normal cleanup happens via fish_exit.
    zellij_state_write
    zellij_update_tabname
    zellij_update_panename
    zellij_update_pane_color
end
