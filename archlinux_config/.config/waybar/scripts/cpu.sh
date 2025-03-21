#!/bin/bash
# CPU使用率（取总使用率）
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
# CPU温度（需根据传感器名称调整）
cpu_temp=$(sensors | grep 'Package id 0' | awk '{print $4}' | sed 's/+//;s/°C//')
echo "  ${cpu_usage}   ${cpu_temp}°C"
