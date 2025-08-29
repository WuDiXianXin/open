# 配置 Arch Linux

> By WuDiXianXin
---

## 连接网络(最后面有 dns 配置)

### 使用ping命令查看是不是连接到网络了

```bash
ping -c 4 www.baidu.com
```

### 如果未连接网络，使用 NetworkManager 的工具 nmcli

#### 启动 NetworkManager 服务，并连接 wifi

```bash
sudo systemctl enable --now NetworkManager
nmcli --ask d wifi connect wifi的名字
```

#### 如果不行请按照下面操作

##### 查看当前可用的网络连接和设备状态

```bash
nmcli device
```

```
DEVICE  TYPE      STATE        con
wlan0   wifi      disconnected --
eth0    ethernet  unavailable  --
lo      loopback  unmanaged    --
```

```bash
ip link
```

```
# 从输出结果找到有wlp的
......
3: wlp0s20f3 ......
        ```

##### 添加新的 Wi-Fi 连接（如果尚未创建）
```bash
nmcli con add type wifi con-name "[自定义虚拟网卡名字]" \
ifname [wlp0s20f3] autoconnect yes \
ssid [wifi的名字] \
wifi-sec.key-mgmt [一般情况填wpa-psk] \
wifi-sec.psk [wifi的密码]
```

##### 激活 Wi-Fi 连接

```bash
nmcli con up "[自定义虚拟网卡名字]"
```

##### 检查连接状态，确认是否成功连接

```bash
nmcli con show "[自定义虚拟网卡名字]"
# nmcli d show
```

##### 使用 ping 命令测试网络连接

```bash
ping -c 4 www.baidu.com
```

### 安装aur助手paru与日常维护

#### 配置Arch Linux CN 仓库

```bash
nano /etc/pacman.conf
```

```
# 在文件最后面添加
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```

#### 更新包数据库 并 安装 archlinuxcn-keyring

```bash
pacman -Sy archlinuxcn-keyring
```

#### 安装 AUR助手 paru

```bash
pacman -Syu paru
```

#### 日常维护，只需要：这其中参数：y会自动更新包数据库，u升级系统中的包

```bash
sudo pacman -Syu
```

##### 半年或者几个月后进行一次更新密钥

```bash
sudo pacman -S archlinux-keyring archlinuxcn-keyring
```

##### 如果日后出现密钥错误问题，重新初始化密钥环

```bash
sudo rm -fr /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --populate archlinuxcn
```

### 安装N卡驱动（nvidia-dkms版）

前置要求： base-devel linux-zen-headers (要包括你的所有内核的 headers )

#### 启用32位包，可以玩32位游戏，也是 lib32-nvidia-utils 包的前置要求

```bash
nano /etc/pacman.conf
```

```ini
# 取消下面两行注释
[multilib]
Include = /etc/pacman.d/mirrorlist
```

#### 安装 dkms 和 nvidia-dkms以及相应工具和包

```bash
pacman -Sy dkms nvidia-dkms nvidia-utils \
nvidia-settings nvidia-prime lib32-nvidia-utils \
mesa vulkan-icd-loader
```

#### 注意事项

不要安装 nvidia 、nvidia-(drm、modeset、uvm),
因为nvidia-dkms已经包含了这些

#### 重启

```bash
reboot
```

### 字体

### 安装字体

```bash
paru -S ttf-maplemono-nf-cn otf-noto-sans-cjk-vf noto-fonts-emoji ttf-jetbrains-mono-nerd
```

#### 刷新字体

```bash
sudo fc-cache -f -v
```

### 安装桌面环境以及一些软件

直接用 `gnome` 省事了

1. gnome
```bash
paru -S \
gnome \
wl-clipboard \
fcitx5-im \
fcitx5-chinese-addons \
fcitx5-pinyin-zhwiki \
rime-pinyin-zhwiki

sudo systemctl enable gdm
```

2. hyprland
```bash
paru -S \
hyprland \
waybar \
wl-clipboard \
libnotify \
xdg-desktop-portal-hyprland \
fcitx5-im \
fcitx5-chinese-addons \
fcitx5-pinyin-zhwiki \
rime-pinyin-zhwiki
```

