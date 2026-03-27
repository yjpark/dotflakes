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

# State directory and file path for tracking pane→project mappings per tab
function zellij_state_dir
    echo "/tmp/zellij-tabs-$ZELLIJ_SESSION_NAME"
end

function zellij_state_file
    echo (zellij_state_dir)"/$argv[1]"
end

# Write this pane's project to the current tab's state file
function zellij_state_write
    set -l tab_id (zellij_tab_id)
    if test -z "$tab_id"; return; end
    # Remove this pane from ALL tabs first (handles pane moves between tabs)
    zellij_state_remove
    set -l state_dir (zellij_state_dir)
    mkdir -p "$state_dir"
    set -l state_file (zellij_state_file $tab_id)
    set -l project (zellij_project_name)
    echo "$ZELLIJ_PANE_ID=$project" >>"$state_file"
    set -g ZELLIJ_CURRENT_TAB_ID $tab_id
end

# Remove this pane's entry from all tab state files in this session
function zellij_state_remove
    set -l state_dir (zellij_state_dir)
    if test -d "$state_dir"
        for state_file in "$state_dir"/*
            if test -f "$state_file"
                grep -v "^$ZELLIJ_PANE_ID=" "$state_file" >"$state_file.tmp" 2>/dev/null
                mv "$state_file.tmp" "$state_file"
            end
        end
    end
end

# Read unique project names from the current tab's state file
function zellij_state_projects
    set -l tab_id (zellij_tab_id)
    if test -z "$tab_id"; return; end
    set -l state_file (zellij_state_file $tab_id)
    if test -f "$state_file"
        cut -d= -f2 "$state_file" | awk '!seen[$0]++'
    end
end

# Clean up stale tab state files that no longer correspond to open tabs
function zellij_state_cleanup
    set -l state_dir (zellij_state_dir)
    if not test -d "$state_dir"; return; end
    # Get valid tab IDs from Zellij
    set -l valid_ids (zellij action list-tabs --json 2>/dev/null | string match -rga '"tab_id":\s*(\d+)')
    if test (count $valid_ids) -eq 0; return; end
    for state_file in "$state_dir"/*
        if test -f "$state_file"
            set -l file_id (basename "$state_file")
            if not contains "$file_id" $valid_ids
                rm -f "$state_file"
            end
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

# Compute tab name from a state file's projects
function zellij_tabname_for_state_file
    set -l state_file "$argv[1]"
    if test -f "$state_file"
        set -l projects (cut -d= -f2 "$state_file" | awk '!seen[$0]++')
        if test (count $projects) -gt 1
            string join " | " $projects
            return
        else if test (count $projects) -eq 1
            echo $projects[1]
            return
        end
    end
end

# Detect pane moves between tabs on each prompt
function zellij_check_tab --on-event fish_prompt
    if set -q ZELLIJ
        set -l tab_id (zellij_tab_id)
        if test -n "$tab_id" -a "$tab_id" != "$ZELLIJ_CURRENT_TAB_ID"
            set -l old_tab_id $ZELLIJ_CURRENT_TAB_ID
            # Re-register in new tab (also updates ZELLIJ_CURRENT_TAB_ID)
            zellij_state_write
            zellij_update_tabname
            # Update the source tab's name after removing this pane
            if test -n "$old_tab_id"
                set -l old_name (zellij_tabname_for_state_file (zellij_state_file $old_tab_id))
                if test -n "$old_name"
                    nohup zellij action rename-tab-by-id $old_tab_id "$old_name" >/dev/null 2>&1
                end
            end
        end
    end
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

    # Clean up stale state files from closed tabs or previous sessions
    zellij_state_cleanup

    # Register this pane and update names (also sets ZELLIJ_CURRENT_TAB_ID)
    # Note: stale entries from crashed panes are naturally overwritten when
    # pane IDs are reused. Normal cleanup happens via fish_exit.
    zellij_state_write
    zellij_update_tabname
    zellij_update_panename
    zellij_update_pane_color
end
