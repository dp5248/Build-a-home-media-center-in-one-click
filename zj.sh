#!/bin/bash
sudo apt install apt-transport-https ca-certificates -y
sudo tee /etc/apt/sources.list > /dev/null <<-'EOF'
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
EOF
sudo apt update && sudo apt upgrade -y

#安装基本工具
sudo apt install -y vim curl npm samba nfs-common nfs-kernel-server nfs-common

#挂载硬盘并创建smb共享
sudo chown 1000:1000 -R /mnt
sudo chmod 777 /etc/fstab
for var in sd{b..z}
do
        if [ -b /dev/$var ];then
        read -p "你有一块盘大小为`sudo fdisk -l | grep -oP "(?<=(Disk /dev/$var)).*" | cut -d" " -f2-3`盘位为/dev/$var,是否格式化该硬盘（y/n）:" b
        if [ $b = y ];then sudo mkfs.ext4 /dev/$var;
        else echo '本操作没格式化该硬盘';
        fi
        read -p "是否需要挂载该硬盘(y/n)：" c
        if [ $c = y ];then 
        read -p "请输入想命名的非中文名称（尽量简短，不同名称之间不要重复）:" b0
        mkdir /mnt/$b0 -p
        b1=`sudo blkid | grep -oP "(?<=(/dev/$var)).*" | cut -d" " -f2 | cut -c 7-42`
        b2=`sudo blkid | grep -oP "(?<=(/dev/$var)).*" | cut -d" " -f4 | cut -c 7-10`
        sudo echo UUID=$b1 /mnt/$b0 $b2 defaults 0 0 >> /etc/fstab
        printf "%s [$b0]\n comment = $b0\n path = /mnt/$b0\n read only = no\n browsable = yes\n public = yes\n available = yes\n writable = yes\n" | sudo tee /etc/samba/smb.conf -a > /dev/null
        printf %s "-v /mnt/$b0/qs:/$b0 \\" >> ~/ZJ/QS
        printf %s "-v /mnt/$b0/pk:/$b0 \\" >> ~/ZJ/QP
        printf %s "-v /mnt/$b0/qb:/$b0 \\" >> ~/ZJ/QB
        else echo '本操作没挂载该硬盘';fi
        fi
done
sudo chmod 644 /etc/fstab

#重启smb并设置smb密码
sudo service smbd restart
user=`ls /home`
sudo smbpasswd -a $user

read -p "刚刚输入的密码为:" smbmm
echo "你的SMB用户名为`ls /home`，密码为$smbmm" >> ~/ZJ/note -a

#改host方便nastools识别
sudo tee /etc/hosts -a > /dev/null <<-'EOF'
108.156.91.110 api.themoviedb.org
192.241.234.54 api.thetvdb.org
54.230.18.89 www.themoviedb.org
52.84.125.81 api.tmdb.org
108.159.227.49 image.tmdb.org
EOF

#硬链接hlink，需要作为另外并以root运行
cd ~/ZJ
wget https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz
mv node-v16.16.0-linux-x64.tar.xz node.tar.gz
tar -xvf ~/ZJ/node.tar.gz
mv node-v16.16.0-linux-x64 node
sudo ln -s ~/ZJ/node/bin/npm /usr/local/bin/
sudo ln -s ~/ZJ/node/bin/node /usr/local/bin/
npm install -g hlink
sudo ln -s ~/ZJ/node/bin/hlink /usr/local/bin/
sudo tee /root/hlink.config.mjs > /dev/null <<-'EOB'
// 重要说明路径地址都请填写 绝对路径！！！！
export default {
  /**
   * 源地址
   */
  source: '',
  /**
   * 目标地址
   */
  dest: '',
  /**
   * 需要包含的后缀名,如果不配置该项，会采用以下策略
   *  1. 配置了excludeExtname，则链接文件为排除后的其他文件
   *  2. 未配置excludeExtname，则链接文件为目录下的所有文件
   */
  includeExtname: [],
  /**
   * 需要排除的后缀名, 如果配置了includeExtname则该配置无效
   */
  excludeExtname: [],
  /**
   * 0：保持原有的目录结构
   * 1：只保存一级目录结构
   * 默认为 0
   * 例子：
   *  - 源地址目录为：/a
   *  - 目标地址目录为: /d
   *  - 链接的文件地址为 /a/b/c/z/y/mv.mkv；
   *  如果保存模式为0 生成的硬链地址为: /d/b/c/z/y/mv.mkv
   *  如果保存模式为1 生成的硬链地址为：/d/y/mv.mkv
   */
  saveMode: 0,
  /**
   * 是否打开缓存，默认关闭
   *
   * 打开后，每次硬链后会把对应文件存入缓存，就算下次删除硬链，也不会进行硬链
   */
  openCache: false,
  /**
   * 是否为独立文件创建同名文件夹，默认创建
   */
  mkdirIfSingle: true,
}
EOB
sudo cp /root/hlink.config.mjs ~/ZJ/hlink.config.mjs

tee ~/ZJ/hlinkhj.sh > /dev/null <<-'EOF'
#! /bin/bash
ln -s ~/ZJ/node/bin/npm /usr/local/bin/
ln -s ~/ZJ/node/bin/node /usr/local/bin/
ln -s ~/ZJ/node/bin/hlink /usr/local/bin/
ln -s ~/ZJ/hlink.config.mjs /root/hlink.config.mjs
EOF
sudo cp ~/ZJ/hlinkhj.sh /etc/init.d/
sudo chmod 750 /etc/init.d/hlinkhj.sh
sudo update-rc.d hlinkhj.sh defaults
sudo chown 1000:1000 -R ~/ZJ/ && sudo chmod 777 -R ~/ZJ/
cat ~/ZJ/note
read -p "以下为安装docker和推荐容器，不需要请输入n，需要请直接回车:" do
if [ $do = n ];then
echo "硬盘挂载，smb共享，硬链接已完成，请输入sudo reboot"
exit
fi

#安装docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
user=`ls /home`
sudo usermod -aG docker $user
sudo newgrp docker
su $user
echo "硬盘挂载，smb共享，硬链接,docker已完成，请输入sudo reboot"

#安装docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
user=`ls /home`
sudo usermod -aG docker $user
sudo newgrp docker
su $user
echo "硬盘挂载，smb共享，硬链接,docker已完成，请输入sudo reboot"
