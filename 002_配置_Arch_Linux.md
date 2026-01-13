# 配置 Arch Linux

> By WuDiXianXin

>> 前置说明：以下配置基于已安装完成的 Arch Linux 基础系统，需以具备 sudo 权限的普通用户执行；所有操作均在终端中完成，确保已退出 chroot 环境并正常进入系统。

---

## 一、网络配置

### 1.1 检查网络连通性

```bash
# 发送4个数据包测试百度连通性，按Ctrl+C可终止
ping -c 4 www.baidu.com
```

### 1.2 连接 WiFi（NetworkManager）

NetworkManager 是主流的网络管理工具，替代传统 iwctl，支持命令行/图形化管理，开机自启后可兼容大部分桌面环境。

#### 1.2.1 快速连接（交互式，推荐）

```bash
# 开机自启并立即启动 NetworkManager 服务
sudo systemctl enable --now NetworkManager
# --ask：交互式输入 WiFi 密码（无需明文写在命令中，更安全）
nmcli --ask d wifi connect "WiFi名称"
```

#### 1.2.2 手动配置（快速连接失败时）

##### 1.2.2.1 步骤1：查看网络设备状态

```bash
# 查看设备类型、状态（重点关注 wifi 设备名，如 wlan0/wlp0s20f3）
nmcli device
# 或通过 ip link 查看所有网络接口（以 wlp/wlan 开头的为无线网卡）
# ip link
```

示例输出（需记录无线网卡设备名，如 `wlp0s20f3`）：
```
DEVICE      TYPE      STATE        CONNECTION
wlp0s20f3   wifi      disconnected  --
eth0        ethernet  unavailable  --
lo          loopback  unmanaged    --
```

##### 1.2.2.2 步骤2：添加 WiFi 连接配置

```bash
# con-name：自定义连接名（如 "MyWiFi"）
# ifname：无线网卡设备名（如 wlp0s20f3）
# ssid：实际 WiFi 名称（区分大小写）
# wifi-sec.key-mgmt：加密方式（普通家用WiFi填 wpa-psk，无密码填 none）
# wifi-sec.psk：WiFi 密码（无需引号，特殊字符需转义）
nmcli con add type wifi con-name "MyWiFi" \
ifname wlp0s20f3 autoconnect yes \
ssid "你的WiFi名称" \
wifi-sec.key-mgmt wpa-psk \
wifi-sec.psk "你的WiFi密码"
```

##### 1.2.2.3 步骤3：激活并验证连接

```bash
# 激活自定义的 WiFi 连接
nmcli con up "MyWiFi"
# 查看连接详情（确认 IP/DNS 等信息）
nmcli con show "MyWiFi"
# 再次测试网络连通性
ping -c 4 www.baidu.com
```

### 1.3 自定义 DNS 服务器（解决网络慢/解析失败）

默认 DNS 由路由器分配，可手动指定公共 DNS 提升解析速度，推荐国内用户优先选择阿里云/114，国际用户可选谷歌/Cloudflare。

#### 1.3.1 添加 DNS

```bash
# 替换 "MyWiFi" 为你的连接名（nmcli con show 可查看所有连接名）
nmcli con modify "MyWiFi" +ipv4.dns "8.8.8.8 114.114.114.114"
# IPv6 DNS：阿里云(2400:3200::2) + 谷歌(2001:4860:4860::8844)
nmcli con modify "MyWiFi" +ipv6.dns "2400:3200::2 2001:4860:4860::8844"

# 禁用自动获取 DNS（确保手动配置生效）
nmcli con modify "MyWiFi" ipv4.ignore-auto-dns yes
nmcli con modify "MyWiFi" ipv6.ignore-auto-dns yes

# 重启 WiFi 连接使配置生效
nmcli con down "MyWiFi" && nmcli con up "MyWiFi"
```

#### 1.3.2 移除 DNS

