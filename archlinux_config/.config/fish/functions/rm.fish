function rm
    echo -e "\033[31m[安全提示]\033[0m 请优先使用：\n" \
        "  \033[32mrmd\033[0m   # 安全删除到回收站\n" \
        "  \033[31mrmy\033[0m   # 强制原生删除（危险）" >&2
    return 1
end
