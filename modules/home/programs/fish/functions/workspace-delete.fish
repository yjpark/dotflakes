if test (count $argv) -eq 0
    echo "Usage: workspace-delete <project>/<workspace>"
    return 1
end

set -l target $argv[1]
set -l parts (string split '/' "$target")

if test (count $parts) -ne 2
    echo "Usage: workspace-delete <project>/<workspace>"
    return 1
end

set -l project $parts[1]
set -l ws_name $parts[2]

if test "$ws_name" = default
    echo "Cannot delete the default workspace."
    return 1
end

set -l conf "$HOME/workspaces/.config.conf"
if not test -f "$conf"
    echo "No projects registered."
    return 1
end

# Find repo path
set -l repo_path
while read -l line
    test -z "$line"; and continue
    string match -q '#*' "$line"; and continue
    set -l kv (string split '=' "$line")
    if test "$kv[1]" = "$project"
        set repo_path "$kv[2]"
        break
    end
end <"$conf"

if test -z "$repo_path"
    echo "Unknown project: $project"
    return 1
end

set -l ws_path "$HOME/workspaces/$project/$ws_name"

# Detect VCS and delete accordingly
if test -d "$repo_path/.jj"
    # jj workspace
    jj workspace forget "$ws_name" -R "$repo_path"
    if test $status -ne 0
        echo "Failed to forget jj workspace."
        return 1
    end

    if test -d "$ws_path"
        rm -rf "$ws_path"
        echo "Removed: $ws_path"
    end
else
    # git worktree
    if test -d "$ws_path"
        git -C "$repo_path" worktree remove "$ws_path"
        if test $status -ne 0
            echo "Failed to remove git worktree."
            return 1
        end
    else
        echo "Workspace directory not found: $ws_path"
        return 1
    end
end

echo "Deleted workspace: $project/$ws_name"