```bash
# 移除指定 IPv4 DNS（需严格匹配添加时的地址和顺序）
nmcli con modify "MyWiFi" -ipv4.dns "223.5.5.5 114.114.114.114"
# 只移除单个 IPv4 DNS（保留其他）
nmcli con modify "MyWiFi" -ipv4.dns "223.5.5.5"

# 移除指定 IPv6 DNS
nmcli con modify "MyWiFi" -ipv6.dns "2400:3200::2 2001:4860:4860::8844"

# 清空所有手动配置的 DNS（恢复路由器自动分配）
nmcli con modify "MyWiFi" ipv4.dns ""
nmcli con modify "MyWiFi" ipv6.dns ""

# 重启连接生效
nmcli con down "MyWiFi" && nmcli con up "MyWiFi"
```

#### 1.3.3 验证 DNS 配置

```bash
# 替换 wlp0s20f3 为你的无线网卡设备名
nmcli d show wlp0s20f3 | grep DNS  # 过滤DNS相关配置，更易查看
```

## 二、安装 AUR 助手（paru）

Arch 官方仓库包有限，AUR（用户贡献仓库）提供海量软件，paru 是轻量、易用的 AUR 包管理工具（兼容 pacman 命令，替代 yay）。

### 2.1 添加 Arch Linux CN 仓库（快速安装，非官方谨慎使用）

```bash
sudo nano /etc/pacman.conf
```

在文件末尾添加清华镜像源（国内速度快）：

```ini
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```

### 2.2 完成安装

```bash
# 更新包数据库并安装 archlinuxcn-keyring（解决 CN 仓库包签名验证）
sudo pacman -Sy archlinuxcn-keyring
# 同步包并安装 paru
sudo pacman -Syu paru
```

### 2.3 日常系统维护

```bash
# 更新所有包（官方+AUR）
sudo pacman -Syu         # 仅更新官方仓库包
paru -Syu                # 更新官方包 + AUR 包（paru 兼容 pacman 命令）

# 每3-6个月更新密钥环（避免包签名验证失败）
sudo pacman -S archlinux-keyring archlinuxcn-keyring

# 密钥错误修复（包验证失败时执行）
sudo rm -fr /etc/pacman.d/gnupg
sudo pacman-key --init                  # 初始化密钥环
sudo pacman-key --populate archlinux    # 导入官方密钥
sudo pacman-key --populate archlinuxcn  # 导入 CN 仓库密钥（仅添加了CN仓库时执行）
sudo pacman -Syvv                       # 重新同步包数据库
```

## 三、安装 NVIDIA 显卡驱动（dkms 版）

dkms 版驱动会在内核更新后自动重新编译，避免驱动失效，推荐所有内核（linux/zen/lts）使用。

### 3.1 前置要求

确保已安装对应内核的头文件（内核头文件版本需与当前运行内核一致）：
```bash
# 查看当前内核版本
uname -r
# 安装对应内核头文件（示例：默认 linux 内核）
sudo pacman -S linux-headers
# 若使用 linux-zen 内核：sudo pacman -S linux-zen-headers
# 若使用 linux-lts 内核：sudo pacman -S linux-lts-headers
```

### 3.2 启用 multilib 仓库（支持 32 位程序/游戏）

```bash
sudo nano /etc/pacman.conf
```

取消以下两行注释（移除行首的 #）：
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

### 3.3 安装驱动及依赖

```bash
sudo pacman -Sy dkms nvidia-open-dkms nvidia-utils \
nvidia-settings nvidia-prime lib32-nvidia-utils \
mesa vulkan-icd-loader
```

> 注意：
> - 无需单独安装 nvidia、nvidia-drm、nvidia-modeset 等包，nvidia-open-dkms 已包含；
> - nvidia-prime 用于笔记本切换核显/独显；
> - lib32-nvidia-utils 为 32 位程序（如部分游戏）提供显卡支持。

### 3.4 重启系统使驱动生效

```bash
reboot
```

### 3.5 验证驱动安装

