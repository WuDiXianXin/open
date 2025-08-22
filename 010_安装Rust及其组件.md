# 安装 Rust 及其组件

## 一、安装`rustup`（基础工具）

首先需要安装`rustup`，它是Rust的工具链管理器，通过它可以安装和管理所有Rust相关工具。

1. 打开终端，执行以下命令：
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
2. 另外一种命令：
```bash
wget https://sh.rustup.rs -O - | sh
```

按照提示选择安装模式（默认推荐`1`），安装完成后，重启终端或执行以下命令使环境变量生效：
```bash
source $HOME/.cargo/env
```


## 二、安装核心工具（`rustc`、`cargo`等）
`rustup`默认会安装最新稳定版的Rust工具链，包括：
- `rustc`（Rust编译器）
- `cargo`（Rust包管理器）
- `rustdoc`（文档生成工具）
- `rustfmt`（代码格式化工具，对应`cargo-fmt`）
- `clippy-driver`（`cargo-clippy`的驱动，代码检查工具）

`使用 1 方法安装后默认都有，无需执行以下部分。`

如果需要确认或重新安装，执行：
```bash
rustup install stable  # 安装稳定版工具链（包含上述核心工具）
```

## 三、安装额外组件（`rust-analyzer`、`rls`等）
以下工具在 Linux标准版 中皆有，无需安装：

```bash
# 代码分析/IDE支持
rustup component add rust-analyzer  # 现代Rust语言服务器（推荐）
rustup component add rls            # Rust语言服务器（旧版，可选）

# 调试工具
rustup component add rust-gdb       # GDB调试器的Rust适配
rustup component add rust-gdbgui    # GDB的图形界面调试工具
rustup component add rust-lldb      # LLDB调试器的Rust适配

# 其他工具
rustup component add clippy         # 对应cargo-clippy（代码检查）
rustup component add rustfmt        # 对应cargo-fmt（代码格式化）
rustup component add miri           # 对应cargo-miri（Rust解释器/调试工具）
```


## 四、安装cargo子命令（`cargo-chef`、`tauri`相关等）
以下工具是`cargo`的扩展子命令，通过`cargo install`安装：

```bash
# 项目构建相关
cargo install cargo-chef  # 用于优化Docker构建缓存的工具

# Tauri相关（跨平台桌面应用开发）
cargo install create-tauri-app  # 快速创建Tauri项目（对应cargo-create-tauri-app）
cargo install tauri-cli         # Tauri命令行工具（对应cargo-tauri）
```


## 五、验证安装
安装完成后，可以通过以下命令验证：
```bash
rustc --version    # 检查rustc版本
cargo --version    # 检查cargo版本
cargo clippy --version  # 检查clippy
rust-analyzer --version  # 检查rust-analyzer
```

如果需要更新所有工具，执行：
```bash
rustup update  # 更新rustup及所有已安装组件
cargo install --force <工具名>  # 强制更新某个cargo子命令（如cargo-chef）
```


通过以上步骤，你可以在Linux系统上安装并管理所有列出的Rust相关工具。`rustup`会自动处理依赖关系，并允许你在不同版本的工具链之间切换（如稳定版、测试版、 nightly 版）。
