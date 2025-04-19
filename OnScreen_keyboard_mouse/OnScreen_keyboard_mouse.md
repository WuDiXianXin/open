> wayland 环境中 监视 键盘和鼠标输入 ，by WuDiXianXin

---
### 总结
####不要在 wayland 环境中使用 screenkey obs-input-overlay 等监视 键盘和鼠标输入
### 提醒
1. 一定注意，纯 wayland 环境 无法使用
2. 只能监视 使用 x11 (xcb) 环境 软件/程序 的输入
3. 在 x11 (xcb) 和 wayland 环境中的 fcitx5 不通用

### 在 kitty 的 x11 环境中使用
#### 定义在 环境中

1. fish

~/.config/fish/config.fish :

```fish
    # 定义启动 Kitty 的函数
    function kittyx
        set -e WAYLAND_DISPLAY
        kitty >/dev/null 2>&1 &
    end

    # 定义启动 OBS 的函数
    function obsx
        set -e WAYLAND_DISPLAY
        set QT_QPA_PLATFORM xcb
        obs >/dev/null 2>&1 &
    end

    # 定义启动 virt-manager 的函数
    function virtx
        set -e WAYLAND_DISPLAY
        set QT_QPA_PLATFORM xcb
        virt-manager >/dev/null 2>&1 &
    end

    # 定义启动 fcitx5 的函数
    function fcitx5x
        set -e WAYLAND_DISPLAY
        set QT_QPA_PLATFORM xcb
        killall fcitx5
        fcitx5 >/dev/null 2>&1 &
    end
```
