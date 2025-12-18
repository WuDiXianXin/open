# linux-wallpaperengine 安装和手动构建以及使用

将 Wallpaper Engine 风格的动态壁纸带到 Linux！这个项目允许你直接在桌面上运行 Steam 的 Wallpaper Engine 动画壁纸。

> ⚠️ 这是一个从教育项目演变成的基于 OpenGL 的 Linux 壁纸引擎。可能会有一些限制和奇怪的行为！

## 发行版包管理器

以下安装方法均来自 [linux-wallpaperengine readme页面](https://github.com/Almamu/linux-wallpaperengine)

依赖：pipewire-audio 也可以，不用再安装 PulseAudio

- OpenGL 3.3 support
- CMake
- LZ4, Zlib
- SDL2
- FFmpeg
- X11 or Wayland
- Xrandr (for X11)
- GLFW3, GLEW, GLUT, GLM
- MPV
- PulseAudio
- FFTW3

### Arch Linux

```bash
# yay -S linux-wallpaperengine-git # 我不用
paru -S linux-wallpaperengine-git
```

### Ubuntu 22.04

```bash
sudo apt-get update
sudo apt-get install build-essential cmake libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libgl-dev libglew-dev freeglut3-dev libsdl2-dev liblz4-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxxf86vm-dev libglm-dev libglfw3-dev libmpv-dev mpv libmpv1 libpulse-dev libpulse0 libfftw3-dev
```

### Ubuntu 24.04

```bash
sudo apt-get update
sudo apt-get install build-essential cmake libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libgl-dev libglew-dev freeglut3-dev libsdl2-dev liblz4-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxxf86vm-dev libglm-dev libglfw3-dev libmpv-dev mpv libmpv2 libpulse-dev libpulse0 libfftw3-dev
```

### Alt linux

```bash
sudo epm update
sudo epm install gcc-c++ make cmake libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel libGL-devel libGLEW-devel freeglut-devel libSDL2-devel liblz4-devel libavcodec-devel libavformat-devel libavutil-devel libswscale-devel libXxf86vm-devel libglm-devel libglfw3-devel libmpv-devel mpv libpulseaudio-devel libpulseaudio libfftw3-devel libpng-devel libffi-devel libswresample-devel libgmpxx-devel
```

### Fedora 42

```bash
sudo dnf update
sudo dnf install gcc g++ cmake libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel mesa-libGL-devel glew-devel freeglut-devel SDL2-devel lz4-devel ffmpeg ffmpeg-free-devel libXxf86vm-devel glm-devel glfw-devel mpv mpv-devel pulseaudio-libs-devel fftw-devel
```

## Arch linux 手动构建

其他发行版，我没构建过，请参考 [linux-wallpaperengine readme页面](https://github.com/Almamu/linux-wallpaperengine)

分「依赖安装→源码准备→子模组补全→编译→安装」5步走，解决子模组克隆失败+手动编译的问题：

### 步骤1：先安装编译/运行依赖

打开终端，安装项目需要的依赖库（Arch Linux 下用 `pacman`）：

```bash
sudo pacman -S --needed lz4 ffmpeg mpv glfw glew freeglut libpulse git cmake sdl2 glm xorg-xrandr wayland-protocols
```

### 步骤2：克隆主项目源码

创建一个工作目录（比如 `~/build`，或其他目录），克隆主仓库：

```bash
# 创建工作目录
mkdir -p ~/build
cd ~/build

# 克隆主项目（和PKGBUILD里的source一致）
# 可加 --depth 1 git参数加速下载
git clone https://github.com/Almamu/linux-wallpaperengine.git linux-wallpaperengine-git
cd linux-wallpaperengine-git
```

### 步骤3：手动补全所有子模组（关键：替代`git submodule update`）

项目的子模组都在 `src/External/` 目录下，我们手动下载每个子模组到对应路径（避免Git克隆失败）：

```bash
# 进入子模组目录
cd src/External

# 批量删除所有空的子模组目录（一键执行）
rm -rf argparse Catch2 glslang-WallpaperEngine json kissfft MimeTypes SPIRV-Cross-WallpaperEngine stb

# 可加 --depth 1 git参数加速下载
# 1. 下载Catch2
git clone https://github.com/catchorg/Catch2.git Catch2

# 2. 下载MimeTypes（若Git克隆失败，用压缩包替代：见下方备选）
git clone https://github.com/lasselukkari/MimeTypes.git MimeTypes

# 3. 下载SPIRV-Cross-WallpaperEngine
git clone https://github.com/Almamu/SPIRV-Cross-WallpaperEngine.git SPIRV-Cross-WallpaperEngine

# 4. 下载argparse
git clone https://github.com/p-ranav/argparse.git argparse

# 5. 下载glslang-WallpaperEngine
git clone https://github.com/Almamu/glslang-WallpaperEngine.git glslang-WallpaperEngine

# 6. 下载json
git clone https://github.com/nlohmann/json.git json

# 7. 下载kissfft
git clone https://github.com/mborgerding/kissfft.git kissfft

# 8. 下载stb
git clone https://github.com/nothings/stb.git stb

# 回到主项目目录
cd ../..
```

#### 若某个子模组（比如MimeTypes）Git克隆失败？

用**压缩包下载+解压**替代：

```bash
# 进入src/External目录
cd src/External
rm -rf MimeTypes  # 清空失败残留

# 下载MimeTypes压缩包
wget https://github.com/lasselukkari/MimeTypes/archive/refs/heads/master.zip -O MimeTypes.zip
unzip MimeTypes.zip
mv MimeTypes-master MimeTypes  # 重命名为子模组要求的目录名
rm MimeTypes.zip

cd ../..
```

### 步骤4：编译项目（对应PKGBUILD的`build`阶段）

执行CMake配置+编译：

```bash
# 创建build目录
mkdir -p build

# 执行CMake配置（参数和PKGBUILD完全一致）
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_INSTALL_PREFIX="/opt/linux-wallpaperengine" \
    -Wno-dev \
    -DCMAKE_CXX_FLAGS="-ffat-lto-objects -Wno-builtin-macro-redefined" \
    -DCMAKE_C_FLAGS="-Wno-builtin-macro-redefined"

# 开始编译（-j后面跟CPU核心数，比如8核写-j8）
cmake --build build -j$(nproc)
```

### 步骤5：安装到系统（对应PKGBUILD的`package`阶段）

把编译好的文件安装到 `/opt`，并创建启动脚本：

```bash
# 安装到/opt/linux-wallpaperengine
sudo cmake --install build

# 切换到bash环境，再创建/usr/bin下的启动脚本（方便直接运行）
# 或者你可以直接编辑保存
# 1. 用 sudo tee 创建启动脚本（规避重定向权限问题）
sudo tee /usr/bin/linux-wallpaperengine > /dev/null << EOF
#!/bin/bash
export LD_LIBRARY_PATH="/opt/linux-wallpaperengine/lib:\$LD_LIBRARY_PATH"
cd /opt/linux-wallpaperengine; ./linux-wallpaperengine "\$@"
EOF

# 2. 给脚本添加可执行权限（root 权限）
sudo chmod +x /usr/bin/linux-wallpaperengine

# 3. 确认 /opt 下的主程序权限（确保可执行）
sudo chmod +x /opt/linux-wallpaperengine/linux-wallpaperengine
```

### 验证安装成功

在终端直接运行：

```bash
linux-wallpaperengine --help
```

## 使用

### 基本语法

```bash
linux-wallpaperengine [options] <background_id or path>
```

你可以使用以下任一方式：

A Steam Workshop ID (e.g. 1845706469)
一个 Steam 创意工坊 ID（例如： 1845706469 ）

A path to a background folder
一个背景文件夹的路径

### 常见选项

| Option 选项 | Description 描述 |
| -------------- | --------------- |
| --silent | 静音背景音频 |
| --volume <val> | 设置音频音量 |
| --noautomute | 不要在其它应用程序播放音频时静音 |
| --no-audio-processing | 禁用音频响应功能 |
| --fps <val> | 限制帧率 |
| --window <XxYxWxH> | 以自定义大小/位置在窗口模式下运行 |
| --screen-root <screen> | 设置为特定屏幕的背景 |
| --bg <id/path> | 将背景分配给特定屏幕（使用 --screen-root 之后） |
| --scaling <mode> | 壁纸缩放：stretch，fit，fill，或 default |
| --clamping <mode> | 设置纹理锁定：clamp，border，repeat |
| --assets-dir <path> | 设置资产的自定义路径 |
| --screenshot <file> | 保存屏幕截图（PNG、JPEG、BMP） |
| --list-properties | 显示壁纸的可定制属性 |
| --set-property name=value | 覆盖特定属性 |
| --disable-mouse | 禁用鼠标交互 |
| --disable-parallax | 禁用支持视差效果的背景 |
| --no-fullscreen-pause | 全屏应用运行时防止暂停 |

### 创建软链接

创建软链接后，可直接用软链接路径指定壁纸，不用输超长 Steam 路径：

#### 步骤1：确认目标目录存在（避免创建失败）
先执行命令检查 Steam 创意工坊壁纸目录是否存在：
```bash
# `xx` 是我的用户名，`431960`是我的wallpaper engine存放壁纸的目录，你需要替换
ls -d /home/xx/.steam/steam/steamapps/workshop/content/431960
```
如果输出目录路径（无 `No such file or directory` 报错），说明目录存在；若报错，先确认 Steam 已下载 Wallpaper Engine 创意工坊壁纸，或核对路径是否正确。

#### 步骤2：创建软链接（核心操作）
软链接建议创建在**用户主目录**（`~`）下（方便访问），命名为 `wallpaperengine`，指向目标目录。执行以下命令（绝对路径，避免软链接失效）：
```bash
# 创建软链接（格式：ln -s 目标目录 软链接路径/名称）
ln -s /home/xx/.steam/steam/steamapps/workshop/content/431960 /home/xx/wallpaperengine
```

#### 步骤3：验证软链接是否生效
执行命令查看软链接状态：
```bash
ls -l /home/xx/wallpaperengine
```
正常输出示例（关键看 `->` 指向正确目录，权限带 `l` 表示软链接）：
```
lrwxrwxrwx 1 xx xx 70 Dec 18 19:00 /home/xx/wallpaperengine -> /home/xx/.steam/steam/steamapps/workshop/content/431960
```

#### 补充：删除软链接（如需）
如果想删除软链接，直接执行（**不要加 `/`**，否则会删目标目录文件！）：
```bash
# 删除主目录下的软链接
rm /home/xx/wallpaperengine

# 若删除~/.local/bin下的软链接
rm ~/.local/bin/wallpaperengine
```

### 用法示例

请参考 [linux-wallpaperengine readme页面](https://github.com/Almamu/linux-wallpaperengine)

```bash
# 通过 ID 运行背景
linux-wallpaperengine 1845706469

# 从文件夹运行背景
linux-wallpaperengine ~/wallpaperengine/1845706469/

# 示例
linux-wallpaperengine --screen-root eDP-1 --screen-root HDMI-A-1 --fps 15 --scaling fill ~/wallpaperengine/3625547979/
```

## 常见问题

请参考 [linux-wallpaperengine readme页面](https://github.com/Almamu/linux-wallpaperengine)

以下为直接复制原内容：

Black screen when setting as screen's background
设置成屏幕背景时出现黑屏

This can be caused by a few different things depending on your environment and setup.
这可能由几个不同的原因引起，具体取决于您的环境和设置。

X11

Common symptom of a compositor drawing to the background which prevents Wallpaper Engine from being properly visible. The only solution currently is disabling the compositor so Wallpaper Engine can properly draw on the screen
一个常见的症状是合成器绘制到背景上，这阻止了 Wallpaper Engine 正常显示。目前唯一的解决方案是禁用合成器，以便 Wallpaper Engine 能够在屏幕上正常绘制。

NVIDIA

Some users have had issues with GLFW initialization and other OpenGL errors. These are generally something that's worth reporting in the issues. Sometimes adding this variable when running Wallpaper Engine helps and/or solves the issue:
一些用户在使用 GLFW 初始化和其他 OpenGL 错误时遇到了问题。这些问题通常值得在问题反馈中报告。有时在运行 Wallpaper Engine 时添加这个变量有助于解决或缓解问题：

__GL_THREADED_OPTIMIZATIONS=0 linux-wallpaperengine

We'll be looking at improving this in the future, but for now it can be a useful workaround.
我们未来会考虑改进这一点，但就目前而言，这可以作为一个有用的临时解决方案。
