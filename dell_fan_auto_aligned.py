#!/bin/python
import sys
import pexpect
import os
import logging
import time
import subprocess  # 新增：用于执行sensors/nvidia-smi命令
from patch import g15_5520_patch

class DellFanController:
    def __init__(self, auto_mode=True):
        # 1. 初始化日志
        logging.basicConfig(
            filename="/tmp/dell-fan-auto.log",
            level=logging.INFO,
            format="%(asctime)s - %(levelname)s - %(message)s"
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info("=== Dell Fan Auto Controller (对齐waybar) 启动 ===")

        # 2. 检查依赖命令（sensors/nvidia-smi，waybar也在用）
        self._check_deps()

        # 3. 检查acpi_call模块
        if not os.path.exists("/proc/acpi/call"):
            print("错误：未加载acpi_call内核模块，请先执行：sudo modprobe acpi_call")
            self.logger.error("acpi_call模块未加载，退出")
            sys.exit(1)
        self.logger.info("acpi_call模块已加载")

        # 4. 初始化shell与提权
        self.shell = pexpect.spawn('bash', encoding='utf-8', env=None, args=["--noprofile", "--norc"])
        self.shell.expect("[#$] ")
        self.shell_exec("export HISTFILE=/dev/null; history -c")
        self._sudo_elevate()
        self._init_acpi_cmds()

        # 5. 核心配置：温度-转速参数（贴合waybar阈值）
        self.temp_params = {
            "cpu": {
                "min_temp": 45,    # 低负载基础温度
                "max_temp": 85,    # 接近waybar临界90℃，留缓冲
                "min_speed": 20,   # 最低转速（避免停转导致积热）
                "max_speed": 100   # 最高转速（满速散热）
            },
            "gpu": {
                "min_temp": 45,    # 低负载基础温度
                "max_temp": 80,    # 与waybar临界80℃对齐
                "min_speed": 20,
                "max_speed": 100
            }
        }
        self.power_modes_dict = {"Manual": "0x0"}  # 强制手动模式，避免系统干扰
        self.auto_mode = auto_mode
        self.logger.info("初始化完成，进入自动控制模式")

    def _check_deps(self):
        """检查waybar依赖的命令（sensors/nvidia-smi）是否存在"""
        # 检查sensors（CPU温度）
        if not subprocess.call(["which", "sensors"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL):
            self.logger.info("依赖命令sensors已安装")
        else:
            print("错误：未安装sensors（waybar也依赖），请先执行：sudo pacman -S lm-sensors")
            self.logger.error("sensors未安装，退出")
            sys.exit(1)
        # 检查nvidia-smi（GPU温度，RTX 3060专用）
        if not subprocess.call(["which", "nvidia-smi"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL):
            self.logger.info("依赖命令nvidia-smi已安装")
        else:
            print("错误：未安装nvidia-smi（NVIDIA驱动组件），请先安装NVIDIA驱动")
            self.logger.error("nvidia-smi未安装，退出")
            sys.exit(1)

    def _sudo_elevate(self):
        """sudo提权（终端交互）"""
        try:
            self.shell.sendline("sudo bash --noprofile --norc")
            index = self.shell.expect(["[sudo] password for", "[#$] "], timeout=10)
            if index == 0:
                password = input("请输入sudo密码：")
                self.shell.sendline(password)
                self.shell.expect("[#$] ", timeout=10)
        except pexpect.TIMEOUT:
            print("提权超时，密码错误？")
            self.logger.error("sudo提权超时")
            sys.exit(1)
        if "root" not in self.shell_exec("whoami")[1]:
            print("提权失败，需root权限控制风扇")
            self.logger.error("提权失败")
            sys.exit(1)
        self.logger.info("sudo提权成功")

    def _detect_laptop_model(self):
        """识别G15 5520并加载补丁"""
        self.model = "Unknown"
        temp_acpi_cmd = "echo \"\\_SB.AMWW.WMAX 0 {} {{{}, {}, {}, 0x00}}\" | tee /proc/acpi/call; cat /proc/acpi/call"
        original_acpi_cmd = self.acpi_cmd
        self.acpi_cmd = temp_acpi_cmd

        laptop_model = self.acpi_call("get_laptop_model")
        if laptop_model == "0x12c0":
            self.model = "G15 5520 (Intel i7-12700H + RTX 3060)"
            g15_5520_patch(self)
            print(f"✅ 已识别机型：{self.model}，加载专属补丁")
            self.logger.info(f"识别机型：{self.model}")
            return

        self.acpi_cmd = original_acpi_cmd
        print(f"⚠️  未识别机型（返回值{laptop_model}），继续尝试（风险）")
        self.logger.warning(f"未识别机型，返回值{laptop_model}")

    def _init_acpi_cmds(self):
        """初始化ACPI命令（含机型检测）"""
        self.acpi_cmd = "echo \"\\_SB.AMWW.WMAX 0 {} {{{}, {}, {}, 0x00}}\" | tee /proc/acpi/call; cat /proc/acpi/call"
        self.acpi_call_dict = {
            "set_fan1_boost": ["0x15", "0x02", "0x32"],  # CPU风扇（0x32）
            "set_fan2_boost": ["0x15", "0x02", "0x33"],  # GPU风扇（0x33）
            "get_fan1_rpm": ["0x14", "0x05", "0x32"],    # 读CPU转速
            "get_fan2_rpm": ["0x14", "0x05", "0x33"],    # 读GPU转速
            "get_laptop_model": ["0x1a", "0x02", "0x02"],# 读机型
            "set_power_mode": ["0x15", "0x01"]           # 设电源模式
        }
        self._detect_laptop_model()

    def shell_exec(self, cmd):
        """执行shell命令并返回结果"""
        self.logger.debug(f"执行shell命令：{cmd}")
        self.shell.sendline(cmd)
        self.shell.expect("[#$] ")
        return self.shell.before.split('\n')

    def acpi_call(self, cmd, value=0):
        """发送ACPI命令控制硬件"""
        try:
            args = self.acpi_call_dict[cmd]
        except KeyError:
            print(f"错误：无效ACPI命令「{cmd}」")
            self.logger.error(f"无效ACPI命令：{cmd}")
            return ""

        hex_val = f"0x{value:02X}"
        cmd_str = self.acpi_cmd.format(args[0], args[1], args[2], hex_val)
        try:
            result = self.shell_exec(cmd_str)
        except Exception as e:
            print(f"ACPI命令失败：{e}")
            self.logger.error(f"ACPI命令{cmd}失败：{e}")
            return ""

        if len(result) < 3:
            print(f"ACPI命令「{cmd}」结果不完整")
            self.logger.warning(f"ACPI命令{cmd}结果不完整")
            return ""
        return result[2].split('\r')[-1].split('\x00')[0].strip()

    def get_cpu_temp(self):
        """读取CPU温度（与waybar完全一致：sensors coretemp-isa-0000 Package id 0）"""
        try:
            # 执行waybar同款命令，提取Package id 0的温度
            result = subprocess.check_output(
                ["sensors", "coretemp-isa-0000"],
                encoding="utf-8",
                stderr=subprocess.STDOUT
            )
            # 用waybar同款awk逻辑解析（去除+°C，保留1位小数）
            for line in result.split('\n'):
                if "Package id 0" in line:
                    parts = line.strip().split()
                    temp_str = parts[3].replace('+', '').replace('°C', '')
                    return round(float(temp_str), 1)
            self.logger.error("未找到CPU Package id 0温度")
            return None
        except Exception as e:
            print(f"读取CPU温度失败：{e}")
            self.logger.error(f"读取CPU温度失败：{e}")
            return None

    def get_gpu_temp(self):
        """读取GPU温度（与waybar完全一致：nvidia-smi --query-gpu=temperature.gpu）"""
        try:
            # 执行waybar同款命令，避免格式差异
            result = subprocess.check_output(
                ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"],
                encoding="utf-8",
                stderr=subprocess.STDOUT
            )
            temp = round(float(result.strip()), 1)
            return temp
        except Exception as e:
            print(f"读取GPU温度失败：{e}")
            self.logger.error(f"读取GPU温度失败：{e}")
            return None

    def calculate_fan_speed(self, temp, component="cpu"):
        """按正比例计算目标转速（贴合waybar阈值）"""
        if temp is None:
            return None

        params = self.temp_params[component]
        # 温度低于最小值：用最低转速
        if temp <= params["min_temp"]:
            return params["min_speed"]
        # 温度高于最大值：用最高转速
        elif temp >= params["max_temp"]:
            return params["max_speed"]
        # 中间温度：正比例计算（(temp - min_temp)/(max_temp - min_temp) * 转速范围 + min_speed）
        else:
            ratio = (temp - params["min_temp"]) / (params["max_temp"] - params["min_temp"])
            speed = params["min_speed"] + ratio * (params["max_speed"] - params["min_speed"])
            return round(speed)  # 取整，避免小数转速

    def set_fan_speed(self, fan_id, speed):
        """设置风扇转速（含参数校验）"""
        if fan_id not in [1, 2]:
            print(f"错误：无效风扇ID「{fan_id}」（仅支持1=CPU/2=GPU）")
            self.logger.error(f"无效风扇ID：{fan_id}")
            return
        if not (0 <= speed <= 100):
            print(f"错误：转速「{speed}%」无效（需0-100）")
            self.logger.error(f"无效转速：{speed}%")
            return

        # 强制切换到手动模式，避免系统自动调速覆盖
        self.acpi_call("set_power_mode", self.power_modes_dict["Manual"])
        # 计算Boost值（0-100% → 0-255）
        boost_val = int(speed * 255 / 100)
        cmd = "set_fan1_boost" if fan_id == 1 else "set_fan2_boost"
        self.acpi_call(cmd, boost_val)

        fan_type = "CPU" if fan_id == 1 else "GPU"
        print(f"✅ {fan_type}风扇：{speed}%（Boost值：{boost_val:02X}）")
        self.logger.info(f"{fan_type}风扇设置：{speed}%（Boost={boost_val:02X}）")

    def get_fan_rpm(self, fan_id):
        """读取风扇当前转速（用于显示）"""
        if fan_id not in [1, 2]:
            print(f"错误：无效风扇ID「{fan_id}」")
            return None

        cmd = "get_fan1_rpm" if fan_id == 1 else "get_fan2_rpm"
        rpm_str = self.acpi_call(cmd)
        try:
            return int(rpm_str, 16)  # 十六进制转十进制
        except ValueError:
            print(f"❌ 读取{['CPU','GPU'][fan_id-1]}风扇转速失败")
            self.logger.error(f"读取{['CPU','GPU'][fan_id-1]}转速失败，返回值：{rpm_str}")
            return None

    def auto_control_loop(self, interval=5):
        """自动控制循环（默认5秒更新一次，与waybar刷新频率匹配）"""
        print(f"=== 自动风扇控制启动 ===")
        print(f"更新间隔：{interval}秒 | 按 Ctrl+C 退出")
        print(f"CPU温度范围：{self.temp_params['cpu']['min_temp']}℃-{self.temp_params['cpu']['max_temp']}℃ → 20%-100%转速")
        print(f"GPU温度范围：{self.temp_params['gpu']['min_temp']}℃-{self.temp_params['gpu']['max_temp']}℃ → 20%-100%转速")
        print("="*60)

        try:
            while self.auto_mode:
                # 1. 读取温度（与waybar同源）
                cpu_temp = self.get_cpu_temp()
                gpu_temp = self.get_gpu_temp()
                # 2. 计算目标转速
                cpu_speed = self.calculate_fan_speed(cpu_temp, "cpu")
                gpu_speed = self.calculate_fan_speed(gpu_temp, "gpu")
                # 3. 读取当前转速（用于显示）
                cpu_rpm = self.get_fan_rpm(1)
                gpu_rpm = self.get_fan_rpm(2)

                # 4. 显示实时状态（对齐waybar数据）
                print(f"\n[{time.strftime('%H:%M:%S')}]")
                print(f"CPU：{cpu_temp:5.1f}℃ → 目标{cpu_speed:3d}% | 当前{cpu_rpm:5d} RPM" if cpu_temp and cpu_speed else "CPU：温度读取失败")
                print(f"GPU：{gpu_temp:5.1f}℃ → 目标{gpu_speed:3d}% | 当前{gpu_rpm:5d} RPM" if gpu_temp and gpu_speed else "GPU：温度读取失败")

                # 5. 执行转速设置
                if cpu_speed:
                    self.set_fan_speed(1, cpu_speed)
                if gpu_speed:
                    self.set_fan_speed(2, gpu_speed)

                # 等待下一次更新（与waybar刷新频率同步，避免频繁操作）
                time.sleep(interval)

        except KeyboardInterrupt:
            print("\n=== 用户中断，退出自动控制 ===")
            self.logger.info("用户按Ctrl+C退出")
        except Exception as e:
            print(f"\n=== 控制异常：{e} ===")
            self.logger.error(f"自动控制异常：{e}")

if __name__ == "__main__":
    try:
        # 启动自动控制（间隔5秒，与waybar默认刷新频率一致）
        controller = DellFanController(auto_mode=True)
        controller.auto_control_loop(interval=5)
    except Exception as e:
        print(f"脚本启动失败：{e}")
        logging.error(f"脚本启动失败：{e}")
        sys.exit(1)
