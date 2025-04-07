function proxy_manager
    printf "󰓯 代理作用域管理菜单：\n"
    printf "1. 设置(wifi局域网)全局代理\n"
    printf "2. 设置(手机热点)全局代理\n"
    printf "3. 撤销全局代理\n"
    printf "4. 查看当前代理配置\n"
    printf "请选择操作 [1-4]: "

    read -l choice
    switch $choice
        case 1
            set -gx http_proxy "http://192.168.5.243:17890"
            set -gx https_proxy "$http_proxy"
            set -gx all_proxy "socks5://192.168.5.243:17891"
            set -gx no_proxy "192.168.5.0/24,localhost,127.0.0.1,::1"
            if curl -m 3 -x $http_proxy https://example.com >/dev/null 2>&1 || \
   		curl -m 3 --socks5 $all_proxy https://example.com >/dev/null 2>&1
		printf "✅ 代理已生效"
	    end

        case 2
            set -gx http_proxy "http://192.168.205.21:17890"
            set -gx https_proxy "$http_proxy"
            set -gx all_proxy "socks5://192.168.205.21:17891"
            set -gx no_proxy "192.168.205.0/24,localhost,127.0.0.1,::1"
            if curl -m 3 -x $http_proxy https://example.com >/dev/null 2>&1 || \
   		curl -m 3 --socks5 $all_proxy https://example.com >/dev/null 2>&1
		printf "✅ 代理已生效"
	    end

        case 3
            if set -q http_proxy
                set -e http_proxy https_proxy all_proxy no_proxy
                printf "🛑 全局代理已清除\n"
            else
                printf "⚠️ 无活跃代理配置\n"
            end

        case 4
            printf "%-6s | %-12s | %s\n" "作用域" "变量" "值"
            printf "-------------------------\n"
            for var in http_proxy https_proxy all_proxy no_proxy
                if set -q $var
                    set -l scope (test -g $$var; and echo "全局" or echo "局部")
                    printf "%-6s | %-12s = %s\n" $scope $var $$var
                end
            end | column -t 2>/dev/null || cat  # 兼容无 column 命令的系统

        case '*'
            printf "󰅖 无效输入，请选择 1-4\n"
    end
end
