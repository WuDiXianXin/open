---
### 🌐 手机给其他设备共享代理流量的配置说明
---

#### 一、查看手机网络信息

**1. 通过WiFi局域网连接时**  
_(手机和其他设备在同一个WiFi下)_  
• **手机端（Termux中运行）**

```bash
ifconfig  # 查看手机的局域网IP（如192.168.5.243）
```

• **连接的设备（Linux系统）**

```bash
nmcli d show | grep IP4  # 查看当前连接的路由信息
```

_需绕过的地址范围：_ `192.168.5.0/24`（同一局域网段）和默认路由 `0.0.0.0/0`

---

**2. 通过手机热点连接时**  
_(手机开启热点，设备连接热点)_  
• **手机端（Termux中运行）**

```bash
ifconfig  # 查看热点的IP（如192.168.205.21）
```

_提示：关闭/重开热点后需重新查看IP_  
• **连接的设备（Linux系统）**

```bash
nmcli d show | grep IP4  # 确认网关地址（即手机热点IP）
```

_需绕过的地址范围：_ `192.168.205.0/24` 和默认路由 `0.0.0.0/0`

---

#### 二、设置代理环境变量

**操作步骤（Linux设备执行）：**

1. **关闭其他代理设置**  
   _在NetworkManager中关闭WiFi代理或设为空_
2. **根据连接方式配置代理**  
   • **WiFi局域网模式**

   ```fish
   set -gx http_proxy "http://192.168.5.243:17890"  # 手机局域网IP+端口
   set -gx https_proxy "$http_proxy"
   set -gx all_proxy "socks5://192.168.5.243:17891"
   set -gx no_proxy "192.168.5.0/24,localhost,127.0.0.1,::1"  # 排除内网地址
   ```

   • **手机热点模式**

   ```fish
   set -gx http_proxy "http://192.168.205.21:17890"  # 手机热点IP+端口
   set -gx https_proxy "$http_proxy"
   set -gx all_proxy "socks5://192.168.205.21:17891"
   set -gx no_proxy "192.168.205.0/24,localhost,127.0.0.1,::1"
   ```

   _注：端口号需与手机端代理软件（如Clash）的监听端口一致_

---

#### 三、切换WiFi网络示例

```fish
# 断开当前网络
nmcli connection down rd

# 连接新WiFi（如热点名称"DaAiShiJian"）
nmcli d wifi connect DaAiShiJian
```

\_提示：可能需要输入WiFi密码(在d前面加上--ask参数)

---

### 📝 补充说明

1. **代理生效验证**

```fish
# linux 设备
curl -x $http_proxy ifconfig.me
curl --socks5 $all_proxy ifconfig.me
```

2. **常见问题**  
   • _代理不生效_：检查IP和端口是否正确，或尝试重启网络服务  
   • _无法连接热点_：确保手机已开启热点共享功能
3. **安全提示**  
   建议使用加密代理协议（如SOCKS5）并避免使用免费代理

---
