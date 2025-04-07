function o
    set -l search_pattern (if set -q argv[1]; echo $argv[1]; else; echo .; end)
    set -l search_path (if set -q argv[2]; echo $argv[2]; else; echo $HOME; end)

    if not test -d "$search_path"
        echo "Error: '$search_path' is not a valid directory" >&2
        return 1
    end

    set -l file (
        fd --hidden --ignore-file ~/bash/.fdignore --type f "$search_pattern" "$search_path" \
        | fzf --height 60% --reverse \
            --preview-window right:50%:wrap \
            --preview 'bat --color=always --line-range :500 {}' \
            --bind "enter:accept" \
            --exit-0
    )

    if test -n "$file"
        nvim "$file"
    else
        echo "󰅖 Cancelled"
    end
end
