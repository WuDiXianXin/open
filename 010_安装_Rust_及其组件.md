# 安装 Rust 及其组件


## 一、安装`rustup`（基础工具）
`rustup`是 Rust 官方的工具链管理器，负责安装、切换、更新 Rust 编译器及相关组件，支持跨平台（Linux/macOS/Windows）。

### 1. 安装命令（按系统选择）
- **Linux/macOS**：
  使用`curl`或`wget`执行官方安装脚本（二选一）：
  ```bash
  # 方法1：通过curl
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
 
  # 方法2：通过wget
  wget https://sh.rustup.rs -O - | sh
  ```

- **Windows**：
  访问 [rustup 官网](https://rustup.rs/) 下载 `rustup-init.exe`，运行后按提示安装（建议勾选“添加到 PATH”）。


### 2. 环境变量生效
安装完成后，需让`~/.cargo/bin`（Rust 工具目录）加入系统 PATH：
- Linux/macOS：重启终端，或手动执行：
  ```bash
  source $HOME/.cargo/env
  ```
- Windows：安装时若已勾选“添加到 PATH”，重启终端即可；否则需手动将 `%USERPROFILE%\.cargo\bin` 添加到系统环境变量。


## 二、核心工具链（`rustc`、`cargo`等）
`rustup`默认安装**最新稳定版（stable）工具链**，包含以下核心工具（无需额外操作）：
- `rustc`：Rust 编译器，将源代码编译为可执行文件/库；
- `cargo`：包管理器，负责项目创建（`cargo new`）、构建（`cargo build`）、测试（`cargo test`）、依赖管理等；
- `rustdoc`：文档生成工具（`cargo doc` 生成 HTML 文档）；
- `rustfmt`/`cargo-fmt`：代码格式化工具（`cargo fmt` 自动调整代码风格）；
- `clippy`/`cargo-clippy`：代码检查工具（`cargo clippy` 检测潜在错误、风格问题）。


### 补充：工具链版本管理
Rust 工具链分三种渠道，可按需切换：
```bash
rustup install stable   # 稳定版（默认，推荐生产环境）
rustup install beta     # 测试版（提前体验新特性）
rustup install nightly  #  nightly版（包含最新实验特性，适合开发工具）

# 切换默认工具链
rustup default nightly  # 临时切换到nightly（部分工具如miri依赖）
```


## 三、额外组件（语言服务器、调试工具等）
以下组件需手动安装（部分依赖特定工具链，如`miri`需`nightly`）：

| 组件用途                | 安装命令                                  | 说明                                  |
|-------------------------|-------------------------------------------|---------------------------------------|
| 现代语言服务器（推荐）  | `rustup component add rust-analyzer`      | 为 IDE 提供补全、跳转等功能，替代 RLS |
| Rust 标准库的源代码  | `rustup component add rust-src`                | rust-src 是提升 Rust 开发体验（尤其是 IDE 集成）的重要组件 |
| GDB 调试适配            | `rustup component add rust-gdb`           | 配合 GDB 调试 Rust 程序               |
| LLDB 调试适配            | `rustup component add rust-lldb`          | 配合 LLDB 调试 Rust 程序（macOS 推荐）|
| 内存安全调试器          | `rustup component add miri`               | 需切换到 nightly 工具链（`rustup default nightly`） |


### 注意：
- `clippy`和`rustfmt`在`stable`工具链中默认已安装，无需重复执行`rustup component add`；
- 若安装失败（如网络问题），可尝试更换镜像源（参考 [Rust 镜像配置](https://mirrors.tuna.tsinghua.edu.cn/help/rustup/)）。


## 四、VS Code 配置（跨平台）
除基础扩展外，推荐安装以下工具提升开发体验：

```bash
# 核心扩展：Rust 语言支持（基于rust-analyzer）
code --install-extension rust-lang.rust-analyzer

# 调试扩展：支持LLDB调试（Windows/Linux/macOS通用）
code --install-extension vadimcn.vscode-lldb

# 依赖管理：显示Cargo依赖版本信息
code --install-extension serayuzgur.crates

# 代码提示：增强类型/文档提示
code --install-extension belfz.search-crates-io
```


## 五、Cargo 子命令（扩展工具）
通过`cargo install`安装扩展工具（需系统基础依赖，如`gcc`、`libssl-dev`等）：

| 工具用途                  | 安装命令                                  | 常用场景                              |
|---------------------------|-------------------------------------------|---------------------------------------|
| Docker 构建优化           | `cargo install cargo-chef`                | 加速 Rust 项目的 Docker 镜像构建      |
| Tauri 桌面应用开发        | `cargo install create-tauri-app tauri-cli`| 创建跨平台桌面应用（`cargo tauri dev`）|
| 依赖管理便捷工具          | `cargo install cargo-edit`                | 直接修改`Cargo.toml`（`cargo add 依赖`）|
| 检查依赖更新              | `cargo install cargo-outdated`            | 查看可更新的依赖（`cargo outdated`）  |
| 批量更新子命令            | `cargo install cargo-update`              | 一键更新所有已安装的子命令（`cargo install-update -a`） |


### 注意：
- 安装前确保系统已安装编译依赖（如 Linux 需`build-essential`，macOS 需`Xcode Command Line Tools`）；
- 部分工具（如`tauri-cli`）可能需要额外系统库（参考 [Tauri 环境要求](https://tauri.app/v1/guides/getting-started/prerequisites/)）。


## 六、验证与更新
### 验证安装
```bash
rustup --version       # 检查rustup版本
rustc --version        # 检查编译器版本
cargo --version        # 检查包管理器版本
rust-analyzer --version  # 检查语言服务器
cargo clippy --version   # 检查代码检查工具
```


### 更新工具
```bash
rustup update          # 更新所有已安装的工具链和组件
cargo install --force <工具名>  # 更新单个cargo子命令（如cargo install --force cargo-chef）
cargo install-update -a  # 批量更新所有cargo子命令（需先安装cargo-update）
```


## 七、常见问题
1. **安装失败**：检查网络连接，或配置国内镜像（如清华镜像）；
2. **命令未找到**：确认`~/.cargo/bin`已加入 PATH，或重启终端；
3. **miri 无法运行**：切换到 nightly 工具链（`rustup default nightly`）；
4. **VS Code 无提示**：确保`rust-analyzer`扩展已启用，且项目根目录有`Cargo.toml`。
