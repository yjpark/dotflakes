# Generate completions from workspaces.conf + jj/git workspace list
function __workspace_completions
    set -l conf "$HOME/workspaces/.config.conf"
    test -f "$conf"; or return

    while read -l line
        test -z "$line"; and continue
        string match -q '#*' "$line"; and continue

        set -l parts (string split '=' "$line")
        set -l project $parts[1]
        set -l repo_path $parts[2]

        test -d "$repo_path"; or continue

        if test -d "$repo_path/.jj"
            # jj workspaces
            for ws_name in (jj workspace list -R "$repo_path" -T 'self.name() ++ "\n"' 2>/dev/null)
                test -z "$ws_name"; and continue
                echo "$project/$ws_name"
            end
        else if test -d "$repo_path/.git"; or test -f "$repo_path/.git"
            # git worktrees
            echo "$project/default"
            for wt_line in (git -C "$repo_path" worktree list --porcelain 2>/dev/null)
                if string match -q "worktree *" "$wt_line"
                    set -l wt_path (string replace "worktree " "" "$wt_line")
                    if test "$wt_path" != "$repo_path"
                        echo "$project/"(basename "$wt_path")
                    end
                end
            end
        end
    end <"$conf"
end

complete -c workspace-cd -f -a '(__workspace_completions)'
