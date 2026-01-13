# 配置方案

```toml
[profile.dev]
debug = true                # 保留调试信息
incremental = true          # 启用增量编译
codegen-units = 16          # 多单元并行编译
opt-level = 0               # 不优化（加速编译）

[profile.release]
debug = false               # 移除调试信息
incremental = false         # 禁用增量编译（节省磁盘空间）
codegen-units = 1           # 最大优化
opt-level = 3               # 最高优化级别
strip = true                # 剥离符号表
lto = "fat"                 # 链接时优化
```

```bash
cargo install sccache
# paru -S sccache
cargo install cargo-chef
```

```bash
# 初始化或依赖变更时
cargo chef prepare --recipe-path recipe.json
cargo chef cook --recipe-path recipe.json

# 日常开发
cargo build  # 快速增量编译
```

```bash
# 生成食谱文件
cargo chef prepare --recipe-path recipe.json
# 预编译依赖
cargo chef cook --release --recipe-path recipe.json
# 正常编译项目
cargo build --release
```

## sccache使用方法

```fish
# 本地环境
# 清除现有缓存（可选）
sccache --clear
# 首次编译（会生成缓存）
cargo build --release
# 再次编译（应该命中缓存）
cargo clean && cargo build --release
# 查看缓存统计
sccache --show-stats

# CI 环境
# 1. 显式启动服务（可选）
sccache --start-server
# 2. 执行编译任务
cargo build --release
# 3. 显式停止服务（可选）
sccache --stop-server
```

## fish环境

```fish
# 使用 sccache 包装 Rust 编译器
set -x RUSTC_WRAPPER sccache
# 自定义缓存目录（可选）
set -x SCCACHE_DIR "$HOME/.cache/sccache"
# 增大缓存上限（默认 10GB，根据磁盘空间调整）
set -x SCCACHE_CACHE_SIZE 20G
# 使用 zstd 压缩（比默认的 lz4 压缩率更高，但稍慢）
set -x SCCACHE_COMPRESSION zstd
# 可选：禁用分布式存储（若不需要）
set -x SCCACHE_NO_DISTRIBUTED 1
# 限制 sccache 内存使用
set -x SCCACHE_IDLE_TIMEOUT 3600 # 1小时无活动后自动关闭
set -x SCCACHE_MAX_STORES 100 # 限制并发存储操作数
```

## 开发环境配置

```toml
# Cargo.toml（开发 profile）

[profile.dev]
debug = true                # 保留调试信息
incremental = true          # 启用增量编译
codegen-units = 16          # 多单元并行编译
opt-level = 0               # 不优化（加速编译）
```

工作流：

```bash
# 初始化或依赖变更时
cargo chef prepare --recipe-path recipe.json
cargo chef cook --recipe-path recipe.json

# 日常开发
cargo build  # 快速增量编译
```

## 发布环境配置

```fish
# CI 环境配置
set -x SCCACHE_GHA_ENABLED true  # 启用 GitHub Actions 缓存
set -e SCCACHE_GHA_ENABLED
```

```toml
# Cargo.toml（发布 profile）

[profile.release]
debug = false               # 移除调试信息
incremental = false         # 禁用增量编译（节省磁盘空间）
codegen-units = 1           # 最大优化
opt-level = 3               # 最高优化级别
strip = true                # 剥离符号表
lto = "fat"                 # 链接时优化
```

工作流：

```bash
# 生成食谱文件
cargo chef prepare --recipe-path recipe.json
# 预编译依赖
cargo chef cook --release --recipe-path recipe.json
# 正常编译项目
cargo build --release
```
