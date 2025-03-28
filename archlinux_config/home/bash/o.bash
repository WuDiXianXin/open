#!/usr/bin/env bash

o() {
  local file
  local search_pattern="${1:-.}"
  local search_path="${2:-$HOME}"

  if [[ ! -d "$search_path" ]]; then
    echo "Error: '$search_path' is not a valid directory" >&2
    return 1
  fi

  file=$(
    fdf --ignore-file ~/bash/.fdignore "$search_pattern" "$search_path" |
      fzf --height 60% --reverse \
        --preview-window right:50%:wrap \
        --preview 'bat --color=always --line-range :500 {}' \
        --bind "enter:accept" \
        --exit-0
  )

  [[ -n "$file" ]] && nvim "$file" || echo "󰅖 Cancelled"
}
