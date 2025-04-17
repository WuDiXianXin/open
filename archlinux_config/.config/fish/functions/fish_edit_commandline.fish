function fish_edit_commandline
    # 创建临时文件并检查是否成功
    set -l tmpfile (mktemp 2>/dev/null)
    if not set -q tmpfile[1] || not test -f $tmpfile
        echo "Failed to create temp file"
        return 1
    end

    # 将当前命令行内容写入临时文件
    if not commandline >$tmpfile
        echo "Failed to save commandline"
        rm -f $tmpfile
        return 1
    end

    # 调用编辑器（支持环境变量回退）
    set -l editor (command -v $EDITOR || command -v nano || command -v vi)
    if not $editor $tmpfile
        echo "Editor execution failed"
        rm -f $tmpfile
        return 1
    end

    # 加载编辑后的内容并清理
    commandline -r (cat $tmpfile | string collect)
    commandline -f repaint
    rmy -f $tmpfile
end
