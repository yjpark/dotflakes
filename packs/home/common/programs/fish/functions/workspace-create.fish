if test (count $argv) -eq 0
    echo "Usage: wc <feature-name>"
    return 1
end

set -l feature $argv[1]

# Detect VCS: jj takes priority over git
set -l repo_root
set -l vcs
set repo_root (jj root 2>/dev/null)
if test -n "$repo_root"
    set vcs jj
else
    set repo_root (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | string replace -r '/\.git$' '')
    if test -n "$repo_root"
        set vcs git
    else
        echo "Not inside a jj or git repository."
        return 1
    end
end

set -l project (basename "$repo_root")
set -l ws_path "$HOME/workspaces/$project/$feature"

if test -d "$ws_path"
    echo "Workspace already exists: $ws_path"
    return 1
end

# Register project in config if needed
set -l conf "$HOME/workspaces/.config.conf"
if not test -f "$conf"
    mkdir -p (dirname "$conf")
    touch "$conf"
end

if not grep -q "^$project=" "$conf" 2>/dev/null
    echo "$project=$repo_root" >>"$conf"
    echo "Registered project: $project → $repo_root"
end

# Create workspace
mkdir -p (dirname "$ws_path")

switch $vcs
    case jj
        jj workspace add "$ws_path" --name "$feature"
        if test $status -ne 0
            echo "Failed to create jj workspace."
            return 1
        end
    case git
        # Try creating a new branch; if it already exists, use the existing one
        git -C "$repo_root" worktree add "$ws_path" -b "$feature" 2>/dev/null
        or git -C "$repo_root" worktree add "$ws_path" "$feature"
        if test $status -ne 0
            echo "Failed to create git worktree."
            return 1
        end
end

cd "$ws_path"
echo "Created workspace ($vcs): $project/$feature"
