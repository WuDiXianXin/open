# 使用 iwd 替代 NetworkManager

> By WuDiXianXin and DeepSeek

在 Arch Linux 上，有时更新系统并重启后，NetworkManager 会出现**软堵塞**（soft blocked）的情况。使用 `iwd`（iNet Wireless Daemon）作为替代方案可以避免此问题，且更加轻量。

## 1. 安装 iwd

```bash
paru -S iwd
```

## 2. 停止并禁用 NetworkManager

```bash
sudo systemctl disable --now NetworkManager
```

## 3. 卸载 NetworkManager（可选）

```bash
paru -Rns networkmanager
```

> ⚠️ **注意**：如果你有其他依赖 NetworkManager 的软件包（例如某些桌面环境或 VPN 客户端），卸载前请确认不会破坏系统功能。

## 4. 启用 iwd 服务

```bash
sudo systemctl enable --now iwd
```

## 5. 配置 DNS 解析（推荐使用 systemd-resolved）

iwd 本身不直接处理 DNS，需要配合 `systemd-resolved` 实现自动 DNS 管理，避免手动写死 `/etc/resolv.conf`。

### 为什么推荐 `systemd` 作为 DNS 解析服务？

- iwd 默认值即为 `systemd`（Arch Wiki 说明），但显式设置可确保生效。
- Arch Linux 基于 systemd，官方推荐使用 `systemd-resolved` 管理 DNS，支持网络环境切换时自动更新。
- 避免手动设置固定 DNS（如 `114.114.114.114`）导致的切换问题。

### 配置步骤

#### 5.1 修改 iwd 配置文件

编辑 `/etc/iwd/main.conf`，添加或修改以下内容：

```ini
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
```

保存文件。

#### 5.2 启用并启动 systemd-resolved

```bash
sudo systemctl enable --now systemd-resolved
```

#### 5.3 链接 `/etc/resolv.conf`

将系统的 DNS 解析文件链接到 systemd-resolved 管理的动态文件：

```bash
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

#### 5.4 重启 iwd 服务

```bash
sudo systemctl restart iwd
```

## 6. 验证配置

### 检查 DNS 状态

```bash
resolvectl status
```

正常输出应包含网络接口及其分配的 DNS 服务器。

### 测试域名解析

```bash
ping archlinux.org
```

## 7. 可能遇到的问题及排查

### 问题 1：iwd 启动早于 systemd-resolved

- **现象**：网络连接后无法解析域名。
- **排查**：运行 `systemctl status systemd-resolved --no-pager`，确认 resolved 是否正常运行。
- **解决**：可以调整服务依赖，或在 iwd 启动后手动重启它（`sudo systemctl restart iwd`）。

### 问题 2：服务冲突

- **现象**：iwd 无法正常工作或网络不稳定。
- **排查**：确保没有其他网络管理工具（如 NetworkManager、dhcpcd、systemd-networkd）同时运行。
- **解决**：禁用冲突的服务：
  ```bash
  sudo systemctl disable --now NetworkManager dhcpcd  # 根据需要禁用
  ```

### 问题 3：手动写入的 `/etc/resolv.conf` 被覆盖

- **说明**：链接到 `stub-resolv.conf` 后，系统不再读取固定 DNS 条目。若之前手动写入了 `nameserver`，这些设置将失效。
- **解决**：信任 systemd-resolved 自动获取的 DNS，无需再手动配置。

## 8. 日常使用

连接 Wi-Fi 可使用 `iwctl` 命令行工具：

```bash
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect <SSID>
# 输入密码即可
```

退出 `iwctl` 用 `exit` 或 `Ctrl+D`。

---

通过以上步骤，你可以完全用 iwd 替代 NetworkManager，并获得自动 DNS 管理的现代网络体验。
