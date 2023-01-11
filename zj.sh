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
mkdir /mnt/Z -p
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
        printf %s "-v /mnt/$b0/qs:/$b0 \\" >> /mnt/Z/QS
        printf %s "-v /mnt/$b0/pk:/$b0 \\" >> /mnt/Z/QP
        printf %s "-v /mnt/$b0/qb:/$b0 \\" >> /mnt/Z/QB
        else echo '本操作没挂载该硬盘';fi
        fi
done
sudo chmod 644 /etc/fstab

#重启smb并设置smb密码
sudo service smbd restart
user=`ls /home`
sudo smbpasswd -a $user

read -p "刚刚输入的密码为:" smbmm
echo "你的SMB用户名为`ls /home`，密码为$smbmm" >> /mnt/Z/note -a

#改host方便nastools识别
sudo tee /etc/hosts -a > /dev/null <<-'EOF'
108.156.91.110 api.themoviedb.org
192.241.234.54 api.thetvdb.org
54.230.18.89 www.themoviedb.org
52.84.125.81 api.tmdb.org
108.159.227.49 image.tmdb.org
EOF

#硬链接hlink，需要作为另外并以root运行
cd /mnt/Z
wget https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz
mv node-v16.16.0-linux-x64.tar.xz node.tar.gz
tar -xvf /mnt/Z/node.tar.gz
mv node-v16.16.0-linux-x64 node
sudo ln -s /mnt/Z/node/bin/npm /usr/local/bin/
sudo ln -s /mnt/Z/node/bin/node /usr/local/bin/
npm install -g hlink
sudo ln -s /mnt/Z/node/bin/hlink /usr/local/bin/
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
sudo cp /root/hlink.config.mjs /mnt/Z/hlink.config.mjs

tee /mnt/Z/hlinkhj.sh > /dev/null <<-'EOF'
#! /bin/bash
ln -s /mnt/Z/node/bin/npm /usr/local/bin/
ln -s /mnt/Z/node/bin/node /usr/local/bin/
ln -s /mnt/Z/node/bin/hlink /usr/local/bin/
ln -s /mnt/Z/hlink.config.mjs /root/hlink.config.mjs
EOF
sudo cp /mnt/Z/hlinkhj.sh /etc/init.d/
sudo chmod 750 /etc/init.d/hlinkhj.sh
sudo update-rc.d hlinkhj.sh defaults
sudo chown 1000:1000 -R /mnt/Z/ && sudo chmod 777 -R /mnt/Z/
cat /mnt/Z/note
echo "硬盘挂载，smb共享，硬链接已完成，请输入sudo reboot"




read -p "以下为安装docker和推荐容器，不需要请输入n，需要请直接回车:" do
if [ $do = n ];then
exit
fi

#安装docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
user=`ls /home`
sudo usermod -aG docker $user
sudo newgrp docker

#用户输入docker设置文件的路径
read -p "请输入/mnt下面的一个文件夹名称（最好是挂载了硬盘的），用于存放docker的设置文件：" wj

#基础容器
#Portainer
read -p "是否需要安装portainer（用途：方便管理容器）(y/n):" po
if [ $po = y ];then
read -p "安装中文版输入y，安装官方版（英文）输入n：" bb
if [ $bb = y ];then
docker run -d \
--name portainer \
--restart=always \
-p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /mnt/$wj/docker/portainer:/data \
6053537/portainer-ce
echo "portainer端口号为9000" >> /mnt/Z/note -a
else if [ $bb = n ];then
docker run -d \
--name portainer \
--restart=always \
-p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /mnt/$wj/docker/portainer:/data \
portainer/portainer-ce
echo "portainer端口号为9000" >> /mnt/Z/note -a
fi
else echo "不安装portainer";fi

#Filebrower
read -p "是否需要安装filebrowser（用途：方便管理文件）(y/n):" fb
if [ $fb = y ];then
docker run -d \
--name fb \
--restart=always \
--net=host \
-e PUID=1000 \
-e PGID=1000 \
-e SSL=on \
-e WEB_PORT=8092 \
-e FB_AUTH_SERVER_ADDR=127.0.0.1 \
-v /mnt:/myfiles \
-v /mnt/$wj/docker/fb:/config \
80x86/filebrowser
echo "filebrowser端口号为8092,默认用户名为admin，默认密码为admin" >> /mnt/Z/note -a
else echo "不安装filebrowser";fi