重启后执行以下命令，输出 NVIDIA 显卡信息则说明安装成功：
```bash
nvidia-smi
```

示例输出（核心信息）：
```
Fri Dec 12 17:35:24 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.105.08             Driver Version: 580.105.08     CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3060 ...    Off |   00000000:01:00.0  On |                  N/A |
| N/A   54C    P8             13W /   45W |     366MiB /   6144MiB |      3%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            3200      G   /usr/bin/niri                            72MiB |
|    0   N/A  N/A            3292      G   Xwayland                                  2MiB |
|    0   N/A  N/A          523610      G   /usr/lib/firefox/firefox                207MiB |
+-----------------------------------------------------------------------------------------+
```

## 四、字体配置

安装常用中文字体、编程字体，解决中文显示乱码、终端字体错位问题。

### 4.1 安装字体

```bash
# 等宽中文字体（编程/终端专用）+ 表情符号 + 编程字体（带Nerd Font图标）
paru -S ttf-maplemono-nf-cn noto-fonts-emoji ttf-jetbrains-mono-nerd
# 可选：补充思源字体（通用中文字体）
# paru -S noto-fonts-cjk
```

### 4.2 刷新字体缓存

```bash
sudo fc-cache -f -v  # -f：强制刷新；-v：显示详细缓存刷新信息
```

### 4.3 验证字体

```bash
# 查看已安装的中文字体
fc-list :lang=zh
# 验证指定字体是否安装
fc-list | grep "Maple Mono"  # 检查 Maple Mono 字体
```

## 五、输入法配置（fcitx5 + 雾凇输入法）

fcitx5 是新一代输入法框架，雾凇输入法（rime-ice）是 RIME 输入法的增强版，支持智能联想、词库丰富。

### 5.1 安装依赖包

```bash
paru -S fcitx5-im fcitx5-rime rime-ice-git
# fcitx5-im：fcitx5 核心组件
# fcitx5-rime：RIME 输入法前端
# rime-ice-git：雾凇输入法（AUR 最新版）
```

### 5.2 配置雾凇输入法

```bash
# 创建 rime 配置目录
mkdir -p $HOME/.local/share/fcitx5/rime/
# 编辑自定义配置文件
nano $HOME/.local/share/fcitx5/rime/default.custom.yaml
```

在文件中添加以下内容（启用雾凇预设）：
```yaml
patch:
  # 导入雾凇输入法默认预设（核心配置）
  __include: rime_ice_suggestion:/
  # 可选：自定义快捷键（示例：Ctrl+Space 切换输入法）
  switcher/hotkeys:
    - "Control+space"
```

### 5.3 配置 Wayland/X11 环境变量（关键）
输入法需配置环境变量才能被应用识别，**核心变量通用适配 X11/XWayland/Wayland**，但 `GTK_IM_MODULE`/`QT_IM_MODULE` 需按 Wayland 合成器（如 Hyprland/KDE/GNOME）差异化配置（官方不推荐全局设置 `GTK_IM_MODULE`，避免兼容问题）。

#### 5.3.1 全局配置（所有用户生效）
编辑全局环境变量文件，优先配置「核心必设变量」，再按合成器补充 `QT_IM_MODULE`：
```bash
sudo nano /etc/environment
```

##### 第一步：添加核心必设变量（所有场景通用）
这部分是基础，确保 XWayland 应用和 Wayland 原生应用识别 Fcitx 5：
```ini
# ========== 核心必设（所有合成器通用） ==========
# 兼容 X11/XWayland 应用（必设！X11 程序依赖此变量）
XMODIFIERS=@im=fcitx
# 强制 Fcitx 5 使用 Wayland 模式（避免 fallback 到 X11）
FCITX5_USE_WAYLAND=1
# 兼容 SDL/GLFW 应用（游戏、图形软件，可选但推荐）
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
```

