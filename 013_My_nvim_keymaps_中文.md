# My Neovim 快捷键配置完整梳理

> 本文档由 **WuDiXianXin** 整理，感谢 Grok AI 协助梳理与排版。

关于 Neovim 原生 keymap 配置请参考 `:help index`，其中列出了所有内置默认快捷键（包括普通模式、插入模式、可视模式、命令行模式等）。
如果想查看特定模式的键位，可使用 `:help normal-mode-index`、`:help insert-index`、`:help visual-index` 等命令。
(如果你感兴趣也可以使用 `:h map` 或 `:h keymap` 或 `:h keymaps`)

我的 Neovim 配置以模块化、简洁为原则，主要快捷键分布在以下几个地方：

- **全局通用键位**：`lua/config/keymaps.lua`
- **Rust 专用增强**：`after/ftplugin/rust.lua`（仅 Rust 文件生效，会覆盖部分全局键位以使用 rustaceanvim 更强大功能）
- **Lua 开发专用**：`after/ftplugin/lua.lua`（仅 Lua 文件生效）
- **插件内部键位**：DAP、crates.nvim、gitsigns.nvim、treesitter-textobjects、markview.nvim 等

下面按功能分类，完整列出所有快捷键（包含键位、作用描述及来源），方便查阅和分享。

### 1. 全局通用键位（lua/config/keymaps.lua）
适用于所有 buffer（除非被 ftplugin 覆盖）。

| 键位              | 作用描述                                   | 备注 / 来源                  |
|-------------------|--------------------------------------------|------------------------------|
| `<leader>`        | 主 Leader 键（空格）                       | 全局前缀                     |
| `<CR>`            | 禁用回车默认功能                           | 避免误触                     |
| `<C-s>`           | 纯净保存文件（支持插入/普通模式）          | 覆盖系统保存                 |
| `<leader>tn`      | 新建空白标签页                             | 标签页管理                   |
| `<leader>to`      | 当前窗口独立为新标签页                     |                              |
| `<leader>tc`      | 关闭当前标签页                             |                              |
| `wk` / `wj` / `wh` / `wl` | 调整窗口高度/宽度                  | 窗口操作                     |
| `wv` / `ws`       | 垂直/水平分屏                              |                              |
| `wd`              | 关闭当前窗口                               |                              |
| `gh`/`gl`/`gk`/`gj` | 切换到左/右/上/下窗口                    |                              |
| `wm`              | 当前窗口全屏/还原切换                      |                              |
| `we`              | 所有窗口等分大小                           |                              |
| `<C-d>` / `<C-u>` | 向下/上半屏并居中                          | 滚动居中                     |
| `n` / `N`         | 下一个/上一个搜索结果并居中展开            | 搜索导航                     |
| `x` / `X`         | 删除字符/前字符（不污染寄存器）            | 安全删除                     |
| `dd` / `D`        | 删除行/到行尾（不污染寄存器）              |                              |
| `d` (v)           | 视觉模式删除（不污染寄存器）               |                              |
| `kj` (i)          | 快速退出插入模式                           | 插入模式                     |
| `<leader>cp`      | 替换全文为剪贴板内容                       | 替换操作                     |
| `<A-k>` / `<A-j>` | 当前行上/下移并自动缩进                    | 行移动                       |
| `<A-k>` / `<A-j>` (v) | 选中行上/下移并自动缩进                |                              |
| `t` / `T`         | 水平/垂直分屏打开终端                      | 终端                         |
| `<leader>bb`      | 切换到交替缓冲区                           | 缓冲区管理                   |
| `<leader>bp` / `<leader>bn` | 上/下一个缓冲区                  |                              |
| `<leader>bd` / `<leader>bD` | 删除/强制删除当前缓冲区          |                              |
| `<C-l>`           | 清除搜索高亮                               | 显示切换                     |
| `<leader>ws`      | 切换空白字符显示                           |                              |
| `<leader>d`       | 查看当前行诊断（浮动窗口，不聚焦）         | 诊断 & LSP                   |
| `<leader>D`       | 查看当前行诊断（浮动窗口，可聚焦）         |                              |
| `<leader>q`       | 所有诊断填充到位置列表                     |                              |
| `<leader>l`       | 打开/关闭位置列表                          |                              |
| `[l` / `]l`       | 位置列表上/下一个                          |                              |
| `[d` / `]d`       | 上/下一个诊断（安全）                      |                              |
| `K`               | 显示悬浮文档（通用 LSP hover）             | LSP 基础                     |
| `grd`             | 跳转定义                                   |                              |
| `grD`             | 跳转声明                                   |                              |
| `grr`             | 查找所有引用                               |                              |
| `gri`             | 跳转实现                                   |                              |
| `grn`             | 全局重命名                                 |                              |
| `gra`             | 代码动作（通用）                           |                              |
| `grt`             | 跳转类型定义                               |                              |
| `<leader>lf`      | 格式化当前文件                             |                              |
| `<leader>ff`      | 查找文件                                   | Mini.pick 查找               |
| `<leader>fb`      | 查找缓冲区                                 |                              |
| `<leader>fg`      | 实时文本搜索                               |                              |
| `<leader>fG`      | 静态文本搜索                               |                              |
| `<leader>fr`      | 恢复上次查找                               |                              |
| `<leader>fh`      | 搜索帮助文档                               |                              |
| `<leader>e`       | 打开文件管理器 (mini.files)                |                              |

