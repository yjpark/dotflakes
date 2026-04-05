if test (count $argv) -eq 0
    return 0
end

set -l target $argv[1]
set -l parts (string split '/' "$target")

if test (count $parts) -ne 2
    echo "Usage: w <project>/<workspace>"
    return 1
end

set -l project $parts[1]
set -l ws_name $parts[2]
set -l conf "$HOME/workspaces/.config.conf"

if not test -f "$conf"
    echo "No projects registered. Use wc to create a workspace first."
    return 1
end

# Find repo path for project
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

# Determine target directory
set -l ws_path
if test "$ws_name" = default
    set ws_path "$repo_path"
else
    set ws_path "$HOME/workspaces/$project/$ws_name"
end

if not test -d "$ws_path"
    echo "Workspace directory not found: $ws_path"
    return 1
end

cd "$ws_path"

# Detect VCS and show brief status
if test -d "$repo_path/.jj"
    # jj status
    set -l jj_template 'self.change_id().shortest(8) ++ "\t" ++ self.local_bookmarks().map(|b| b.name()).join(",") ++ "\t" ++ if(self.conflict(), "conflicts", if(self.empty(), "clean", "dirty"))'
    set -l info (jj log -r @ --no-graph -T "$jj_template" 2>/dev/null)
    if test -n "$info"
        set -l fields (string split \t "$info")
        set -l change_id $fields[1]
        set -l bookmarks $fields[2]
        set -l ws_status $fields[3]

        if test -z "$bookmarks"
            set bookmarks (set_color brblack)"(no bookmark)"(set_color normal)
        else
            set bookmarks (set_color green)"$bookmarks"(set_color normal)
        end

        switch $ws_status
            case clean
                set ws_status (set_color brblack)"clean"(set_color normal)
            case dirty
                set ws_status (set_color yellow)"dirty"(set_color normal)
            case conflicts
                set ws_status (set_color red)"conflicts"(set_color normal)
        end

        echo "$bookmarks  "(set_color brblue)"@$change_id"(set_color normal)"  $ws_status"
    end
else
    # git status
    set -l branch (git -C "$ws_path" branch --show-current 2>/dev/null)
    set -l short_hash (git -C "$ws_path" rev-parse --short HEAD 2>/dev/null)

    if test -z "$branch"
        set branch (set_color brblack)"(detached)"(set_color normal)
    else
        set branch (set_color green)"$branch"(set_color normal)
    end

    set -l ws_status
    set -l diff_output (git -C "$ws_path" status --porcelain 2>/dev/null)
    if test -z "$diff_output"
        set ws_status (set_color brblack)"clean"(set_color normal)
    else
        set ws_status (set_color yellow)"dirty"(set_color normal)
    end

    echo "$branch  "(set_color brblue)"$short_hash"(set_color normal)"  $ws_status"
end
