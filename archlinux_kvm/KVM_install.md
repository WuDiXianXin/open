# archlinux安装配置KVM虚拟机
### 一、检查硬件支持
1. **虚拟化支持检测**  
  执行命令：  
  ```bash
  grep -E "(vmx|svm)" --color=always /proc/cpuinfo  # 直接检测CPU虚拟化标志[2](@ref)
  lsmod | grep kvm                                  # 验证内核模块是否加载[2](@ref)
  ```
2. 若 lsmod 无输出，需手动加载模块

  (二选一)
  ```bash
  sudo modprobe kvm_intel  # Intel CPU
  sudo modprobe kvm_amd    # AMD CPU
  ```

---
### 二、安装必要软件包
- **安装核心组件**  
   ```bash
   sudo pacman -S qemu-desktop libvirt virt-manager virt-viewer ebtables iptables-nft dnsmasq bridge-utils openbsd-netcat ovmf
   ```
---
### 三、配置服务与用户权限
1. 配置 libvirt 规则
   ```bash
   sudo nano /etc/polkit-1/rules.d/50-libvirt.rules
   ```
  内容:
  ```
  /* 允许 kvm 用户组成员无需认证即可管理 libvirt 守护进程 */
  polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&  
        subject.isInGroup("kvm")) {
      return polkit.Result.YES;
    }
  });
  ```
2. **将用户加入必要用户组**  
   ```bash
   sudo usermod -aG libvirt,kvm $(whoami)
   ```
   完成后需 `重新登录(或重启)` 或执行 `newgrp libvirt` 使配置生效

3. **配置 Libvirt 权限（可选）**  
   编辑 /etc/libvirt/libvirtd.conf ，确保以下配置:
   ```ini
   unix_sock_group = "libvirt"
   unix_sock_rw_perms = "0770"
   ```
4. **启动并启用 libvirtd 和 virtlogd 以及 dnsmasq 服务**  
   ```bash
   sudo systemctl enable --now libvirtd virtlogd dnsmasq
   ```

---
### 四、创建虚拟机
1. **使用图形化工具（推荐）**  
   启动 `virt-manager`：  
   ```bash
   virt-manager
   ```
   • 点击“新建虚拟机”，选择 ISO 镜像或网络安装源。
   • 配置 CPU、内存、磁盘大小等参数。

---
### 五、管理虚拟机
• **常用命令**：
  ```bash
  virsh list --all      # 查看所有虚拟机
  virsh start arch-vm   # 启动虚拟机
  virsh shutdown arch-vm # 正常关机
  virsh destroy arch-vm # 强制关闭
  ```

---
### 六、常见问题
1. **网络桥接配置失败**  
   确保 `bridge-utils` 已安装，并配置 `/etc/netctl` 或 `systemd-networkd` 的网络桥接。

2. **权限不足错误**  
   检查用户是否在 `libvirt` 和 `kvm` 组，并重启服务。

---
通过以上步骤，您可以在 Arch Linux 上顺利安装和管理 KVM 虚拟机。如需更详细的网络配置或性能优化，可参考 Arch Wiki 的 KVM 专题文档。