### 安装终端模拟器(如果选 gnome 跳过)

如果不安装gnome、kde等桌面环境，
而是窗口管理器如hyprland、sway、niri、i3等需要终端模拟器。

安装并配置kitty 或者 foot（wayland）

```bash
paru -S kitty
mkdir -p ~/.config/kitty
nano ~/.config/kitty/kitty.conf
```

```ini
font_family Maple Mono NF CN
font_size 12
encoding utf-8
pango_markup yes
```

### 进入桌面环境

1. gnome
```bash
# 重启后
reboot
# 或者
sudo systemctl start gdm
# 选择桌面环境，输入密码，自动进入
```

2. hyprland
```bash
hyprland
```

#### 配置输入法

```bash
fcitx5-configtool
```

#### 蓝牙

1. gnome
```bash
sudo systemctl enable --now bluetooth
sudo systemctl status bluetooth
```

2. hyprland
```bash
sudo pacman -S bluez bluez-utils blueberry
sudo systemctl enable --now bluetooth
sudo systemctl status bluetooth
```

#### 声卡

```bash
sudo pacman -S \
sof-firmware \
pipewire \
pipewire-pulse \
pipewire-alsa \
pipewire-jack \
wireplumber \
pavucontrol
```

```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

### 禁用nvidia声卡

配置 grub，如果前面没有设置，设置了可跳过

```bash
sudo nano /etc/default/grub
```

```ini
GRUB_CMDLINE_LINUX_DEFAULT="... nvidia-drm.modeset=1 modprobe.blacklist=snd_hda_codec_hdmi"
```

```bash
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

### 其他

#### 调整声音

pavucontrol 启动图形配置选项

#### 指定 dns 服务器

使用 nmcli 命令

##### 添加 dns

```bash
nmcli con modify "wifi的名字" +ipv4.dns "8.8.8.8 114.114.114.114"
nmcli con modify "wifi的名字" +ipv6.dns "2400:3200::2 2001:4860:4860::8844"

# 确保 DNS 配置生效（禁用自动获取 DNS）
nmcli con modify "wifi的名字" ipv4.ignore-auto-dns yes
nmcli con modify "wifi的名字" ipv6.ignore-auto-dns yes
# 重启 wifi
nmcli con down "wifi的名字" && nmcli con up "wifi的名字"
```

##### 移除 dns

将 `+` 改为 `-` 即可从 DNS 列表中 **移除指定的 DNS 服务器**

###### 移除 IPv4 DNS

```bash
# 移除指定的 IPv4 DNS 服务器（注意保持地址顺序与添加时一致）
nmcli con modify "wifi的名字" -ipv4.dns "8.8.8.8 114.114.114.114"
```

###### 移除 IPv6 DNS

```bash
# 移除指定的 IPv6 DNS 服务器
nmcli con modify "wifi的名字" -ipv6.dns "2400:3200::2 2001:4860:4860::8844"
```

1. **精确匹配**：移除时需要严格匹配之前添加的 DNS 地址（包括顺序），否则可能无法正确移除。
   - 例如：如果之前添加的是 `8.8.8.8 114.114.114.114`，移除时必须按相同顺序写，不能颠倒。

2. **部分移除**：如果只想移除其中一个 DNS，单独指定即可：

   ```bash
   # 只移除 8.8.8.8（保留 114.114.114.114）
   nmcli con modify "wifi的名字" -ipv4.dns "8.8.8.8"
   ```

3. **生效方式**：修改后需重启连接使配置生效：

   ```bash
   nmcli con down "wifi的名字" && nmcli con up "wifi的名字"
   ```

4. **清空所有 DNS**：如果想删除所有手动设置的 DNS（恢复默认），可以用空字符串：

   ```bash
   nmcli con modify "wifi的名字" ipv4.dns ""  # 清空所有 IPv4 DNS
   nmcli con modify "wifi的名字" ipv6.dns ""  # 清空所有 IPv6 DNS
   ```
