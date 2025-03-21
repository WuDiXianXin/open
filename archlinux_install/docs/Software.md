> By RuoChen404
---
# 安装配置软件
paru -S \
fastfetch \
p7zip \
fd \
luajit \
neovim \
eza \
fzf \
zoxide \
ripgrep \
flameshot \
libreoffice-still \
libreoffice-still-zh-cn \
git \
less \
steam \
godot \
blender \
ffmpeg \
obs-studio

google-chrome

这两个fzf zoxide的配置都在bashrc里面

steam：登录后，点击steam图标进入设置，选择Interface，把英文改成中文，兼容性选择特定版本的 Proton

libreoffice-writer    # 文字处理
libreoffice-calc      # 电子表格
libreoffice-impress   # 演示文稿
libreoffice-draw      # 图形设计
libreoffice-math      # 公式编辑

从gitee或github上创建账户，最好都是英文，
然后创建一个仓库open,按照提示进行操作：

git config --global user.name "用户名"
git config --global user.email "邮箱地址"

查看信息
git config --global --list

设置ssh无密码登陆，连续回车三次
ssh-keygen -t ed25519 -C "随意内容"

复制cat ~/.ssh/id_ed25519.pub输入内容
粘贴在你个人的git平台上

测试是否连接成功
ssh -T git@gitee.com

mkdir open
cd open
git init 
touch README.md
git add README.md
git commit -m "first commit"
git remote add origin git@gitee.com:[你的用户名]/open.git
git push -u origin "master"



(废弃)
在steam中安装wallpaper：
(废弃，我安装不上)
安装WPS(cn，默认回车，也会默认会安装7zip)
mkdir -p /home/xianxin/.cache/paru/clone/ttf-ms-win11-auto/src/
paru -S 
wps-office-cn 
ttf-wps-fonts 
ttf-ms-win11-auto 
wps-office-fonts 
wps-office-mui-zh-cn
