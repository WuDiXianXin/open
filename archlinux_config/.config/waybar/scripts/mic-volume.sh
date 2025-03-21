#!/bin/bash

# 获取音频输入设备的音量信息
volume_data=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

# 提取音量百分比并格式化
volumet=$(echo "$volume_data" | awk '/Volume: ([0-9.]+)/ { printf "%.0f", $2 * 100 }')

# 检查是否静音
if echo "$volume_data" | rg -q '\[MUTED\]'; then
  echo '{"text":" ", "class":"muted"}'
else
  echo "{\"text\":\" $volumet\", \"class\":\"active\"}"
fi