##### 第二步：按合成器补充 QT_IM_MODULE（二选一/按需添加）
根据你使用的 Wayland 合成器，添加对应配置（**不要全局设置 GTK_IM_MODULE**，见 5.3.3 单独配置）：
```ini
# ========== 分合成器适配 QT 应用（择一添加） ==========
# 1. Hyprland/Sway/Niri（wlroots 系，必加）
QT_IM_MODULE=fcitx
# 2. KDE Plasma（KWin，不要加！加了会导致候选框闪烁）
# QT_IM_MODULE=  # 留空/不设置，让 Qt 自动用 Wayland 原生协议
# 3. GNOME（Mutter，必加）
# QT_IM_MODULE=fcitx
```

#### 5.3.2 单用户配置（仅当前用户生效）
若不想修改全局配置，编辑用户级配置文件，内容与全局配置完全一致：
```bash
# 方式1：登录 Shell 生效（通用）
nano ~/.profile
# 方式2：Wayland 桌面优先（推荐）
mkdir -p ~/.config/environment.d
nano ~/.config/environment.d/fcitx5.conf
```
粘贴「核心必设变量 + 对应合成器的 QT_IM_MODULE」即可。

#### 5.3.3 GTK 应用单独配置（替代全局 GTK_IM_MODULE）
全局设置 `GTK_IM_MODULE=fcitx` 会导致 Gtk2 应用兼容问题，官方推荐通过 GTK 版本专属配置文件适配：
##### 1. Gtk2 应用（老旧软件，如 rxvt/xterm）
```bash
nano ~/.gtkrc-2.0
```
添加：
```ini
gtk-im-module="fcitx"
```

##### 2. Gtk3 应用（主流 GTK 软件，如 Gedit）
```bash
mkdir -p ~/.config/gtk-3.0
nano ~/.config/gtk-3.0/settings.ini
```
添加：
```ini
[Settings]
gtk-im-module=fcitx
```

##### 3. Gtk4 应用（最新 GTK 软件，如 libadwaita 系列）
```bash
mkdir -p ~/.config/gtk-4.0
nano ~/.config/gtk-4.0/settings.ini
```
添加：
```ini
[Settings]
gtk-im-module=fcitx
```

##### 4. GNOME 额外适配（必做）
GNOME 需通过 `gsettings` 覆盖系统 XSettings，否则 Gtk 应用可能无法识别输入法：
```bash
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule':<'fcitx'>}"
```

### 5.3.4 生效配置
环境变量和 GTK 配置需重新登录系统才能生效（无需重启整机），也可手动重启 Fcitx 5 验证：
```bash
# 重启 Fcitx 5 后台进程
killall fcitx5 & fcitx5 &
# 启动配置工具确认输入法已添加
fcitx5-configtool
```

在配置工具中操作：
> 1. 右侧「可用输入法」中找到「中州韵」（或 RIME），点击「添加」；
> 2. 可选：调整输入法切换快捷键（默认 Ctrl+Space）；
> 3. 关闭配置工具，重启终端/应用即可使用。
关键说明：
> 1. 若闭源 Qt 应用（如 WPS/Anki）无法输入，可临时执行 `QT_IM_MODULE=fcitx 应用名` 单独适配；
> 2. Qt 6.7+ 可添加 `QT_IM_MODULES="wayland;fcitx;ibus"` 实现输入法模块 fallback，提升兼容性；
> 3. 保留 XWayland 启用（多数合成器默认开启），否则 Fcitx 候选框可能无法正常显示。

> 首次使用需等待雾凇词库加载，按 Ctrl+Space 切换中英文。

## 六、终端模拟器（非 GNOME 桌面需安装）

Wayland 下推荐 kitty/foot，X11 可选 alacritty/terminator，以下以 kitty 为例（跨 X11/Wayland，配置简单）。

### 6.1 安装 kitty

```bash
paru -S kitty
```

### 6.2 安装 foot

```bash
paru -S foot
```

## 七、剪贴板工具（Wayland 专用）

