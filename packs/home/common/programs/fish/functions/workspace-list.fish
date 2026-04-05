set -l conf "$HOME/workspaces/.config.conf"
if not test -f "$conf"
    echo "No projects registered. Use wc to create a workspace first."
    return 1
end

set -l jj_template 'self.name() ++ "\t" ++ self.target().change_id().shortest(8) ++ "\t" ++ self.target().local_bookmarks().map(|b| b.name()).join(",") ++ "\t" ++ if(self.target().conflict(), "conflicts", if(self.target().empty(), "clean", "dirty")) ++ "\n"'

while read -l line
    # Skip empty lines and comments
    test -z "$line"; and continue
    string match -q '#*' "$line"; and continue

    set -l parts (string split '=' "$line")
    set -l project $parts[1]
    set -l repo_path $parts[2]

    if not test -d "$repo_path"
        echo (set_color yellow)"$project"(set_color normal)" (repo not found: $repo_path)"
        continue
    end

    # Detect VCS type
    set -l vcs
    if test -d "$repo_path/.jj"
        set vcs jj
    else if test -d "$repo_path/.git"; or test -f "$repo_path/.git"
        set vcs git
    else
        echo (set_color yellow)"$project"(set_color normal)" (not a jj or git repo)"
        continue
    end

    echo (set_color --bold cyan)"$project/"(set_color normal)" "(set_color brblack)"($vcs)"(set_color normal)

    switch $vcs
        case jj
            set -l ws_lines (jj workspace list -R "$repo_path" -T "$jj_template" 2>/dev/null)
            for ws_line in $ws_lines
                test -z "$ws_line"; and continue
                set -l fields (string split \t "$ws_line")
                set -l ws_name $fields[1]
                set -l change_id $fields[2]
                set -l bookmarks $fields[3]
                set -l ws_status $fields[4]

                # Format bookmark
                if test -z "$bookmarks"
                    set bookmarks (set_color brblack)"(no bookmark)"(set_color normal)
                else
                    set bookmarks (set_color green)"$bookmarks"(set_color normal)
                end

                # Format status
                switch $ws_status
                    case clean
                        set ws_status (set_color brblack)"clean"(set_color normal)
                    case dirty
                        set ws_status (set_color yellow)"dirty"(set_color normal)
                    case conflicts
                        set ws_status (set_color red)"conflicts"(set_color normal)
                end

                printf "  %-14s %s  %s  %s\n" "$ws_name" "$bookmarks" (set_color brblue)"@$change_id"(set_color normal) "$ws_status"
            end

        case git
            set -l wt_lines (git -C "$repo_path" worktree list --porcelain 2>/dev/null)
            set -l wt_path ""
            set -l wt_head ""
            set -l wt_branch ""

            for wt_line in $wt_lines
                if string match -q "worktree *" "$wt_line"
                    # Emit previous worktree if we have one
                    if test -n "$wt_path"
                        __workspace_list_git_entry "$wt_path" "$wt_head" "$wt_branch" "$repo_path"
                    end
                    set wt_path (string replace "worktree " "" "$wt_line")
                    set wt_head ""
                    set wt_branch ""
                else if string match -q "HEAD *" "$wt_line"
                    set wt_head (string replace "HEAD " "" "$wt_line")
                else if string match -q "branch *" "$wt_line"
                    set wt_branch (string replace "branch refs/heads/" "" "$wt_line")
                end
            end
            # Emit last worktree
            if test -n "$wt_path"
                __workspace_list_git_entry "$wt_path" "$wt_head" "$wt_branch" "$repo_path"
            end
    end
end <"$conf"
