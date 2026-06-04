在 Arch Linux 上，建议将 `NameResolvingService` 设置为 `systemd`。这不仅能让 iwd 自动管理 DNS 以替代你手动设置114，也更契合 Arch Linux 的现代体系。

### 💡 为什么要设为 `systemd`？

*   **iwd 默认值**：Arch Wiki 指出，不设置此项时，`systemd` 是默认值。你的情况恰恰证明了需要显式设置，因为手动写`/etc/resolv.conf`意味着 DNS 管理并未自动生效。
*   **Arch 官方推荐**：作为基于 `systemd` 的发行版，Arch 推荐使用 `systemd` 作为 DNS 管理器。当网络环境切换时，iwd 会自动更新 DNS，避免了手动设置可能导致的访问问题。

### 🚀 配置步骤

1.  **配置 iwd**：编辑 `/etc/iwd/main.conf` 文件，添加/修改为以下内容：
    ```ini
    [General]
    EnableNetworkConfiguration=true
    [Network]
    NameResolvingService=systemd
    ```
    完成后**保存文件**。
2.  **启用 systemd-resolved**：iwd 需要 systemd-resolved 服务来配合完成 DNS 管理。运行以下命令启用并启动它：
    ```bash
    sudo systemctl enable --now systemd-resolved
    ```
3.  **链接 `/etc/resolv.conf`**：为了让系统正常使用 systemd-resolved 进行域名解析，需要创建软链接：
    ```bash
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    ```
4.  **重启 iwd**：最后，重启 iwd 服务使配置生效。
    ```bash
    sudo systemctl restart iwd
    ```

### ⚠️ 可能遇到的问题及排查

*   **问题：iwd 启动早于 systemd-resolved**
    在某些情况下，iwd 可能在 systemd-resolved 之前启动，导致 DNS 条目添加失败。当网络连接后依旧无法解析域名时，`systemctl status systemd-resolved --no-pager` 能确认 resolved 是否在正常运行。
*   **问题：服务冲突**
    请确保系统中没有其他网络管理工具（如 `NetworkManager`）在同时运行，因为它们可能会产生冲突。
*   **验证 DNS 设置**
    重启服务后，可以运行 `resolvectl status` 来查看当前 DNS 服务器的配置情况。

设置完成后，之前的`/etc/resolv.conf`会被 `systemd-resolved` 接管，你可以删除之前手动写入的固定 DNS 条目，让 iwd 和 systemd 自动为你处理。
