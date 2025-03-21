#!/bin/bash
set -euo pipefail # 启用严格错误检查

# 定义常量路径
src_config="$HOME/.config"
dest_config="$HOME/git/open/archlinux_config/.config"
dest_home="$HOME/git/open/archlinux_config/home"

# 需要备份的.config目录列表
config_dirs=(
  hypr
  hyprshot
  foot
  kitty
  nvim
  waybar
  swaync
  wlogout
  backgrounds
  flameshot
)

# 批量备份.config目录
for dir in "${config_dirs[@]}"; do
  rsync -a --stats --human-readable "$src_config/$dir/" "$dest_config/$dir"
done

# 备份.bashrc（添加校验和检测）
rsync -a --checksum ~/.bashrc "$dest_home/"