#PT相关
#Vertex
read -p "是否需要安装vertex（用途：刷流/片库自动化）(y/n):" vt
if [ $vt = y ];then
docker run -d \
--name vertex \
--restart=unless-stopped \
-v /mnt/$wj/docker/vertex:/vertex \
-p 11160:3000 \
-e TZ=Asia/Shanghai \
lswl/vertex:stable
echo "vertex端口号为11160" >> /mnt/Z/note -a
else echo "不安装vertex";fi

#QS
read -p "是否需要安装刷流QB（用途：专门用于刷流的QB）(y/n):" qs
if [ $qs = y];then
echo '#!/bin/bash' >> /mnt/Z/QS.sh
printf "docker run -d --name QS --restart=always --network=host -e WEB_PORT=11161 -e BT_PORT=38661 -e PUID=1000 -e PGID=1000 -v /mnt/$wj/docker/QS/config:/config -v /mnt/$wj/docker/QS/data:/data `cat /mnt/Z/QS`" >> /mnt/Z/QS.sh
printf "\n80x86/qbittorrent:4.3.5-alpine-3.13.5-amd64-full" >> /mnt/Z/QS.sh
chmod +x /mnt/Z/QS.sh
sh /mnt/Z/QS.sh
cd /mnt/$wj/docker/QS/config
find -name 'qBittorrent.conf' | xargs perl -pi -e 's|WebUI\HTTPS\Enabled=true|WebUI\HTTPS\Enabled=false|g'
docker restart QS
echo "刷流QB端口号为11161，默认用户名为admin,默认密码为adminadmin" >> /mnt/Z/note -a
else echo "不安装刷流QB";fi

#QP
read -p "是否需要安装片库QB（用途：专门用于刷流的QB）(y/n):" qp
if [ $qp = y];then
echo '#!/bin/bash' >> /mnt/Z/QS.sh
printf "docker run -d --name QP --restart=always --network=host -e WEB_PORT=11170 -e BT_PORT=38670 -e PUID=1000 -e PGID=1000 -v /mnt/$wj/docker/QP/config:/config -v /mnt/$wj/docker/QP/data:/data `cat /mnt/Z/QP`" >> /mnt/Z/QP.sh
printf "\n80x86/qbittorrent:4.3.5-alpine-3.13.5-amd64-full" >> /mnt/Z/QP.sh
chmod +x /mnt/Z/QP.sh
sh /mnt/Z/QP.sh
cd /mnt/$wj/docker/QP/config
find -name 'qBittorrent.conf' | xargs perl -pi -e 's|WebUI\HTTPS\Enabled=true|WebUI\HTTPS\Enabled=false|g'
docker restart QP
echo "片库QB端口号为11170，默认用户名为admin,默认密码为adminadmin" >> /mnt/Z/note -a
else echo "不安装片库QB";fi

#TP
read -p "是否需要安装片库TR（用途：片库QB下载后转移做种）(y/n):" tp
if [ $tp = y ];then
read -p "该TR的用户名设置为：" tp1
read -p "该TR的密码设置为：" tp2
echo '#!/bin/bash' >> /mnt/Z/TP.sh
printf "docker run -d --name TP --restart=always --network=host -e RPCPORT=11171 -e PEERPORT=38671 -e TR_USER=$tp1 -e TR_PASS=$tp2 -e PUID=1000 -e PGID=1000 -e TZ=Asia/Shanghai -v /mnt/$wj/docker/TP/config:/config -v /mnt/$wj/docker/TP/watch:/watch `cat /mnt/Z/QP`" >> /mnt/Z/TP.sh
printf "\ndocker.io/chisbread/transmission:version-3.00-r13" >> /mnt/Z/TP.sh
chmod +x /mnt/Z/TP.sh
sh /mnt/Z/TP.sh
echo "片库TR端口号为11171,用户名为$tp1,密码为$tp2" >> /mnt/Z/note -a
else echo "不安装片库TR";fi

