# ========== FZF 集成 ==========
fzf --fish | source

# ========== Direnv ==========
# direnv hook fish | source

# ========== Zoxide ==========
set -gx _ZO_MAXAGE 5000
zoxide init fish | source

# ========== Starship 提示符 ==========
starship init fish | source

# ========== 其他工具 ==========