Wayland 无默认剪贴板工具，需安装 wl-clipboard 实现命令行剪贴板操作：

```bash
# 安装 wl-clipboard
sudo pacman -S wl-clipboard

# 常用命令
wl-copy "文本内容"         # 将文本复制到剪贴板
wl-paste                   # 粘贴剪贴板内容到终端
wl-paste > file.txt        # 将剪贴板内容保存到文件
cat file.txt | wl-copy     # 将文件内容复制到剪贴板
```

## 八、桌面环境/窗口管理器

### 8.1 GNOME（易用型桌面，适合新手）

GNOME 是开箱即用的桌面环境，集成度高，适合初次接触 Arch 的用户：

```bash
# 安装 GNOME 核心组件 + 常用工具
paru -S gnome gnome-extra
# 启用并启动 GNOME 显示管理器（GDM）
sudo systemctl enable --now gdm
```

> 重启后自动进入 GNOME 登录界面，选择「GNOME」（而非 GNOME on Xorg）即可使用 Wayland 版本。

### 8.2 Hyprland（轻量化 Wayland 窗口管理器）

Hyprland 是动态平铺式 Wayland 窗口管理器，自定义性强，适合进阶用户：

```bash
# 安装 Hyprland 核心 + 配套工具
paru -S \
hyprland \
waybar-hyprland-git \
libnotify \
xdg-desktop-portal-hyprland \
xdg-desktop-portal-gnome \
xdg-desktop-portal-gtk \
swaybg \
swaylock
```

waybar-hyprland-git           # Hyprland 适配版状态栏
libnotify                     # 通知服务
xdg-desktop-portal-hyprland   # Hyprland 门户服务（文件选择/截图等）
xdg-desktop-portal-gnome      # 通用门户服务
xdg-desktop-portal-gtk        # GTK 应用门户服务
swaybg                        # 壁纸工具
swaylock                      # 锁屏工具

#### 8.2.1 启动 Hyprland

```bash
hyprland  # 终端直接启动
# 可选：配置 ~/.config/hypr/hyprland.conf 实现开机自启/自定义快捷键
```

### 8.3 Niri（平铺式 Wayland 窗口管理器）

Niri 是现代化平铺窗口管理器，易上手：

```bash
# 安装 Niri 核心 + 配套工具
paru -S \
niri \
xwayland-satellite \
waybar \
fuzzel \
fnott \
xdg-desktop-portal-gnome \
xdg-desktop-portal-gtk
```

xwayland-satellite        # X11 应用兼容
waybar                    # 状态栏
fuzzel                    # 应用启动器
fnott                     # 通知服务
xdg-desktop-portal-gnome
xdg-desktop-portal-gtk

#### 8.3.1 启动 Niri

```bash
niri  # 终端直接启动
```

## 九、蓝牙配置

### 9.1 GNOME 桌面

GNOME 自带蓝牙图形化管理工具，只需启用服务：

```bash
# 开机自启并启动蓝牙服务
sudo systemctl enable --now bluetooth
# 查看蓝牙服务状态（active (running) 则正常）
sudo systemctl status bluetooth
```

> 操作方式：GNOME 顶部状态栏 → 蓝牙图标 → 选择设备配对。

### 9.2 Hyprland/Niri（Wayland 窗口管理器）

需安装图形化蓝牙管理工具：

```bash
# 安装蓝牙核心 + 命令行工具 + 图形化管理工具
sudo pacman -S bluez bluez-utils blueberry
# 启用并启动蓝牙服务
sudo systemctl enable --now bluetooth
sudo systemctl status bluetooth

# 启动图形化蓝牙管理器
blueberry
```

> 注意：若蓝牙设备无法配对，可执行 `sudo rfkill unblock bluetooth` 解锁蓝牙。

## 十、声卡配置（PipeWire 替代 Pulseaudio）

PipeWire 是新一代音频服务，兼容 Pulseaudio/ALSA/JACK，解决大部分音频兼容性问题。

