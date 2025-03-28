#!/bin/bash
set -euo pipefail

src_config="$HOME/.config"
dest_config="archlinux_config/.config"
dest_home="archlinux_config/home"

config_dirs=(
  hypr
  hyprshot
  foot
  kitty
  nvim
  swaync
  wlogout
  backgrounds
  flameshot
)

for dir in "${config_dirs[@]}"; do
  rsync -a "$src_config/$dir/" "$dest_config/$dir"
done

rsync -a ~/bash "$dest_home/"
rsync ~/.bashrc "$dest_home/"
rsync ~/.bash_profile "$dest_home/"
rsync ~/.inputrc "$dest_home/"
