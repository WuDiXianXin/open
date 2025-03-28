#!/usr/bin/env bash

j() {
  local dir
  local search_pattern="${1:-.}"
  local search_path="${2:-$HOME}"

  if [[ ! -d "$search_path" ]]; then
    echo "Error: '$search_path' is not a valid directory" >&2
    return 1
  fi

  dir=$(
    fdd --ignore-file ~/bash/.fdignore "$search_pattern" "$search_path" |
      fzf --height 60% --reverse \
        --preview-window right:50%:wrap \
        --preview "eza --color=always --icons --group-directories-first --git-ignore --tree --level=2 -a {}" \
        --bind "enter:accept" \
        --exit-0
  )

  [[ -n "$dir" ]] && cd "$dir" || echo "󰅖 Cancelled"
}
