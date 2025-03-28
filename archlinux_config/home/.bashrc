#!/usr/bin/env bash
# ========== 基础设置 ==========
if [[ -n "${BASHRC_LOADED}" ]]; then
  return
fi
export BASHRC_LOADED=1
[[ $- != *i* ]] && return
BASH_LOAD_START=$(date +%s%3N)
# ========== 历史记录增强 ==========
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend cmdhist lithist
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# ========== 路径管理 ==========
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# ========== 工具集成 ==========
source /usr/share/bash-completion/bash_completion
source ~/make/ble.sh/out/ble.sh
source /usr/share/fzf/{key-bindings,completion}.bash
eval "$(direnv hook bash)"
eval "$(starship init bash)"
source "$HOME/bash/j.bash"
source "$HOME/bash/o.bash"
export _ZO_MAXAGE=5000
eval "$(zoxide init bash)"
# ========== Vi 模式与输入优化 ==========
set -o vi
# ========== 别名与函数 ==========
alias e='eza --icons --group-directories-first --git'
alias et='e --tree --level=2 --git-ignore'
alias eal='e -a -l'
alias v='nvim'
alias s='source'
alias cls='clear'
alias mkd='mkdir -p'
alias fdf='fd -H -t f'
alias fdd='fd -H -t d'
alias way='waybar > /dev/null 2>&1 &'
alias reway='killall waybar && waybar > /dev/null 2>&1 &'
rm() {
  echo -e "\033[31m[安全提示]\033[0m 请优先使用：\n" \
    "  \033[32mrmd\033[0m   # 安全删除到回收站\n" \
    "  \033[31mrmy\033[0m   # 强制原生删除（危险）" >&2
  return 1
}
alias rmd='trash-put'
alias rmy='command rm -f'
alias tbash_time='time bash -i -c exit'
complete -F _minimal rmd
complete -F _minimal rmy
complete -F _minimal tbash_time
# ========== 性能监控 ==========
BASH_LOAD_END=$(date +%s%3N)
echo -e "\033[34m[bashrc]\033[0m 加载耗时: $((BASH_LOAD_END - BASH_LOAD_START))ms"
