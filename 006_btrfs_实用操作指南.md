# Btrfs 实用操作指南

> By WuDiXianXin

---

Btrfs 是一种现代的 Copy-on-Write 文件系统，支持子卷（subvolume）、快照（snapshot）、压缩、RAID、校验和、自愈等功能。  
其 CoW 特性使得快照和增量备份非常高效——快照创建几乎瞬间完成，实际新增物理空间仅为后续修改的差异部分。

## 子卷规划建议（最常见布局）

推荐的子卷命名（便于快照管理、与 snapper / timeshift / grub-btrfs 等工具兼容）：

- `@`          → 挂载为 `/` （根文件系统主体）
- `@home`      → 挂载为 `/home`
- `@log`       → 挂载为 `/var/log` （日志通常变化频繁，可不纳入根快照）
- `@cache`     → 挂载为 `/var/cache` （缓存可丢弃，可不纳入快照）
- `@snapshots` → 集中存放快照，挂载为 `/.snapshots` 或 `/.btrfs-snapshots`（**推荐使用点开头 `.snapshots` 以隐藏**）

> 2025–2026 年社区最流行做法：根快照子卷用 `@`，快照存储用 `.snapshots`（点开头），与 openSUSE、Fedora Silverblue、Ubuntu 部分方案、Arch snapper 指南保持一致。

创建与挂载详细步骤可参考  
[《001_安装_Arch_Linux.md》 → “btrfs 文件系统” 章节](https://gitee.com/wudixianxin/open/blob/main/001_安装_Arch_Linux.md)

## 快照与备份、恢复

### 创建快照（推荐始终创建只读快照）

日常备份**强烈建议**使用只读快照（`-r`），防止误操作修改历史版本。

命名建议：`YYYYMMDD-HHMM_用途` 或 `YYYYMMDD-序号_用途`（方便排序）

```bash
# 示例：根子卷 (@) 的只读快照
sudo btrfs subvolume snapshot -r / /.snapshots/$(date +%Y%m%d-%H%M)_root

# 示例：home 子卷
sudo btrfs subvolume snapshot -r /home /.snapshots/$(date +%Y%m%d-%H%M)_home
```

输出示例：
```
create readonly snapshot of '/' in '/.snapshots/20260120-1427_root'
```

**小技巧**：可写脚本自动化 + cron（或 systemd timer）定时创建。

### 从快照回滚恢复（系统损坏时）

**最安全方式**：使用 Arch/Linux live ISO 启动（自带 btrfs-progs）。

1. 确认分区（通常是根分区）

   ```bash
   lsblk -f
   ```

2. 挂载 Btrfs 文件系统（不指定 subvol，让它挂载默认 subvolume）

   ```bash
   sudo mount /dev/nvme0n1p2 /mnt
   ```

3. （可选）查看所有子卷/快照列表

   ```bash
   sudo btrfs subvolume list /mnt
   ```

4. 恢复根子卷（@）示例

   ```bash
   # 先删除损坏的 @（如果 delete 失败，先清空内容）
   sudo btrfs subvolume delete /mnt/@
   # 或者先清空再删（更保险，但极度小心）
   # sudo rm -rf /mnt/@/* /mnt/@/.[!.]*   # 千万确认路径！

   # 从快照重建 @
   sudo btrfs subvolume snapshot /mnt/.snapshots/20260120-1427_root /mnt/@
   ```

5. 同理处理 `@home`（如果也需要回滚）

6. 卸载 & 重启

   ```bash
   sudo umount /mnt
   reboot
   ```

> **重要**：只要子卷名字和原来一样，`/etc/fstab` 无需修改（因为 subvol=@ 等选项不变）。

### 挂载单个快照（只提取文件、不回滚整个系统）

```bash
sudo mkdir /mnt/snap

# 方式1：直接用 subvol= 选项挂载特定快照
sudo mount -t btrfs -o subvol=.snapshots/20260120-1427_root,ro \
     /dev/nvme0n1p2 /mnt/snap

# 方式2：如果已挂载根文件系统，可用 bind 方式（较少用）
# sudo mount --bind /.snapshots/20260120-1427_root /mnt/snap

# 用完记得卸载
sudo umount /mnt/snap
```

### 删除不再需要的快照

```bash
sudo btrfs subvolume delete /.snapshots/20260120-1427_root
```

**批量清理**建议写脚本或使用 snapper / btrbk 等工具自动管理保留策略。

### 使用 `btrfs send | receive` 做备份 / 迁移

**优点**：支持增量、保留 CoW 特性、校验和可靠  
**缺点**：目标也必须是 Btrfs，操作稍复杂

#### 完整备份（第一次）

```bash
# 源快照必须是只读的
sudo btrfs send /.snapshots/20260120-1427_root > /path/to/external/20260120_root.btrfs
# 或直接管道到 receive（推荐，节省本地空间）
sudo btrfs send /.snapshots/20260120-1427_root | sudo btrfs receive /mnt/backup
```

#### 增量备份（后续）

```bash
# 先创建新只读快照
sudo btrfs subvolume snapshot -r / /.snapshots/$(date +%Y%m%d-%H%M)_root

# 增量发送（-p 指定共同祖先）
sudo btrfs send -p /.snapshots/20260120-1427_root \
     /.snapshots/20260121-0930_root \
     | sudo btrfs receive /mnt/backup
```

**常见错误提醒**：

- 增量发送时，**源和目标上必须存在相同的父快照**（即 -p 指定的快照也要在接收端存在）
- 快照必须保持**只读**（否则 send 会失败或数据不一致）
- 接收端路径通常是**已存在的普通目录**（receive 会自动在该目录下创建同名子卷）

#### 从备份文件恢复（迁移 / 换盘场景）

1. 在目标机器挂载新的 Btrfs 分区到 `/mnt`
2. 接收完整备份

   ```bash
   sudo btrfs receive /mnt < /path/to/20260120_root.btrfs
   # 或 cat 方式
   cat 20260120_root.btrfs | sudo btrfs receive /mnt
   ```

3. 增量备份要**按顺序**依次接收（先基础 → 后增量）
4. 接收完成后，将子卷重命名为 `@`（或你原来的名字）

   ```bash
   sudo btrfs subvolume snapshot /mnt/20260120-1427_root /mnt/@
   # 或直接 rename（视情况）
   sudo btrfs subvolume delete /mnt/@    # 如果已有旧的
   sudo btrfs subvolume rename /mnt/20260120-1427_root /mnt/@
   ```

### 其他实用命令速查

- 查看空间使用：`sudo btrfs filesystem df /` / `sudo btrfs filesystem usage /`
- 压缩整个文件系统：`sudo btrfs filesystem defragment -r -czstd /`
-  scrub 检查数据完整性：`sudo btrfs scrub start /`
- 查看属性（压缩、COW 等）：`sudo btrfs property get /path`
- 设置默认子卷（很少需要）：`sudo btrfs subvolume set-default <subvolid> /`

**强烈建议**：  
- 初学者优先使用图形化/自动工具：**snapper + snap-pac**（pacman 自动前后快照）、**btrbk**（强大备份工具）、**timeshift**（简单易用）  
- 定期验证快照能否正常挂载/读取  
- 重要数据仍建议异地多份备份（3-2-1 原则），Btrfs 快照 ≠ 异地备份

希望这份指南对你和看到的人有帮助！欢迎补充/纠错～
