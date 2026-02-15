# 安装 Arch Linux 详细教程

> By WuDiXianXin

>> 参考文章：[泠熙的博客](https://lingxi9374.github.io/posts/教程/archinst/)

---

重要提示：安装前请备份目标磁盘所有重要数据，分区操作会格式化磁盘，导致数据丢失！本教程适用于 UEFI 启动 + GPT 分区表环境，BIOS + MBR 环境不适用。

## 一、前期准备

### 1.1 必备工具

- U盘（建议容量 ≥ 8GB）

- Arch Linux 官方镜像：从 [Arch Linux 官网](https://archlinux.org/download/) `（里面有推荐镜像源）`

- 镜像写入工具：[Ventoy 官网](https://www.ventoy.net/cn/download.html)

- (可选)装机维护工具：[微PE工具箱](https://www.wepe.com.cn/download.html)

- 网络环境：稳定的 WiFi 或有线网络（安装过程需联网下载包）

### 1.2 写入镜像到 U 盘

以下为 Win10/11 系统下使用 Ventoy 工具写入镜像的详细步骤（Ventoy 支持直接拷贝 ISO 镜像，无需重复格式化 U 盘）：

1. 以管理员身份打开解压好的 Ventoy 执行文件（`Ventoy2Disk.exe`）

2. 点击软件界面中的「配置选项」，在弹出的窗口中设置：分区类型选择「GPT」（适配 UEFI 启动），分区设置选择「文件系统：exFAT；簇大小：默认或 32kb；分区按照 4kb 对齐」，设置完成后点击「确定」。

3. 返回主界面，在「设备」下拉框中选择要配置的 U 盘（务必确认 U 盘盘符正确，避免误操作），点击「安装」，弹出警告提示时确认 U 盘数据已备份，然后点击「是」，等待操作完成即可。

4. Ventoy 配置完成后，只需将下载的 Arch Linux ISO 镜像文件(可选：微PE工具箱的 ISO 镜像文件)直接拷贝到 U 盘根目录，无需额外写入操作，U 盘可正常用于 Arch 安装引导。

### 1.3 调整 BIOS/UEFI 启动项

将 U 盘插入待安装电脑，开机时按快捷键（通常为 F2、F12、Del、Esc，不同品牌主板不同）进入 BIOS/UEFI 设置，关闭 Secure Boot，将 U 盘设为第一启动项，保存设置并重启，进入 Arch 镜像系统。

## 二、镜像系统初始化检查

进入 Arch 镜像系统后，默认以 root 用户登录，首先进行以下检查，确保环境符合安装要求。

### 2.1 验证 UEFI 启动模式

执行以下命令，若输出大量文件/目录，说明已进入 UEFI 模式；若提示目录不存在，则为 BIOS 模式，本教程不适用。

```bash

ls /sys/firmware/efi/efivars
```

### 2.2 验证 UEFI 位数

执行命令查看引导模式位数，需输出 64（Arch Linux 仅支持 64 位 UEFI）。

```bash

cat /sys/firmware/efi/fw_platform_size
```

## 三、网络配置

Arch 镜像系统默认未配置网络，需手动连接网络，确保后续包下载正常。

### 3.1 连接 WiFi（无线网络）

使用 `iwctl` 工具连接 WiFi，步骤如下：

```bash

# 进入 iwctl 交互模式
iwctl
# 列出所有无线设备（通常为 wlan0，记好设备名）
device list
# 扫描附近 WiFi
station wlan0 scan
# 列出扫描到的 WiFi 网络
station wlan0 get-networks
# 连接目标 WiFi（将 [WiFi名称] 替换为实际 WiFi 名称，区分大小写）
station wlan0 connect [WiFi名称]
# 输入 WiFi 密码（输入时不显示，输完回车即可）
[WiFi密码]
# 退出 iwctl 交互模式
exit
```

### 3.2 连接有线网络（可选）

若有网线，直接将网线插入电脑，多数情况下会自动获取 IP 地址，无需额外配置。

### 3.3 测试网络连通性

执行以下命令 ping 百度，若正常接收数据包，说明网络连接成功。

```bash
ping -c 4 www.baidu.com
```

## 四、时间同步

启用 NTP 时间同步，确保系统时间准确，避免后续安装过程中出现证书验证错误。

```bash
# 启用 NTP 时间同步
timedatectl set-ntp true
# 查看时间同步状态（确保 NTP service 显示 active）
timedatectl status
```

## 五、镜像源配置

Arch 镜像源列表默认包含全球镜像，为提升下载速度，需筛选国内优质镜像源。

### 5.1 用 reflector 筛选国内镜像源

reflector 工具可自动筛选最近同步、速度快的镜像源，执行以下命令筛选国内 HTTPS 镜像源并保存到 mirrorlist：

```bash
reflector --country 'China' --age 3 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

参数说明：

- --country 'China'：仅筛选中国地区镜像源

- --age 3：仅保留 3 小时内同步过的镜像源

- --protocol https：仅使用 HTTPS 协议（更安全）

- --sort rate：按下载速度排序

- --save：将筛选结果保存到指定文件

### 5.2 禁用 reflector 自动更新服务

避免后续系统自动覆盖自定义镜像源：

```bash
systemctl disable --now reflector.service
```

### 5.3 手动优化镜像源（可选）

若想进一步提升速度，可手动编辑 mirrorlist，将清华、中科大等优质镜像源移至顶部（镜像源优先级按文件顺序排列，越靠前优先级越高）：

```bash
nano /etc/pacman.d/mirrorlist
```

推荐保留的国内镜像源（可添加到文件顶部）：

```bash
# 清华源
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# 中科大源
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
```

编辑完成后，按 Ctrl+O 保存，Ctrl+X 退出 nano。

### 5.4 更新包数据库并安装密钥环

更新包数据库，安装 archlinux-keyring 确保包签名验证正常：

```bash
pacman -Sy archlinux-keyring
```

注：-S 表示同步包，-y 表示更新包数据库；执行过程中若提示是否继续，输入 y 并回车即可。

## 六、磁盘分区

本教程提供两种文件系统方案：ext4（稳定通用，适合新手）和 Btrfs（支持子卷、快照，功能更强大），按需选择。首先查看磁盘信息，确定目标磁盘。

### 6.1 查看磁盘信息

执行以下命令查看系统中所有磁盘及分区，识别目标磁盘（通常为 /dev/nvme0n1 固态硬盘或 /dev/sda 机械硬盘）：

```bash
lsblk
# 或查看更详细的分区信息
# fdisk -l
```

示例输出（参考）：

```bash
❯ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0  1.8T  0 disk 
├─nvme0n1p1 259:1    0    1G  0 part /efi
├─nvme0n1p2 259:2    0    8G  0 part [SWAP]
└─nvme0n1p3 259:3    0  1.8T  0 part /home
                                     /.snapshots
                                     /var/tmp
                                     /var/log
                                     /var/cache
```

### 6.2 分区规划（推荐）

UEFI + GPT 环境下，至少需 3 个分区，推荐规划如下：

|分区路径|分区类型|文件系统|推荐大小|作用|
|---|---|---|---|---|
|/dev/nvme0n1p1（示例）|EFI 系统分区|FAT32|512MB - 1GB|存放 UEFI 引导文件|
|/dev/nvme0n1p2（示例）|Linux swap 根分区|swap|内存 ≤ 8GB 设为 1.5 倍内存；内存 > 8GB 设为 8GB - 16GB|虚拟内存|
|/dev/nvme0n1p3（示例）|Linux 分区|ext4/Btrfs|剩余空间（或按需分配）|系统根目录（/）|


### 6.3 分区工具操作（fdisk）

以目标磁盘为 /dev/nvme0n1 为例，执行以下命令进入 cfdisk 图形化分区工具：

```bash
cfdisk /dev/nvme0n1
```

### 6.4 ext4 文件系统（适合新手）

分区完成后，对各分区进行格式化并挂载。

#### 6.4.1 格式化根分区并挂载

```bash
mkdir -p /mnt
mkfs.ext4 /dev/nvme0n1p3
mount /dev/nvme0n1p3 /mnt
```

#### 6.4.2 格式化并挂载 EFI 分区

```bash

mkdir -p /mnt/efi
mkfs.fat -F32 /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt/efi
```

#### 6.4.3 格式化并启用 swap 分区

```bash

mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
```

#### 6.4.4 验证挂载结果

执行以下命令，若输出中 /mnt、/mnt/efi 有对应挂载路径，swap 分区显示 [SWAP]，说明挂载成功。

```bash

lsblk
```

### 6.5 Btrfs 文件系统（支持子卷/快照）

Btrfs 支持子卷功能，推荐将根分区划分为多个子卷，便于管理和快照。

#### 6.5.1 格式化根分区并临时挂载

```bash
mkdir -p /mnt
mkfs.btrfs -L arch /dev/nvme0n1p3
mount /dev/nvme0n1p3 /mnt
```

#### 6.5.2 创建 Btrfs 子卷

推荐创建以下子卷（便于区分不同目录，快照时可选择性备份）：

```bash

# 根目录子卷（对应 /）
btrfs subvolume create /mnt/@
# 用户目录子卷（对应 /home）
btrfs subvolume create /mnt/@home
# 日志子卷（对应 /var/log）
btrfs subvolume create /mnt/@log
# 缓存子卷（对应 /var/cache）
btrfs subvolume create /mnt/@cache
# 临时子卷（对应 /var/tmp）
btrfs subvolume create /mnt/@tmp
# 快照存储子卷（对应 /.snapshots）
btrfs subvolume create /mnt/@snapshots
# 查看子卷是否创建成功
btrfs subvolume list /mnt
```

#### 6.5.3 卸载根分区，按子卷重新挂载

临时挂载完成子卷创建后，卸载根分区，再按子卷重新挂载（设置优化参数）：

```bash

# 卸载临时挂载的根分区
umount /mnt

# 挂载根目录子卷 @ 到 /mnt（启用 zstd 压缩、禁用访问时间，提升性能）
mount -o subvol=@,compress=zstd,noatime,discard=async /dev/nvme0n1p3 /mnt

# 创建各子卷对应的挂载目录
mkdir -p /mnt/home /mnt/var/log /mnt/var/cache /mnt/var/tmp /mnt/.snapshots /mnt/kvm

mount -o subvol=@home,compress=zstd,noatime,discard=async /dev/nvme0n1p3 /mnt/home
mount -o subvol=@snapshots,compress=zstd,noatime,discard=async /dev/nvme0n1p3 /mnt/.snapshots

mount -o subvol=@kvm,noatime,nodatacow,discard=async /dev/nvme0n1p3 /mnt/kvm
mount -o subvol=@log,noatime,nodatacow,discard=async /dev/nvme0n1p3 /mnt/var/log
mount -o subvol=@cache,noatime,nodatacow,discard=async /dev/nvme0n1p3 /mnt/var/cache
mount -o subvol=@tmp,noatime,nodatacow,discard=async /dev/nvme0n1p3 /mnt/var/tmp
```

#### 6.5.4 格式化并挂载 EFI 分区和 swap 分区

操作与 ext4 系统一致：

```bash
# 格式化并挂载 EFI 分区
mkdir -p /mnt/efi
mkfs.fat -F32 /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt/efi

# 格式化并启用 swap 分区
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
```

#### 6.5.5 验证挂载结果

```bash
lsblk
```

# 七、安装基础系统包

使用 pacstrap 命令将基础系统包安装到 /mnt（根分区挂载点）。

```bash
# 安装基础包（按需调整，解释如下）
pacstrap /mnt base base-devel \
linux-zen linux-zen-headers linux-firmware \
dosfstools e2fsprogs ntfs-3g exfatprogs btrfs-progs \
efibootmgr os-prober grub \
networkmanager wget curl nano vim
```

包说明：

- base、base-devel：基础系统包和开发工具包

- linux-zen：Zen 内核（性能优化，适合桌面用户；也可选择 linux 稳定内核、linux-lts 长期支持内核）

- linux-zen-headers：Zen 内核头文件（用于编译内核模块）

- linux-firmware：硬件固件（确保网卡、显卡等硬件正常工作）

- dosfstools、e2fsprogs、btrfs-progs 等：各类文件系统工具

- efibootmgr、os-prober、grub：GRUB 引导相关工具（os-prober 用于检测双系统）

- networkmanager：网络管理工具（后续用于管理网络）

- wget、curl：下载工具；nano：文本编辑器

注：若为双系统（需识别 Windows），需保留 ntfs-3g、os-prober；单系统可省略。

## 八、配置系统挂载信息（fstab）

生成 fstab 文件，让系统开机时自动挂载各分区/子卷。

```bash
# 生成 fstab 文件（-U 按 UUID 挂载，更稳定；-p 保留挂载选项）
genfstab -U -p /mnt >> /mnt/etc/fstab
# 查看生成的 fstab 文件，确保内容正确
cat /mnt/etc/fstab
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/         	btrfs     	rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=/@	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/home     	btrfs     	rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=/@home	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/kvm		btrfs     	rw,noatime,nodatacow,ssd,discard=async,space_cache=v2,subvol=/@kvm	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/.snapshots	btrfs     	rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=/@snapshots	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/var/log  	btrfs     	rw,noatime,nodatacow,ssd,discard=async,space_cache=v2,subvol=/@log	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/var/cache	btrfs     	rw,noatime,nodatacow,ssd,discard=async,space_cache=v2,subvol=/@cache	0 0

# /dev/nvme0n1p3 LABEL=arch
UUID=05f561c6-fb0e-4bfe-9c95-a058c6e278d5	/var/tmp      	btrfs     	rw,noatime,nodatacow,ssd,discard=async,space_cache=v2,subvol=/@tmp	0 0

# /dev/nvme0n1p1
UUID=F27A-9B6E      	/efi      	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro	0 2

# /dev/nvme0n1p2
UUID=f7a245c3-c1f1-40a0-9b5a-02dc89945a64	none      	swap      	defaults  	0 0
```

务必检查 fstab 文件内容，若有错误，系统开机后无法正常挂载分区，将无法进入系统。

## 九、进入新系统并配置

通过 arch-chroot 命令切换到新安装的系统环境，进行后续配置。

```bash
arch-chroot /mnt /bin/bash
```

执行后，命令行提示符会变化，说明已进入新系统。

### 9.1 配置主机名

设置主机名（将 ZhuJiMing 替换为你的主机名，如 arch-pc）：

```bash
echo 'ZhuJiMing' > /etc/hostname
```

### 9.2 配置 hosts 文件

编辑 /etc/hosts 文件，添加主机名映射：

```bash
nano /etc/hosts
```

添加以下内容（将 ZhuJiMing 替换为你的主机名）：

```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   ZhuJiMing.localdomain ZhuJiMing
```

说明：127.0.1.1 用于本地主机名解析，debian 系列软件依赖此配置，请勿修改。编辑完成后 Ctrl+O 保存，Ctrl+X 退出。

快速添加方法（无需手动编辑）：

```bash
echo "127.0.1.1   ZhuJiMing.localdomain ZhuJiMing" >> /etc/hosts
```

### 9.3 配置时间和时区

```bash
# 启用 NTP 时间同步
timedatectl set-ntp true
# 禁用本地 RTC（避免 Windows 与 Linux 时间冲突）
timedatectl set-local-rtc 0
# 设置时区为上海
timedatectl set-timezone Asia/Shanghai
# 查看时间配置，确保正确
timedatectl status
```

### 9.4 配置语言环境

设置系统语言，推荐同时启用英文和中文 UTF-8 编码。

#### 9.4.1 编辑 locale.gen 文件

```bash
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" > /etc/locale.gen
```

或手动编辑（确保上述两行内容未被注释）：

```bash
nano /etc/locale.gen
```

#### 9.4.2 生成语言环境

```bash
locale-gen
```

#### 9.4.3 设置默认语言

（可以不在这里设置）设置默认语言为中文（也可设置为 en_US.UTF-8 英文）：

```bash
echo LANG=zh_CN.UTF-8 > /etc/locale.conf
```

### 9.5 配置用户和权限

默认只有 root 用户，为安全起见，创建普通用户并授予 sudo 权限。

#### 9.5.1 设置 root 密码

执行命令后，输入两次 root 密码（输入时不显示），按回车确认：

```bash
passwd
```

#### 9.5.2 创建普通用户

将 [用户名] 替换为你的用户名（如 xxx）：

```bash
# -m：创建用户家目录；-g users：加入 users 组；-G wheel：加入 wheel 组（用于授予 sudo 权限）
useradd -m -g users -G wheel [用户名]
# 为普通用户设置密码
passwd [用户名]
```

#### 9.5.3 授予普通用户 sudo 权限

编辑 sudoers 文件，解除 wheel 组的权限注释：

```bash
nano /etc/sudoers
```

找到以下内容，删除 %wheel 前面的 # 号：

```bash
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) ALL
```

sudoers 文件权限敏感，编辑错误会导致 sudo 无法使用，建议使用 visudo 命令编辑（自动校验语法）：visudo

### 9.6 安装 CPU 微码（提升稳定性）

根据 CPU 品牌安装对应的微码，修复 CPU 潜在漏洞，提升系统稳定性。

```bash
# Intel CPU
pacman -S intel-ucode
# AMD CPU
pacman -S amd-ucode
```

## 十、安装并配置 GRUB 引导器

GRUB 是 Linux 常用的引导器，需安装并配置才能让系统正常开机。

### 10.1 安装 GRUB 及依赖

```bash
pacman -S --needed grub
# 双系统必须安装（已在第七步安装，此处可忽略）
# pacman -S efibootmgr os-prober ntfs-3g
```

### 10.2 安装 GRUB 到 EFI 分区

执行以下命令，将 GRUB 引导文件安装到 EFI 分区，设置引导器标识为 GRUB：

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
```

参数说明：

- --target=x86_64-efi：指定目标架构为 64 位 UEFI

- --efi-directory=/efi：EFI 分区挂载点（对应 /mnt/efi，chroot 后为 /efi）

- --bootloader-id=GRUB：UEFI 启动项中的标识（开机时 BIOS 中显示的名称）

- --recheck：重新检查分区，避免安装错误

### 10.3 配置 GRUB 选项

编辑 GRUB 配置文件 /etc/default/grub，优化启动参数：

```bash
nano /etc/default/grub
```

推荐配置（根据实际情况调整，如显卡驱动参数）：

```bash
# GRUB boot loader configuration
GRUB_DEFAULT=0
GRUB_TIMEOUT=15  # 开机引导菜单停留时间（秒）
GRUB_DISTRIBUTOR="Arch"
# 内核启动参数（Nvidia 显卡需添加后续参数，核显可简化为 loglevel=3 quiet）
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nowatchdog ibt=off nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 modprobe.blacklist=snd_hda_codec_hdmi nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
GRUB_CMDLINE_LINUX=""

# Preload both GPT and MBR modules so that they are not missed
GRUB_PRELOAD_MODULES="part_gpt part_msdos"

# Uncomment to enable booting from LUKS encrypted devices
#GRUB_ENABLE_CRYPTODISK=y

# Set to 'countdown' or 'hidden' to change timeout behavior,
# press ESC key to display menu.
GRUB_TIMEOUT_STYLE=menu  # 显示引导菜单（默认 hidden，按 ESC 才显示）

# Uncomment to use basic console
GRUB_TERMINAL_INPUT=console

# Uncomment to disable graphical terminal
#GRUB_TERMINAL_OUTPUT=console

# The resolution used on graphical terminal
GRUB_GFXMODE=auto  # 自动适配分辨率

# Uncomment to allow the kernel use the same resolution used by grub
GRUB_GFXPAYLOAD_LINUX=keep

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY=true

# Uncomment to disable submenus in boot menu
GRUB_DISABLE_SUBMENU=y

# 启用 os-prober（检测双系统，双系统必须设置为 false）
GRUB_DISABLE_OS_PROBER=false
```

编辑完成后 Ctrl+O 保存，Ctrl+X 退出。

### 10.4 检测双系统（若为双系统）

执行以下命令，若能检测到 Windows 系统路径，说明 os-prober 工作正常：

```bash
os-prober
```

### 10.5 生成 GRUB 配置文件

根据上述配置生成 GRUB 引导配置文件：

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

若为双系统，输出中会显示「Found Windows ...」，说明 Windows 已添加到 GRUB 引导菜单。

# 十一、完成安装并重启

所有配置完成后，退出 chroot 环境，重启电脑即可进入新安装的 Arch Linux 系统。

### 11.1 退出 chroot 环境

```bash
exit
```

### 11.2 重启或关机

```bash
# 重启电脑（推荐）
reboot
# 若需后续操作，可先关机
# shutdown -h now
```

重启时，拔出 U 盘，电脑会自动进入 GRUB 引导菜单，选择「Arch Linux」即可进入系统，使用之前创建的普通用户登录。

## 十二、后续配置（可选）

基础系统安装完成后，还需进行以下配置，提升使用体验：

- 启动 NetworkManager 网络服务：sudo systemctl enable --now NetworkManager，使用 nmtui 命令图形化配置网络

- 安装桌面环境（如 GNOME、KDE、XFCE）

- 安装显卡驱动（Intel 核显、AMD 显卡、Nvidia 独显）

- 安装常用软件（浏览器、办公软件、输入法等）