### 2. Rust 专用增强（after/ftplugin/rust.lua）
仅在 Rust 文件中生效，**覆盖**了全局的 `K` 和 `gra`，使用 rustaceanvim 增强功能。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `gra`             | Rust: 代码动作（支持 rust-analyzer 分组）  | 覆盖全局                     |
| `K`               | Rust: 悬浮信息 + 动作（hover actions）     | 覆盖全局                     |
| `<leader>rr`      | 选择并运行 Runnable                        | 运行                         |
| `<leader>rR`      | 重跑上一个 Runnable                        |                              |
| `<leader>tt`      | 选择并运行测试                             | 测试                         |
| `<leader>tT`      | 重跑上一个测试                             |                              |
| `<leader>em`      | 递归展开宏                                 | 宏 & 结构                    |
| `<leader>jl`      | 智能连接行                                 |                              |
| `<leader>ro`      | 打开 Cargo.toml                            | Cargo & 依赖                 |
| `<leader>rc`      | 重载 Workspace                             |                              |
| `<leader>od`      | 打开 docs.rs 文档                          |                              |
| `<leader>ee`      | 循环解释错误                               | 诊断 & 错误                  |
| `<leader>rdg`     | 显示当前详细诊断                           |                              |
| `<leader>fc`      | 手动运行 flyCheck (cargo check/clippy)     |                              |
| `<leader>pm`      | 跳转到父模块                               | 导航                         |
| `<!-- <leader>vh / <leader>vm / <leader>st` --> | 查看 HIR / MIR / 语法树（已注释） | 高级视图（需 nightly）       |

### 3. Lua 开发专用（after/ftplugin/lua.lua）
仅 Lua 文件生效，非常适合配置调试。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `<space>X`        | 加载（source）当前 Lua 文件                | 最常用                       |
| `<space>x` (n)    | 运行当前行 Lua 代码（带错误提示）          |                              |
| `<space>x` (v)    | 运行选中的 Lua 代码                        |                              |
| `<space>p` (n)    | 打印当前 word 的 vim.inspect 结果          | 调试神器                     |
| `<space>p` (v)    | 打印选中内容的 vim.inspect 结果            |                              |
| `<leader>X`       | 执行整个 buffer 的 Lua 代码（不 source）   |                              |

### 4. DAP 调试（全局，plugins/dap.lua）
全局生效，Rust 配置使用自动智能构建。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `<F5>`            | 继续 / 开始调试                            | 标准 F 键                    |
| `<F9>`            | 切换断点                                   |                              |
| `<F10>`           | 步过                                       |                              |
| `<F11>`           | 步入                                       |                              |
| `<F12>`           | 步出                                       |                              |
| `<leader>db`      | 切换断点                                   | Leader 系列                  |
| `<leader>dB`      | 条件断点                                   |                              |
| `<leader>dl`      | 日志断点                                   |                              |
| `<leader>dc`      | 继续执行                                   |                              |
| `<leader>dr`      | 切换 REPL                                  |                              |
| `<leader>dt`      | 终止调试                                   |                              |
| `<leader>du`      | 切换调试界面                               |                              |
| `<leader>dC`      | 当前行条件断点                             |                              |
| `<leader>dL`      | 当前行日志断点                             |                              |
| `<leader>dX`      | 清空所有断点                               |                              |
| `<2-LeftMouse>`   | 双击变量弹出值                             | 鼠标支持                     |

