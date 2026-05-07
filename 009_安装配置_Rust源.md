# 配置 Rust

## Rustup 镜像源

使用字节跳动的 RsProxy

```bash
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
```

## 安装 Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf <https://rsproxy.cn/rustup-init.sh> | sh
```

## Cargo 镜像源

编写~/.cargo/config.toml文件

```toml
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
```
