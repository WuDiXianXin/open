if status is-interactive
    # Commands to run in interactive sessions can go here
    # ========== 基础设置 ==========
    set -g fish_greeting '' # 禁用欢迎语
    # ========== Vi 模式 ==========
    fish_vi_key_bindings
    set -g fish_cursor_insert line
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    bind --mode insert \ce fish_edit_commandline
    bind --mode default v fish_edit_commandline
    # ========== 路径管理 ==========
    # 加载 Cargo 环境
    set -q CARGO_HOME || set CARGO_HOME $HOME/.cargo
    fish_add_path $CARGO_HOME/bin
    alias e="eza --icons --group-directories-first --git"
    alias et="e --tree --level=2 --git-ignore"
    alias eal="e -a -l"
    alias v="nvim"
    alias s="source"
    alias cls="clear"
    alias mkd="mkdir -p"
    alias fdf="fd -H -t f"
    alias fdd="fd -H -t d"
    alias rmd="trash-put"
    alias rmy="command rm -f"

end
