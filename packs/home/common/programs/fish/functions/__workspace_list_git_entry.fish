# Helper for workspace-list: format and print a single git worktree entry
# Args: wt_path wt_head wt_branch repo_path
set -l wt_path $argv[1]
set -l wt_head $argv[2]
set -l wt_branch $argv[3]
set -l repo_path $argv[4]

# Determine workspace name
set -l ws_name
if test "$wt_path" = "$repo_path"
    set ws_name "default"
else
    set ws_name (basename "$wt_path")
end

# Format branch
set -l branch_display
if test -z "$wt_branch"
    set branch_display (set_color brblack)"(detached)"(set_color normal)
else
    set branch_display (set_color green)"$wt_branch"(set_color normal)
end

# Short hash
set -l short_head (string sub -l 7 "$wt_head")

# Status: check if worktree is clean or dirty
set -l ws_status
if test -d "$wt_path"
    set -l diff_output (git -C "$wt_path" status --porcelain 2>/dev/null)
    if test -z "$diff_output"
        set ws_status (set_color brblack)"clean"(set_color normal)
    else
        set ws_status (set_color yellow)"dirty"(set_color normal)
    end
else
    set ws_status (set_color red)"missing"(set_color normal)
end

printf "  %-14s %s  %s  %s\n" "$ws_name" "$branch_display" (set_color brblue)"$short_head"(set_color normal) "$ws_status"