#QB
read -p "是否需要安装保种QB（用途：与片库QB独立）(y/n):" qb
if [ $qb = y];then
echo '#!/bin/bash' >> /mnt/Z/QB.sh
printf "docker run -d --name QB --restart=always --network=host -e WEB_PORT=11180 -e BT_PORT=38680 -e PUID=1000 -e PGID=1000 -v /mnt/$wj/docker/QB/config:/config -v /mnt/$wj/docker/QB/data:/data `cat /mnt/Z/QB`" >> /mnt/Z/QB.sh
printf "\n80x86/qbittorrent:4.3.5-alpine-3.13.5-amd64-full" >> /mnt/Z/QB.sh
chmod +x /mnt/Z/QB.sh
sh /mnt/Z/QB.sh
cd /mnt/$wj/docker/QB/config
find -name 'qBittorrent.conf' | xargs perl -pi -e 's|WebUI\HTTPS\Enabled=true|WebUI\HTTPS\Enabled=false|g'
docker restart QB
echo "保种QB端口号为11180，默认用户名为admin,默认密码为adminadmin" >> /mnt/Z/note -a
else echo "不安装保种QB";fi

#TR
read -p "是否需要安装保种TR（用途：与保种TR独立）(y/n):" tr
if [ $tr = y ];then
read -p "该TR的用户名设置为：" tr1
read -p "该TR的密码设置为：" tr2
echo '#!/bin/bash' >> /mnt/Z/TP.sh
printf "docker run -d --name TP --restart=always --network=host -e RPCPORT=11171 -e PEERPORT=38671 -e TR_USER=$tr1 -e TR_PASS=$tr2 -e PUID=1000 -e PGID=1000 -e TZ=Asia/Shanghai -v /mnt/$wj/docker/TP/config:/config -v /mnt/$wj/docker/TP/watch:/watch `cat /mnt/Z/QP`" >> /mnt/Z/TR.sh
printf "\ndocker.io/chisbread/transmission:version-3.00-r13" >> /mnt/Z/TR.sh
chmod +x /mnt/Z/TR.sh
sh /mnt/Z/TR.sh
echo "片库TR端口号为11181,用户名为$tr1,密码为$tr2" >> /mnt/Z/note -a
else echo "不安装保种TR";fi

#IYUU
read -p "是否需要安装IYUU（用途：用于辅种）(y/n):" iy
if [ $iy = y ];then
docker run -d \
--restart=always \
--name IYUU \
--net=host \
-v /mnt/$wj/docker/IYUU/:/IYUU/db \
-v /mnt/$wj/docker/IYUU/:/IYUU \
-v /mnt/$wj/docker/QP/data/BT_backup/:/QP \
-v /mnt/$wj/docker/TP/config/torrents/:/TP \
-v /mnt/$wj/docker/QB/data/BT_backup/:/QB \
-v /mnt/$wj/docker/TR/config/torrents/:/TR \
iyuucn/iyuuplus
echo "IYUU端口号为8787,打开https://iyuu.cn/，点击开始使用，并微信扫码，获得爱语飞飞TOKEN，密码为空，第一次输入时你可以自由设置你的密码；以后密码与第一次相同才能登录" >> /mnt/Z/note -a
else echo "不安装IYUU";fi

#相关服务
#Ddns-go
read -p "是否需要安装ddns-go（用途：动态域名解析）(y/n):" dd
if [ $dd = y ];then
docker run -d \
--name ddns \
--restart=always \
--net=host \
-v /mnt/$wj/docker/ddns:/root \
jeessy/ddns-go
echo "ddns-go端口号为9876" >> /mnt/Z/note -a
else echo "不安装ddns-go";fi

#NPM
read -p "是否安装NPM（用途：用于反向代理）(y/n):" np
if [ $np = y ];then
docker run -d \
--name npm \
--restart=always \
-e USER_ID=1000 \
-e GROUP_ID=1000 \
-e DISABLE_IPV6=0 \
-v /mnt/$wj/docker/npm:/config:rw \
-p 8181:8181 -p 1880:8080 -p443:4443 \
jlesage/nginx-proxy-manager:latest
echo "npm端口为8181，记得去路由器做端口映射，内网ip为nas的ip，端口为443" >> /mnt/Z/note -a
else echo "不安装npm";fi