### 10.1 安装依赖包

```bash
sudo pacman -S \
sof-firmware        # 声卡固件（适配多数笔记本/集成声卡） \
pipewire            # PipeWire 核心服务 \
pipewire-pulse      # 兼容 Pulseaudio 应用 \
pipewire-alsa       # 兼容 ALSA 应用 \
pipewire-jack       # 兼容 JACK 音频（专业音频软件） \
wireplumber         # PipeWire 会话管理器（必装） \
pavucontrol         # 图形化音量控制工具
```

### 10.2 启用并启动音频服务

```bash
# 启用用户级服务（无需 sudo，仅当前用户生效）
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# 验证服务状态（均为 active (running) 则正常）
systemctl --user status pipewire
systemctl --user status wireplumber
```

### 10.3 验证音频配置

```bash
pactl info  # 输出 "Server Name: PipeWire" 则说明 Pulseaudio 兼容层生效
```

> 启动 `pavucontrol` 可图形化调整音量、默认音频输出/输入设备、应用音量等。

## 十一、禁用 NVIDIA 声卡（避免音频输出异常）

部分 NVIDIA 显卡集成声卡会导致音频输出设备混乱，可通过内核参数禁用。

### 11.1 修改 GRUB 配置

```bash
sudo nano /etc/default/grub
```

在 `GRUB_CMDLINE_LINUX_DEFAULT` 中添加以下参数（保留原有参数，如 loglevel=3 quiet）：
```ini
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nowatchdog ibt=off nvidia-drm.modeset=1 modprobe.blacklist=snd_hda_codec_hdmi"
```

> 说明：
> - `nvidia-drm.modeset=1`：启用 NVIDIA DRM 模式设置（Wayland 下必需）；
> - `modprobe.blacklist=snd_hda_codec_hdmi`：黑名单禁用 NVIDIA 声卡驱动；
> - `ibt=off`：修复部分 Intel CPU 与 NVIDIA 驱动兼容问题。

### 11.2 生成新的 GRUB 配置

```bash
# 检测双系统（单系统可跳过）
sudo os-prober
# 生成新的 GRUB 配置文件
sudo grub-mkconfig -o /boot/grub/grub.cfg
# 重启生效
reboot
```

## 十二、常用工具与优化

### 12.1 音量调节

```bash
pavucontrol  # 图形化调整音量/音频设备（推荐）
# 命令行调节（备用）
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%  # 设置默认输出音量为50%
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle  # 切换静音/取消静音
```

### 12.2 常见问题排查

| 问题现象 | 排查方案 |
|----------|----------|
| fcitx5 无法唤醒 | 1. 检查环境变量是否配置正确（/etc/environment 或 ~/.profile）；<br>2. 重启会话/系统；<br>3. 执行 `fcitx5 -d` 后台启动输入法。 |
| NVIDIA 驱动失效 | 1. 确认已安装对应内核头文件；<br>2. 执行 `sudo dkms autoinstall` 重新编译驱动；<br>3. 检查 GRUB 内核参数是否包含 `nvidia-drm.modeset=1`。 |
| 音频无声音 | 1. 检查 PipeWire 服务是否运行（`systemctl --user status pipewire`）；<br>2. `pavucontrol` 确认默认输出设备正确；<br>3. 安装对应声卡固件（sof-firmware）。 |
| Wayland 应用无文件选择框 | 安装对应门户服务（xdg-desktop-portal-hyprland/gnome/gtk）；<br>重启应用/桌面。 |
| AUR 包编译失败 | 1. 安装 base-devel 依赖（`sudo pacman -S base-devel`）；<br>2. 检查网络是否正常；<br>3. 清理 paru 缓存（`paru -Scc`）。 |

### 12.3 系统清理

```bash
# 清理缓存
paru -Scc
# 卸载未使用的依赖包
paru -Rns $(pacman -Qdtq)
```