### 5. Crates.nvim（Cargo.toml 文件）
仅在 Cargo.toml 中生效。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `<leader>cu`      | 升级所有依赖                               | Crates 管理                  |
| `<leader>cU`      | 更新所有依赖                               |                              |
| `<leader>ch`      | 显示版本/特性弹窗                          |                              |
| `<leader>cv`      | 显示版本弹窗                               |                              |
| `<leader>cf`      | 显示特性弹窗                               |                              |
| `<leader>cd`      | 打开文档                                   |                              |
| `<leader>cr`      | 重新加载缓存                               |                              |

### 6. Gitsigns（Git 文件）
Git 变更操作，仅在 含有.git目录中的 文件中生效。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `]h` / `[h`       | 下一个/上一个变更块                        | 导航                         |
| `<leader>ghs`     | 暂存当前变更块（v 模式支持选中）           | hunk 操作                    |
| `<leader>ghr`     | 撤销当前变更块                             |                              |
| `<leader>ghS`     | 暂存整个文件                               |                              |
| `<leader>ghR`     | 撤销整个文件                               |                              |
| `<leader>ghu`     | 撤销最近一次暂存                           |                              |
| `<leader>ghp`     | 预览当前变更块                             | 查看                         |
| `<leader>ghb`     | 查看当前行完整提交信息                     |                              |
| `<leader>ghB`     | 复制当前行提交信息到剪贴板                 |                              |
| `<leader>ghd` / `<leader>ghD` | 对比文件与暂存区/上一次提交    |                              |
| `<leader>gtb`     | 切换行内提交信息显示                       | 功能开关                     |
| `<leader>gtd`     | 切换已删除行显示                           |                              |
| `<leader>gts`     | 切换变更符号列显示                         |                              |
| `<leader>ghh`     | 选中当前变更块                             | 额外                         |
| `<leader>ghf`     | 刷新变更状态                               |                              |

### 7. Treesitter 文本对象 & 移动（全局）
全局生效，代码结构操作神器。

| 键位              | 作用描述                                   | 备注                         |
|-------------------|--------------------------------------------|------------------------------|
| `af` / `if`       | 函数（外/内）                              | Select 文本对象              |
| `ac` / `ic`       | 类（外/内）                                |                              |
| `al` / `il`       | 循环（外/内）                              |                              |
| `ai` / `ii`       | 条件语句（外/内）                          |                              |
| `as` / `is`       | 语句（外/内）                              |                              |
| `aC` / `iC`       | 注释（外/内）                              |                              |
| `]f` / `[f`       | 下一个/上一个函数开始                      | Move 跳转                    |
| `]c` / `[c`       | 下一个/上一个类开始                        |                              |
| `]s` / `[s`       | 下一个/上一个语句开始                      |                              |
| `<leader>a` / `<leader>A` | 交换到下一个/上一个参数            | Swap 参数                    |
| `;` / `,`         | 重复上一次 move（向前/向后）               | Repeatable                   |

### 8. Which-key 分组提示（lua/plugins/which-key.lua）
自动显示分组提示，增强可读性。

- `<leader>` → Leader 主菜单
- `<leader>b` → 缓冲区管理
- `<leader>t` → 标签页
- `<leader>w` → 窗口
- `<leader>e` → 文件/探索器
- `<leader>c` → 内容/代码操作 / Crates
- `<leader>f` → 查找
- `<leader>l` → 诊断
- `<leader>d` → 调试
- `g` → 跳转
- `gr` → LSP 符号操作
- `[` / `]` → 上/下一个

### 9. Markview（lua/plugins/markview.lua）
A hackable Markdown, HTML, LaTeX, Typst & YAML previewer for Neovim.

- `<leader>M` → 全局完全开关 markview 渲染（包括所有缓冲区）
- `<leader>m` → 只切换当前 Markdown 文件的渲染（最常用）
- `<leader>ms` → 打开/关闭分屏实时预览（一边编辑，一边看美化效果，滚动同步）

### 总结
- **全局 + LSP 通用**：`config/keymaps.lua`（基础编辑、窗口、诊断、Mini.pick 查找等）
- **Rust 增强**：`after/ftplugin/rust.lua`（rustaceanvim 专属命令，覆盖 `K`、`gra`）
- **Lua 调试**：`after/ftplugin/lua.lua`（source、eval、inspect）
- **DAP**：`plugins/dap.lua`（F 键 + `<leader>d*`）
- **Crates**：`plugins/crates.lua`（`<leader>c*`）
- **Gitsigns**：`plugins/gitsigns.lua`（`<leader>gh*`）
- **Treesitter**：`plugins/treesitter.lua`（`a/i*` 对象、`]`/[` 跳转）

祝大家使用愉快！—— WuDiXianXin
