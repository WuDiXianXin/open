#!/bin/bash
set -euo pipefail # 启用严格错误检查

# ======================
# 配置恢复主逻辑
# ======================
src_config="$HOME/git/open/archlinux_config/.config" # 仓库中的配置源
dest_config="$HOME/.config"                          # 系统配置目录
font_source="$HOME/git/open/archlinux_config/fonts"  # 字体文件源
font_dest="/usr/share/fonts"                         # 系统字体目录

# ======================
# 交互式确认机制
# ======================
echo "即将执行以下操作："
echo "1. 恢复 .config 目录配置 (hypr/waybar/nvim 等)"
echo "2. 覆盖用户家目录的 .bashrc"
echo "3. 安装 Maple 字体到系统目录"
read -p "确认执行配置恢复？(y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# ======================
# 配置文件同步模块
# ======================
config_dirs=(
  hypr hyprshot foot kitty nvim waybar
  swaync wlogout backgrounds flameshot
)

echo -e "\n\033[32m[ 正在恢复配置文件 ]\033[0m"
for dir in "${config_dirs[@]}"; do
  echo "▸ 同步 $dir 配置..."
  rsync -a --stats --human-readable "$src_config/$dir/" "$dest_config/$dir"
done

# ======================
# Bashrc 恢复模块
# ======================
echo -e "\n\033[32m[ 恢复 Shell 配置 ]\033[0m"
if [[ -f "$dest_config/home/.bashrc" ]]; then
  cp -v "$src_config/home/.bashrc" ~/.bashrc
else
  echo "⚠️  未找到 .bashrc 备份文件"
fi

# ======================
# 字体安装模块
# ======================
echo -e "\n\033[32m[ 安装字体文件 ]\033[0m"
if [[ -d "$font_source" ]]; then
  sudo rsync -a "$font_source/" "$font_dest/"
  sudo fc-cache -f -v
  echo "✅ 字体缓存已刷新"
else
  echo "⚠️  字体目录不存在: $font_source"
fi

echo -e "\n\033[34m恢复完成！建议注销后重新登录使配置生效\033[0m"
