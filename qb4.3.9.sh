#!/bin/bash
read -p "容器明名为：" rqm
read -p "PUID为：" PUID
read -p "PGID为：" PGID
read -p "WEBUID端口为：" WEBUI
read -p "设置文件路径为(如/mnt/docker/qb,不需要写config)：" SZWJ
read -p "下载路径1(如/mnt/Z/dy)：" XZ1
read -p "下载路径1映射(如dy)为：" xz1
read -p "是否需要下载路径2(y/n)：" lj2
if [ $lj2 = y ];then
read -p "下载路径2(如/mnt/Z/jj)：" XZ2
read -p "下载路径2映射(如jj）为：" xz2
else echo '不设置下载路径2'
fi
read -p "是否需要下载路径3(y/n)：" lj3
if [ $lj3 = y ];then
read -p "下载路径3(如/mnt/Z/ge):" XZ3
read -p "下载路径3映射(如ge)为：" xz3
else echo '不设置下载路径3'
fi
read -p "是否需要下载路径4(y/n)：" lj4
if [ $lj4 = y ];then
read -p "下载路径4(如/mnt/Z/ge):" XZ4
read -p "下载路径4映射(如ge)为：" xz4
else echo '不设置下载路径4'
fi
if [ $lj2 = y ] && [ $lj3 = y ] && [ $lj4 = y ];then
chmod 777 -R $SZWJ $XZ1 $XZ2 $XZ3 $XZ4
docker run --name=$rqm --restart=always --network=host -e PUID=$PUID -e PGID=$PGID -e TZ=Asia/Shanghai -e WEBUI_PORT=$WEBUI -v $SZWJ/config:/config -v $XZ1:/downloads -v $XZ1:/$xz1 -v $XZ2:/$xz2 -v $XZ3:/$xz3 -v $XZ4:/$xz4 linuxserver/qbittorrent:14.3.9
fi
if [ $lj2 = y ] && [ $lj3 = y ] && [ $lj4 = n ];then
chmod 777 -R $SZWJ $XZ1 $XZ2 $XZ3
docker run --name=$rqm --restart=always --network=host -e PUID=$PUID -e PGID=$PGID -e TZ=Asia/Shanghai -e WEBUI_PORT=$WEBUI -v $SZWJ/config:/config -v $XZ1:/downloads -v $XZ1:/$xz1 -v $XZ2:/$xz2 -v $XZ3:/$xz3 linuxserver/qbittorrent:14.3.9
fi
if [ $lj2 = y ] && [ $lj3 = n ] && [ $lj4 = n ];then
chmod 777 -R $SZWJ $XZ1 $XZ2
docker run --name=$rqm --restart=always --network=host -e PUID=$PUID -e PGID=$PGID -e TZ=Asia/Shanghai -e WEBUI_PORT=$WEBUI -v $SZWJ/config:/config -v $XZ1:/downloads -v $XZ1:/$xz1 -v $XZ2:/$xz2 linuxserver/qbittorrent:14.3.9
fi
if [ $lj2 = n ] && [ $lj3 = n ] && [ $lj4 = n ];then
chmod 777 -R $SZWJ $XZ1
docker run --name=$rqm --restart=always --network=host -e PUID=$PUID -e PGID=$PGID -e TZ=Asia/Shanghai -e WEBUI_PORT=$WEBUI -v $SZWJ/config:/config -v $XZ1:/downloads -v $XZ1:/$xz1 linuxserver/qbittorrent:14.3.9
fi
echo '官方qb4.3.9已安装完毕，访问端口为$WEBUI，默认帐号为admin，默认密码为adminadmin。'