#VWD
read -p "是否安装bitwarden（用途：私有密码库）(y/n):" bw
if [ $bw = y ];then
docker run -d \
--name vwd \
--restart=always \
-e SIGNUPS_ALLOWED:false \
-v /mnt/$wj/docker/vwd:/data \
-p 11190:80 \
vaultwarden/server:latest
echo "bitwarden端口为11190，先设置好反向代理后去再设置bwd" >> /mnt/Z/note -a
else echo "不安装bitwarden";fi

#Heimdall
read -p "是否安装heimdall（用途：导航栏）(y/n):" hm
if [ $hm = y ];then
docker run -d \
--name=hm \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Asia/Shanghai \
-p 11191:80 \
-p 11192:443 \
-v /mnt/$wj/docker/hm:/config \
--restart unless-stopped \
lscr.io/linuxserver/heimdall:latest
echo "heimdall端口为11191" >> /mnt/Z/note -a
else echo "不安装heimdall";fi

#备份相关
#Mysql
read -p "是否安装mysql（用途：数据库）(y/n):" my
if [ $my = y ];then
read -p "数据库密码设置为：" mysql
docker run -d \
--name mysql \
--restart=always \
-v /mnt/$wj/docker/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=$mysql \
-e MYSQL_USER=nextcloud \
-e MYSQL_PASSWORD=$mysql \
-e MYSQL_DATABASE=nextcloud \
-p 3306:3306 \
mysql
echo "mysql的端口为3306，用户名为nextcloud，密码和root密码都是$mysql" >> /mnt/Z/note -a
else echo "不安装mysql";fi

#Nextcloud
read -p "是否安装nextcloud（用途：私有云备份）(y/n):" nc
if [ $nc = y ];then
docker run -d \
--name nextcloud \
--restart=always \
-v /mnt/$wj/docker/nextcloud:/var/www/html \
-p 11200:80 \
--link mysql:mysql \
nextcloud
echo "nextcloud端口为11120" >> /mnt/Z/note -a
else echo "不安装nextcloud";fi

#片库相关
#nastools
read -p "是否安装nastools（用途：自动化片库和刷流等）(y/n):" nt
if [ $nt = y ];then
echo '#!/bin/bash' >> /mnt/Z/NT.sh
printf "docker run -d --name nastools --net=host --hostname nas-tools -e TZ="Asia/Shanghai" -e PUID=1000 -e PGID=1000 -e UMASK=022 -e NASTOOL_AUTO_UPDATE=true -v/mnt/$wj/docker/nt:/config `cat /mnt/Z/QP`" >> /mnt/Z/NT.sh
printf "\njxxghp/nas-tools:latest" >> /mnt/Z/NT.sh
chmod +x /mnt/Z/NT.sh
sh /mnt/Z/NT.sh
echo "nastool端口为3000，默认用户名是admin，默认密码是password" >> /mnt/Z/note -a
else echo "不安装nastools";fi

#Chinesesubfinder
echo '#!/bin/bash' >> /mnt/Z/ZIMU.sh
printf "docker run -itd --name zimu --restart=unless-stopped --net=host -e PUID=1000 -e PGID=1000 -e TZ=Asia/Shanghai -v /mnt/$wj/docker/zimu/config:/config -v /mnt/$wh/docker/zimu/cache:/app/cache -v /mnt/$wj/docker/zimu/brower:/root/.cache/rod/brower `cat /mnt/Z/QP`" >> /mnt/Z/ZIMU.sh
printf "\nallanpk716/chinesesubfinder:latest" >> /mnt/Z/ZIMU.sh
pirntf "\necho Chineseubfinder的端口为19035 >> /mnt/Z/note -a" >> /mnt/Z/ZIMU.sh
chmod +x /mnt/Z/ZIMU.sh
echo "请设置好nastools后，在ssh窗口输入sh /mnt/Z/ZIMU.sh以安装ChineseSubFinder" >> /mnt/Z/note -a
echo "以后需要查看本次装机相关内容请输入cat /mnt/Z/note可查看（这句指令建议记录好）" >> /mnt/Z/note -a
cat /mnt/Z/note
