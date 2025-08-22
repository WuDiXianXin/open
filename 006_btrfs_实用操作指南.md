# Btrfs 实用操作指南

> By WuDiXianXin
---

Btrfs 是一种支持快照、子卷、增量备份等功能的高级文件系统，
其“ Copy-on-Write ”特性使得存储效率更高——实际消耗的物理空间仅为文件变化后的差异部分，而非完整复制文件。

## 创建并挂载 Btrfs 分区、子卷

子卷规划是 Btrfs 使用的基础，建议按以下方式命名子卷（便于管理和快照）：

- `@`：对应根目录 `/`
- `@home`：对应用户目录 `/home`
- `@log`：对应日志目录 `/var/log`
- `@cache`：对应缓存目录 `/var/cache`
- `@snapshots`：用于集中存储所有快照（建议单独创建此子卷，挂载于 `/.snapshots`）

具体创建 和 挂载步骤 可参考我的开源仓库open中的
[《001_安装_Arch_Linux.md》的 “btrfs 文件系统” 章节](https://gitee.com/wudixianxin/open/blob/main/001_安装_Arch_Linux.md)

## 快照与备份、恢复

### 创建可读快照

Btrfs 快照分为“可读快照”（ readonly ）和“可写快照”（默认），日常备份建议创建**可读快照**（加 `-r` 参数），避免误修改快照内容。

```bash
# 创建根目录（@子卷）的可读快照，命名格式建议包含日期+用途
sudo btrfs subvolume snapshot -r / /.snapshots/20250816_root_snap

# 创建/home（@home子卷）的可读快照
sudo btrfs subvolume snapshot -r /home /.snapshots/20250816_home_snap
```

成功执行后会显示类似提示：

```
create readonly snapshot of '/' in '/.snapshots/20250816_root_snap'
create readonly snapshot of '/home' in '/.snapshots/20250816_home_snap'
```

### 从快照中恢复

当系统出现问题（如误删文件、软件冲突）时，可通过快照恢复到之前的状态。
**操作前建议先通过 `sudo btrfs subvolume list /` 确认子卷和快照的路径，避免误操作**。

#### 步骤

1. **进入 Arch Linux 安装镜像**  
   重启电脑，通过 Arch ISO 启动盘进入 live 环境（无需联网，ISO 自带 Btrfs 工具）。

2. **挂载 Btrfs 分区**  
   假设你的 Btrfs 分区为 `/dev/nvme0n1p2`（可通过 `lsblk` 确认），挂载到 `/mnt`：

   ```bash
   mount /dev/nvme0n1p2 /mnt
   ```

3. **恢复根目录（@子卷）**  
   - 先删除损坏的 `@` 子卷（若删除失败，需先清空子卷内容）：

     ```bash
     # 尝试直接删除
     btrfs subvolume delete /mnt/@

     # 若报错 "ERROR: Could not destroy subvolume/snapshot: Directory not empty"
     rm -rf /mnt/@/*  # 谨慎！确保目标是待删除的@子卷，而非其他重要数据
     btrfs subvolume delete /mnt/@
     ```

   - 从快照重建 `@` 子卷：

     ```bash
     # 假设快照路径为 /mnt/@snapshots/20250816_root_snap（需根据实际快照位置调整）
     btrfs subvolume snapshot /mnt/@snapshots/20250816_root_snap /mnt/@
     ```

4. **恢复 /home（@home子卷）**  
   同理操作 `@home` 子卷：

   ```bash
   # 删除损坏的@home子卷
   btrfs subvolume delete /mnt/@home

   # 从快照重建@home子卷
   btrfs subvolume snapshot /mnt/@snapshots/20250816_home_snap /mnt/@home
   ```

5. **重启系统**  
   恢复完成后直接重启即可，无需修改 `fstab`（子卷挂载路径未变）：

   ```bash
   reboot
   ```

### 导出快照为备份文件

通过 `btrfs send` 可将快照导出为独立的备份文件（二进制数据流），便于存储到外部设备或远程服务器。

```bash
# 导出根目录快照为备份文件
sudo btrfs send /.snapshots/20250816_root_snap > /.snapshots/20250816_root.btrfs

# 导出/home快照为备份文件
sudo btrfs send /.snapshots/20250816_home_snap > /.snapshots/20250816_home.btrfs
```

#### 增量备份（节省空间）

若后续需备份，可基于已有快照创建新快照，再通过 `-p` 参数导出差异部分（仅存储变化的数据）：

```bash
# 1. 基于旧快照创建新快照（以根目录为例）
sudo btrfs subvolume snapshot -r / /.snapshots/20250817_root_snap

# 2. 导出增量备份（-p 指定前序快照）
sudo btrfs send -p /.snapshots/20250816_root_snap /.snapshots/20250817_root_snap > /.snapshots/20250817_root_incremental.btrfs
```

### 挂载快照（查看/提取文件）

若无需恢复整个系统，仅需查看快照中的文件或提取单个文件，可直接挂载快照：

```bash
# 1. 创建挂载点
sudo mkdir -p /mnt/btrfs_snap

# 2. 查看所有子卷和快照（确认快照路径）
sudo btrfs subvolume list /

# 3. 挂载快照（以20250816_root_snap为例，btrfs 分区为/dev/nvme0n1p2）
sudo mount -t btrfs -o subvol=@snapshots/20250816_root_snap /dev/nvme0n1p2 /mnt/btrfs_snap

# 4. 操作完成后取消挂载
sudo umount /mnt/btrfs_snap
```

挂载后可通过 `/mnt/btrfs_snap` 访问快照中的文件，直接复制所需内容即可。

### 删除快照

若快照不再需要，可通过 `btrfs subvolume delete` 命令删除（**删除后无法恢复，需谨慎**）：

```bash
# 格式：sudo btrfs subvolume delete 快照实际路径
sudo btrfs subvolume delete /.snapshots/20250816_root_snap
```

### 从备份文件中恢复

若已将快照导出为 `.btrfs` 备份文件（如迁移系统、硬盘更换场景），可通过 `btrfs receive` 命令恢复：

#### 恢复步骤

1. **准备目标分区**  
   确保目标 Btrfs 分区已挂载（假设挂载于 `/mnt`），并创建用于接收恢复数据的子卷：

   ```bash
   # 创建临时子卷用于接收恢复数据（例如恢复根目录快照）
   sudo btrfs subvolume create /mnt/@_restore
   ```

2. **恢复备份文件**  
   使用 `btrfs receive` 将备份文件导入到目标子卷：

   ```bash
   # 格式：cat 备份文件 | sudo btrfs receive 目标子卷路径
   cat /.snapshots/20250816_root.btrfs | sudo btrfs receive /mnt/@_restore
   ```

3. **增量备份的接收顺序**  
   如果是恢复增量备份（使用 `-p` 参数生成的），必须**先恢复基础快照，再按顺序恢复增量快照**，否则会报错。

   例如：

   ```bash
   # 先恢复基础快照
   cat /.snapshots/20250816_root.btrfs | sudo btrfs receive /mnt

   # 再恢复基于它的增量快照
   cat /.snapshots/20250817_root_incremental.btrfs | sudo btrfs receive /mnt
   ```

4. **替换原子卷**  
   恢复完成后，删除原损坏的子卷，将恢复的子卷重命名为原名称（如 `@`）：

   ```bash
   # 删除原@子卷（需先确保未挂载，建议在live环境操作）
   sudo btrfs subvolume delete /mnt/@

   # 将恢复的子卷重命名为@
   sudo btrfs subvolume rename /mnt/@_restore /mnt/@
   ```

5. **重启系统**  
   确认子卷名称正确后，重启即可完成恢复。

**注意事项**：  

- 操作前务必确认快照/子卷路径正确，避免误删重要数据。  
- 备份文件建议存储在非系统分区或外部设备，防止系统分区故障导致备份丢失。  
- 定期清理无用快照，避免占用过多存储空间（可通过 `btrfs filesystem df /` 查看空间使用情况）。
