# 这行代码的作用是检查当前 Bash 是否处于交互模式。
# 如果不是交互模式，则直接退出脚本
[[ $- != *i* ]] && return

set -o vi

alias e='eza'
alias v='nvim'
alias s='source'
alias cls='clear'
alias cdh='cd ~/'
alias rmd='rm -rf'
alias mkd='mkdir -p'
alias way='waybar > /dev/null 2>&1 &'
alias reway='killall waybar && waybar > /dev/null 2>&1 &'

# 设置提示符
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
. "$HOME/.cargo/env"

# 启用 Fzf 的 Bash 集成
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

# 设置 Fzf 的默认搜索命令，使用 fd 替代 find
export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'

# 设置 Fzf 的默认选项
export FZF_DEFAULT_OPTS="--height 40% --reverse --border --color=auto"

# 设置 Zoxide 使用 Fzf 时的选项
export _ZO_FZF_OPTS="--height 40% --reverse --border"

# 初始化 Zoxide
export PATH="$HOME/.app:$PATH"
# zoxide 初始化 要放在所有路径之后*****
eval "$(zoxide init bash)"
