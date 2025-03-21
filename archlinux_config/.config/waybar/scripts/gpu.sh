#!/bin/bash

# 获取原始数据（新增处理千分位逗号）
gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits | tr -d ',')

# 数据解析（更健壮的字段分割方式）
IFS=', ' read -ra data <<<"$gpu_data"
gpu_usage=${data[0]}
mem_used=${data[1]}
mem_total=${data[2]}
gpu_temp=${data[3]}

# 显存百分比计算（兼容无bc环境）
if command -v bc >/dev/null 2>&1; then
  mem_percent=$(echo "scale=1; 100*$mem_used/$mem_total" | bc)
else
  mem_percent=$((100 * mem_used / mem_total)) # 整数计算后备方案
fi

# 格式化输出（修复空值情况）
printf "   %s%%   %s%%  %s°C\n" "${gpu_usage:-0}" "${mem_percent:-0}" "${gpu_temp:-0}"
