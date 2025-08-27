# 安装 Arch Linux

> By WuDiXianXin
>> 参考文章 [泠熙的博客](https://lingxi9374.github.io/posts/教程/archinst/)
---

## 进入镜像系统后，检查准备工作是否正确

### 是否是使用 UEFI 启动 GPT 分区表的 ISO 镜像系统，如果有这个目录且会输出很多内容，说明是的

```bash
ls /sys/firmware/efi/efivars
```

### 查看引导模式是不是 64

```bash
cat /sys/firmware/efi/fw_platform_size
```

## 连接网络

### 连接 wifi

```bash
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect [wifi名称]
[wifi密码]
exit
```

### 测试网络

```bash
ping -c 4 www.baidu.com
```

## 同步时间

### 启用 NTP 时间同步

```bash
timedatectl set-ntp true
```

### 查看时间配置

```bash
timedatectl status
```

## 配置镜像源

### 使用reflector更新最近镜像站

```bash
reflector --country 'China' --age 3 --protocol https --sort rate –-save /etc/pacman.d/mirrorlist
```

### 停止镜像列表自动更新服务（reflector）

```bash
systemctl disable --now reflector.service
```

### 只保留前几个镜像源，比如第一个和清华源，然后保存退出

```bash
nano /etc/pacman.d/mirrorlist
```

### 更新包数据库并安装 archlinux-keyring

```bash
pacman -Sy archlinux-keyring
```

## 磁盘分区( ext4 和 btrfs )

我这里使用的是 btrfs 作为主系统文件系统，不懂可以参考文章 [泠熙的博客](https://lingxi9374.github.io/posts/教程/archinst/)，或者借助AI进行分区
使用命令 `lsblk` 或者 `fdisk -l` 查看分区情况

```
❯ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0   1.8T  0 disk 
├─nvme0n1p1 259:1    0   512M  0 part /efi
├─nvme0n1p2 259:2    0   512G  0 part /home
│                                     /var/cache
│                                     /var/log
│                                     /.snapshots
│                                     /
├─nvme0n1p3 259:3    0   512G  0 part /home/xx/dev/git
├─nvme0n1p4 259:4    0    16M  0 part 
├─nvme0n1p5 259:5    0 829.8G  0 part 
├─nvme0n1p6 259:6    0   704M  0 part 
└─nvme0n1p7 259:7    0     8G  0 part [SWAP]
```

### ext4 文件系统

#### 格式化和挂载 根目录 /（ nvme0n1p2 替换成你自己设置的）

```bash
mkdir -p /mnt
mkfs.ext4 /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
```

#### 格式化和挂载 EFI 分区（ nvme0n1p1 替换成你自己设置的）

```bash
mkdir -p /mnt/efi
mkfs.vfat -F32 /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt/efi
```

#### 格式化和挂载 swap 分区（ nvme0n1p3 替换成你自己设置的）

```bash
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3
```

#### 查看是否挂载分区成功（会比上图多了 mnt 字样的）

```bash
lsblk
```

### btrfs 文件系统

#### 格式化分区并挂载 Btrfs 主分区（ nvme0n1p2 替换成你自己设置的）

```bash
mkdir -p /mnt
mkfs.btrfs -f /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
```

#### 创建所需子卷

```bash
# 创建根目录子卷（对应/）
btrfs subvolume create /mnt/@

# 创建用户目录子卷（对应/home）
btrfs subvolume create /mnt/@home

# 创建日志子卷（对应/var/log）
btrfs subvolume create /mnt/@log

# 创建缓存子卷（对应/var/cache）
btrfs subvolume create /mnt/@cache

# 创建快照存储自卷（对应/.snapshots）
btrfs subvolume create /mnt/@snapshots

# 查看子卷是否生成
btrfs subvolume list /mnt
```

#### 卸载主分区，重新按子卷挂载（准备安装系统）

```bash
# 先卸载临时挂载的主分区
umount /mnt

# 挂载根目录子卷 @ 到 /mnt（系统会安装到这里）
mount -o subvol=@,compress=zstd,noatime,discard=async /dev/nvme0n1p2 /mnt

# 创建 /home、/var/log、/var/cache、/mnt/.snapshots 的挂载目录（系统默认没有，需要手动建）
mkdir -p /mnt/home /mnt/var/log /mnt/var/cache /mnt/.snapshots

# 挂载 @home 子卷到 /mnt/home
mount -o subvol=@home,compress=zstd,noatime,discard=async /dev/nvme0n1p2 /mnt/home

# 挂载 @log 子卷到 /mnt/var/log
mount -o subvol=@log,noatime,discard=async /dev/nvme0n1p2 /mnt/var/log

# 挂载 @cache 子卷到 /mnt/var/cache
mount -o subvol=@cache,noatime,discard=async /dev/nvme0n1p2 /mnt/var/cache

# 挂载 @snapshots 子卷到 /mnt/.snapshots
mount -o subvol=@snapshots,compress=zstd,noatime,discard=async /dev/nvme0n1p2 /mnt/.snapshots
```

#### 格式化并挂载 EFI 分区（ nvme0n1p1 替换成你自己设置的）

```bash
mkdir -p /mnt/efi
mkfs.vfat -F32 /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt/efi
```

#### 格式化并挂载 swap 分区（ nvme0n1p3 替换成你自己设置的）

```bash
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3
```

#### 查看是否挂载分区成功

```bash
lsblk
```

## 给新系统预装软件

```bash
# 如果你不需要 grub 中显示 Windows系统选项，就不需要安装 ntfs-3g os-prober
pacstrap /mnt base base-devel \
linux-zen linux-zen-headers linux-firmware \
dosfstools e2fsprogs ntfs-3g exfat-utils btrfs-progs \
efibootmgr os-prober grub \
networkmanager wget curl nano
```

## 更新开机挂载分区信息

```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

## 进入新系统

```bash
arch-chroot /mnt /bin/bash
```

### 设置主机配置

#### 设置主机名（ 'ZhuJiMing' 改成你设置的，要加一对单引号）

```bash
echo 'ZhuJiMing' > /etc/hostname
```

#### 编辑/etc/hosts文件，添加以下内容

1. 方法一：
```bash
nano /etc/hosts
```

```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   ZhuJiMing.localdomain ZhuJiMing
```

2. 方法二：
```bash
echo "127.0.1.1   ZhuJiMing.localdomain ZhuJiMing" >> /etc/hosts
```

```
请注意：
127.0.0.1 和 ::1 是本地回环地址，
localhost 是主机名，
ZhuJiMing.localdomain 是你自己设置的主机名的备用域名，
ZhuJiMing 是你自己设置的主机名。
请不要修改 127.0.1.1 (debian系列软件会使用这一行)，否则可能会导致网络无法正常连接。
```

### 设置时间

```bash
timedatectl set-ntp true
timedatectl set-local-rtc 0
timedatectl set-timezone Asia/Shanghai
timedatectl status
```

### 设置语言环境

#### 设置 /etc/locale.gen

```bash
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" > /etc/locale.gen
```

#### 更新信息

```bash
locale-gen
```

#### 设置语言环境(中英都行)

```bash
echo LANG=zh_CN.UTF-8 > /etc/locale.conf
```

## 设置账户和密码

### 设置root账号密码（密码需要输入两次，且不显示内容）

```bash
passwd
```

### 添加sudo用户并设置给其设置密码（[用户名]改成你设置的）

```bash
useradd -m -g users -G wheel [用户名]
passwd [用户名]
```

### 开放sudo权限（删除 root 后面的第一个 %wheel 前面的 #）

```bash
nano /etc/sudoers
```

```
如下所示:
##
## User privilege specification
##
root ALL=(ALL:ALL) ALL

## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) ALL
```

## 安装微核（二选一）

### 如果你是Intel的

```bash
pacman -S intel-ucode
```

### 如果你是AMD的

```bash
pacman -S amd-ucode
```

## 安装并配置GRUB

### 安装 grub

```bash
pacman -S --needed grub
# 双系统 需要 efibootmgr os-prober
# 支持 win系统需要 ntfs-3g
```

### 设置grub安装信息(主板 bois 进入选项)

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
```

### 配置grub内容

```bash
nano /etc/default/grub
```

```
# GRUB boot loader configuration

GRUB_DEFAULT=0
GRUB_TIMEOUT=15
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nowatchdog ibt=off nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 modprobe.blacklist=snd_hda_codec_hdmi nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
GRUB_CMDLINE_LINUX=""

# Preload both GPT and MBR modules so that they are not missed
GRUB_PRELOAD_MODULES="part_gpt part_msdos"

# Uncomment to enable booting from LUKS encrypted devices
#GRUB_ENABLE_CRYPTODISK=y

# Set to 'countdown' or 'hidden' to change timeout behavior,
# press ESC key to display menu.
GRUB_TIMEOUT_STYLE=menu

# Uncomment to use basic console
GRUB_TERMINAL_INPUT=console

# Uncomment to disable graphical terminal
#GRUB_TERMINAL_OUTPUT=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `videoinfo'
GRUB_GFXMODE=auto

# Uncomment to allow the kernel use the same resolution used by grub
GRUB_GFXPAYLOAD_LINUX=keep

# Uncomment if you want GRUB to pass to the Linux kernel the old parameter
# format "root=/dev/xxx" instead of "root=/dev/disk/by-uuid/xxx"
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY=true

# Uncomment and set to the desired menu colors.  Used by normal and wallpaper
# modes only.  Entries specified as foreground/background.
#GRUB_COLOR_NORMAL="light-blue/black"
#GRUB_COLOR_HIGHLIGHT="light-cyan/blue"

# Uncomment one of them for the gfx desired, a image background or a gfxtheme
#GRUB_BACKGROUND="/path/to/wallpaper"
#GRUB_THEME="/path/to/gfxtheme"

# Uncomment to get a beep at GRUB start
#GRUB_INIT_TUNE="480 440 1"

# Uncomment to make GRUB remember the last selection. This requires
# setting 'GRUB_DEFAULT=saved' above.
# GRUB_SAVEDEFAULT=true

# Uncomment to disable submenus in boot menu
GRUB_DISABLE_SUBMENU=y

# Probing for other operating systems is disabled for security reasons. Read
# documentation on GRUB_DISABLE_OS_PROBER, if still want to enable this
# functionality install os-prober and uncomment to detect and include other
# operating systems.
GRUB_DISABLE_OS_PROBER=false
```

### 检测win系统有没有加入grub选项中

```bash
os-prober
```

### 生成grub配置文件

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## 结束镜像安装

### 退出到 ISO 镜像 root 用户环境

```bash
exit
```

### 重启 或 关机

```bash
reboot
# shutdown -h now
```
