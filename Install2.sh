#!/bin/bash
#用户确认函数
yh() {
read -p "【想以普通用户运行请直接回车，想以root用户运行请任意输入后回车】:" yh1
if [ $yh1 ];then
uid=0
gid=0
else
uid=$uid1
gid=$gid1
fi
}

#非片库路径设置的函数
lj() {
for var in {1..20}
do
if [ $var = 1 ];then
lj1
elif [ $var -gt 1 ];then
echo " "
read -p "是否新增下载路径$var【是请直接回车，否请随意输入后回车】:" ljpd1
if [ $ljpd1 ];then
return 0
else
lj1
fi
fi
done
}

lj1() {
read -p "下载路径$var(如/volume1/dy或/mnt/yinpanA/dy):" XZ
read -p "下载路径$var映射(如/dy)为:" xz
mkdir $XZ/$xz -p
#name\1.sh是用于给下面TR写入路径用的
printf %s "-v $XZ/$xz:$xz " >> $docker/$name/$name.sh
printf %s "-v $XZ:$xz " >> $docker/note/$name\1.sh
#note\1.txt是给下面TR写入记录用的
printf "%s\n" "下载路径$var,$XZ/$xz映射为$xz" >> $docker/$name/note.txt
printf "%s\n" "下载路径$var,$XZ/$xz映射为$xz" >> $docker/$name/note\1.txt
}


#片库路径设置的函数（考虑到nt相关）
ljpk() {
for var in {1..20}
do
if [ $var = 1 ];then
ljpk1
elif [ $var -gt 1 ];then
echo " "
read -p "是否新增$pklx下载路径$var【是请直接回车，否请随意输入后回车】:" ljpd2
if [ $ljpd2 ];then
break
else
ljpk1
fi
fi
done
}

ljpk1() {
read -p "$pklx下载路径$var(如/volume1/dy或/mnt/yinpanA/dy):" XZ
read -p "$pklx下载路径$var映射(如/dy)为:" xz
mkdir $XZ/$xz $XZ/nt/$xz -p
#name\1.sh是用于给对应TR写入路径用的,name\2.sh是给NT写入路径用的,name\3.sh是给plex等写入路径用的
printf %s "-v $XZ/$xz:$xz " >> $docker/$name/$name.sh
printf %s "-v $XZ/$xz:$xz " >> $docker/note/$name\1.sh
printf %s "-v $XZ:$xz " >> $docker/note/$name\2.sh
printf %s "-v $XZ/nt/$xz:$xz " >> $docker/note/$name\3.sh
#note1.txt是给对应TR写入记录用的，note2.txt是给NT写入记录用的,note3.txt是给plex等写入记录用的
printf "%s\n" "$pklx下载路径$var,$XZ/$xz映射为$xz" >> $docker/$name/note.txt
printf "%s\n" "$pklx下载路径$var：$XZ/$xz映射为$xz" >> $docker/$name/note1.txt
printf "%s\n" "$pklx下载路径$var：$XZ/$xz映射为$xz，硬链接的文件路径为$XZ/nt/$xz" >> $docker/$name/note2.txt
printf "%s\n" "$pklx硬链接的文件路径为$XZ/nt/$xz,映射为$xz" >> $docker/$name/note3.txt
}


#安装QB的函数，a和b中间需要加入上面的路径函数
qbaza() {
#定义容器名和端口，uid和gid
read -p "QB容器命名为:" name
mkdir $docker/$name -p
read -p "WEBUI端口设置为:" WEBUI
yh
#开始写入shell以安装QB，并记录容器设置情况
echo '#!/bin/bash' >> $docker/$name/$name.sh
printf "sudo docker run -d --name $name --restart=always --network=host -e TZ=Asia/Shanghai -e WEBUI_PORT=$WEBUI -e PUID=$uid -e PGID=$gid -v $docker/$name:/config " >> $docker/$name/$name.sh
printf "%s\n" "Qbittorrent已安装完毕访问端口为$WEBUI" "默认帐号为admin，默认密码为adminadmin" "设置文件为$docker/$name/config" >> $docker/$name/note.txt
}


qbazb() {
#用户选择QB的版本
printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" 支持的版本有： （1）QB4.1.9 （2）QB4.2.5 （3）QB4.3.5 （4）QB4.3.8 （5）QB4.3.9 （6）最新版（不建议）
read -p "请选择QBittorrent的版本选项数字【1-6】:" bb
if [ $bb = 1 ];then
jx="linuxserver/qbittorrent:4.1.9.99201911190849-6738-0b055d8ubuntu18.04.1-ls54 > /dev/null"
elif [ $bb = 2 ];then
jx="linuxserver/qbittorrent:14.2.5.99202004250119-7015-2c65b79ubuntu18.04.1-ls93 > /dev/null"
elif [ $bb = 3 ];then
jx="linuxserver/qbittorrent:14.3.5.99202106211645-7376-e25948e73ubuntu20.04.1-ls140 > /dev/null"
elif [ $bb = 4 ];then
jx="linuxserver/qbittorrent:14.3.8.99202110120741-7429-1bae770b2ubuntu20.04.1-ls158 > /dev/null"
elif [ $bb = 5 ];then
jx="linuxserver/qbittorrent:14.3.9 > /dev/null"
elif [ $bb = 6 ];then
jx="linuxserver/qbittorrent:latest > /dev/null"
fi

printf "$jx" >> $docker/$name/$name.sh
chmod +x $docker/$name/$name.sh
sh $docker/$name/$name.sh
printf %s "-v $docker/$name/qBittorrent/BT_backup " >> $docker/note/IYUU1.sh
cat $docker/$name/note.txt | tee $docker/note.txt -a > /dev/null

#是否安装对应TR
read -p "是否需要安装该QB对应的TR，用于后期iyuu转种【是请直接回车，否请随意输入后回车】:" tr1
if [ $tr1 ];then
echo "不安装该QB对应的TR"
echo " "
return 0
else
traza
trazb
fi
}


#安装TR的函数
traza() {
#用户输入TR相关参数
read -p "TR容器命名为:" name1
read -p "WEBUI端口设置为:" WEBUI
read -p "数据传输端口设置为:" PEERPORT
read -p "该TR的用户名设置为:" tra
read -p "该TR的密码设置为:" trb
mkdir $docker/$name1/watch -p
}


trazb() {
#用户选择TR版本
printf "%-20s  %-20s  %-20s  %-20s\n" 支持的版本有： （1）官方最新版 （2）快检版最新版 （3）快检版r13
read -p "请选择TRansmission的版本选项数字【1-3】:" bb
if [ $bb = 1 ];then
jx="linuxserver/transmission > /dev/null"
printf "sudo docker run -d --name $name1 --restart=always -p $WEBUI:9091 -p $PEERPORT:$PEERPORT -p $PEERPORT:$PEERPORT/udp -e PEERPORT=$PEERPORT -e USER=$tra -e PASS=$trb -e PUID=$uid -e PGID=$gid -e TZ=Asia/Shanghai -v $docker/$name1:/config -v $docker/$name1/watch:/watch `cat $docker/note/$name\1.sh` $jx" >> $docker/$name1/$name1\1.sh
printf %s "官方版TRansmission最新版" >> $docker/$name1/note.txt
elif [ $bb = 2 ];then
jx="chisbread/transmission > /dev/null"
printf "sudo docker run -d --name $name1 --restart=always --network=host -e RPCPORT=$WEBUI -e PEERPORT=$PEERPORT -e TR_USER=$tra -e TR_PASS=$trb -e PUID=$uid -e PGID=$gid -e TZ=Asia/Shanghai -v $docker/$name1:/config -v $docker/$name1/watch:/watch `cat $docker/note/$name\1.sh` $jx" >> $docker/$name1/$name1\1.sh
printf %s "快检版TRansmission最新版" >> $docker/$name1/note.txt
elif [ $bb = 3 ];then
jx="chisbread/transmission:version-3.00-r13 > /dev/null"
printf "sudo docker run -d --name $name1 --restart=always --network=host -e RPCPORT=$WEBUI -e PEERPORT=$PEERPORT -e TR_USER=$tra -e TR_PASS=$trb -e PUID=$uid -e PGID=$gid -e TZ=Asia/Shanghai -v $docker/$name1:/config -v $docker/$name1/watch:/watch `cat $docker/note/$name\1.sh` $jx" >> $docker/$name1/$name1\1.sh
printf %s "快检版TRansmission-R13" >> $docker/$name1/note.txt
fi
printf "%s\n" "访问端口为$WEBUI，数据传输端口为$PEERPORT" "默认帐号为$tra，默认密码为$trb" "设置文件为$docker/$name1/config" "`cat $docker/$name/note1.txt`"  >> $docker/$name1/note.txt
chmod +x $docker/$name1/$name1\1.sh
sh $docker/$name1/$name1\1.sh
printf %s "-v $docker/$name1/torrents " >> $docker/note/IYUU1.sh
cat $docker/$name1/note.txt | tee $docker/note.txt -a > /dev/null
}



#安装片库QB
pkqb() {
qbaza
#pklx=片库类型，根据片库类型去设置好路径
for pklx in "【电影】" "【电视剧】" "【动漫】"
do
ljpk
done
qbazb
name6=$name
}

#安装nastools
nt() {
mkdir $docker/nastools -p
echo "#!/bin/bash" >> $docker/$name2/$name2.sh
printf %s "sudo docker run -d --name nastools --restart=always --net=host --hostname nas-tools -e TZ="Asia/Shanghai" -e PUID=$uid -e PGID=$gid -e UMASK=022 -e NASTOOL_AUTO_UPDATE=true -v $docker/$name2:/config `cat $docker/note/$name\2.sh` jxxghp/nas-tools:latest > /dev/null" >> $docker/$name2/$name2.sh
chmod +x $docker/$name2/$name2.sh
sh $docker/$name2/$name2.sh
printf "%s\n" "nastool端口为3000，默认用户名是admin，默认密码是password" "`cat $docker/$name/note2.txt`" >> $docker/note.txt
}

#媒体服务器
mtfwq() {
echo "现在开始安装媒体服务器"
yh
printf "%-20s  %-20s  %-20s  %-20s\n" 支持的媒体服务器有 （1）plex （2）emby （3）jellyfin
read -p "请选择一个媒体服务器【1-3】:" mt
if [ $mt = 1 ];then
mkdir $docker/plex -p
printf %s "sudo docker run -d --name=plex --restart unless-stopped --net=host -e PUID=$uid -e PGID=$gid -e VERSION=docker -v $docker/plex:/config `cat $docker/note/$name\3.sh` lscr.io/linuxserver/plex:latest > /dev/null" >> $docker/plex/plex.sh
chmod +x $docker/plex/plex.sh
sh $docker/plex/plex.sh
printf "%s\n" "plex已安装，端口号为32400，第一次访问请在32400后加/web来访问，即ip:32400/web" "`cat $docker/$name/note3.txt`" >> $docker/note.txt
elif [ $mt = 2 ];then
mkdir $docker/emby -p
printf "sudo docker run -d --name=emby --restart unless-stopped --net=host -e PUID=$uid -e PGID=$gid -e TZ=Asia/Shanghai -v $docker/emby:/config `cat $docker/note/$name\3.sh`" >> $docker/emby/emby.sh
if [ -c `ls /dev/dri | grep renderD128` ];then
printf %s "--device /dev/dri:/dev/dri " >> $docker/emby/emby.sh
fi
printf "lscr.io/linuxserver/emby:latest > /dev/null" >> $docker/emby/emby.sh
chmod +x $docker/emby/emby.sh
sh $docker/emby/emby.sh
printf "%s\n" "emby已安装，端口号为8096" "`cat $docker/$name/note3.txt`" >> $docker/note.txt
elif [ $mt = 3 ];then
mkdir $docker/emby -p
printf %s "sudo docker run -d --name=jellyfin --restart unless-stopped --net=host -e PUID=$uid -e PGID=$gid -e TZ=Asia/Shanghai -v $docker/emby:/config `cat $docker/note/$name\3.sh` >> $docker/jellyfin/jellyfin.sh"
if [ -c `ls /dev/dri | grep renderD128` ];then
printf %s "--device /dev/dri:/dev/dri " >> $docker/jellyfin/jellyfin.sh
fi
printf %s "lscr.io/linuxserver/jellyfin:latest > /dev/null" >> $docker/jellyfin/jellyfin.sh
chmod +x $docker/jellyfin/jellyfin.sh
sh $docker/jellyfin/jellyfin.sh
printf "%s\n" "jellyfin已安装，端口号为8096" "`cat $docker/$name/note3.txt`" >> $docker/note.txt
fi
}

#安装其他用途的QB,TR和其他容器
qtqb() {
echo "现在开始安装片库以外用途的QB，TR以及其他容器"
for qb in {1..10}
do
read -p "是否还需要安装其他用途的Qbittorrent【是请直接回车，否请随意输入后回车】:" qb2
if [ $qb2 ];then
echo "不安装Qbittorrent"
echo " "
break
else
qbaza
lj
qbazb
fi
done
}

#安装tr
qttr() {
for tr in {1..10}
do
read -p "是否需要安装Transmission【是请直接回车，否请随意输入后回车】:" tr2
if [ $tr2 ];then
echo "不安装Transmission"
echo " "
break
else
traza
name=$name1
yh
lj
trazb
fi
done
}

#Vertex
vt() {
mkdir $docker/vertex -p
read -p "现在开始安装vertex，WEBUI端口设置为【因为装了上面的nastools，不能选3000，以及其他已添加过的端口】:" WEBUI
sudo docker run -d \
--name vertex \
--restart=unless-stopped \
-v $docker/vertex:/vertex \
-p $WEBUI:3000 \
-e TZ=Asia/Shanghai \
lswl/vertex:stable > /dev/null
sleep 3
echo "vertex端口号为$WEBUI,用户名为admin,密码为`sudo cat $docker/vertex/data/password`" >> $docker/note.txt
}

#IYUU
iy() {
mkdir $docker/IYUU -p
printf "sudo docker run -d --restart=always --name IYUU --net=host -v $docker/IYUU/:/IYUU/db -v $docker/IYUU/:/IYUU `cat $docker/note/IYUU1.sh` iyuucn/iyuuplus > /dev/null" >> $docker/IYUU/IYUU.sh
chmod +x $docker/IYUU/IYUU.sh
sh $docker/IYUU/IYUU.sh
printf "%s\n" "IYUU端口号为8787,打开https://iyuu.cn/" "点击开始使用，并微信扫码，获得爱语飞飞TOKEN" "密码为空，第一次输入时你可以自由设置你的密码；以后密码与第一次相同才能登录" >> $docker/note.txt
}


#Portainer
po() {
mkdir $docker/portainer -p
sudo docker run -d \
--name portainer \
--restart=always \
-p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $docker/portainer:/data \
6053537/portainer-ce > /dev/null
echo "portainer端口号为9000" >> $docker/note.txt
}

#Filebrower
fb() {
mkdir $docker/filebrowser -p
echo "现在开始安装filebrowser，用root用户运行的话，操作空间更大,对新手更友好，但操作前请明确自己知道在做什么"
yh
sudo docker run -d \
--name filebrowser \
--restart=always \
--net=host \
-e PUID=$uid \
-e PGID=$gid \
-e SSL=on \
-e WEB_PORT=8092 \
-e FB_AUTH_SERVER_ADDR=127.0.0.1 \
-v /:/myfiles \
-v $docker/filebrowser:/config \
80x86/filebrowser > /dev/null
echo "filebrowser端口号为8092,默认用户名为admin，默认密码为admin" >> $docker/note.txt
}

#Ddns-go
dd() {
mkdir $docker/ddns -p
sudo docker run -d \
--name ddns \
--restart=always \
--net=host \
-v $docker/ddns:/root \
jeessy/ddns-go > /dev/null
echo "ddns-go端口号为9876" >> $docker/note.txt
}

#NPM
npm() {
echo "现在开始安装npm"
yh
mkdir $docker/npm -p
sudo docker run -d \
--name npm \
--restart=always \
--net=host \
-e USER_ID=$uid \
-e GROUP_ID=$gid \
-e DISABLE_IPV6=0 \
-v $docker/npm:/config:rw \
jlesage/nginx-proxy-manager:latest > /dev/null
echo "npm端口为8181，记得去路由器做端口映射，内网ip为nas的ip，端口为4443" >> $docker/note.txt
}

#VWD
bwd() {
mkdir $docker/bitwarden -p
read -p "现在开始安装bitwarden，WEBUI端口设置为:" WEBUI3
sudo docker run -d \
--name bitwarden \
--restart=always \
-e SIGNUPS_ALLOWED:false \
-v $docker/bitwarden:/data \
-p $WEBUI3:80 \
vaultwarden/server:latest > /dev/null
echo "bitwarden端口为$WEBUI3，先设置好反向代理后去再设置bwd" >> $docker/note.txt
}

#Heimdall
hm() {
mkdir $docker/heimdall -p
read -p "现在开始安装heimdall，WEBUI端口设置为:" WEBUI4
sudo docker run -d \
--name=heimdall \
-e PUID=$uid1 \
-e PGID=$gid1 \
-e TZ=Asia/Shanghai \
-p $WEBUI4:80 \
-p 39999:443 \
-v $docker/heimdall:/config \
--restart unless-stopped \
lscr.io/linuxserver/heimdall:latest > /dev/null
echo "heimdall端口为$WEBUI4" >> $docker/note.txt
}

#书库漫画库
kom() {
mkdir $docker/komga/config $docker/komga/tmp -p
read -p "现在开始安装komga，WEBUI端口设置为：" WEBUI5
printf %s "sudo docker run -d --name komga --restart unless-stopped --user $uid1:$gid1 -p $WEBUI5:8080 -v $docker/komga/config:/config -v $docker/komga/tmp:/tmp " >> $docker/komga/komga.sh
for var in {1..20}
do
if [ $var = 1 ];then
komlj
elif [ $var -gt 1 ];then
read -p "是否新增书/漫画路径$var【是请直接回车，否请随意输入后回车】:" lj
if [ $lj ];then
break
else
komlj
fi
fi
done
printf %s "gotson/komga > /dev/null" >> $docker/komga/komga.sh
chmod +x $docker/komga/komga.sh
sh $docker/komga/komga.sh
printf "%s\n" "komga端口为$WEBUI5" "`cat $docker/komga/note.txt`" >> $docker/note.txt
}

komlj() {
read -p "书/漫画路径$var(如/volume1/book或/mnt/yinpanA/book):" XZ
read -p "书/漫画路径$var映射(如/book)为:" xz
mkdir $XZ -p
printf %s "-v $XZ:$xz " >> $docker/komga/komga.sh
printf "%s\n" "书/漫画路径$var,$XZ映射为$xz" >> $docker/komga/note.txt
}

alist() {
sudo docker run -d \
--restart=always \
--name=alist \
-v $docker/alist:/opt/alist/data \
-p 5244:5244 \
-e PUID=0 -e PGID=0 -e UMASK=022 \
xhofe/alist:latest > /dev/null
alistu=`docker exec -it alist ./alist admin | grep username`
alistp=`docker exec -it alist ./alist admin | grep password`
echo "alist端口为5244" "$alistu" "$alistp" >> $docker/note.txt
}

az() {
printf "%-20s\n" 需要安装的是： （0）以下所有容器 （1）自动化片库 （2）QB和对应TR（TR可装可不装） （3）TR （4）vertex （5）iyuu （6）portainer （7）filebrowser （8）ddns （9）npm反向代理 （10）bitwarden （11）heimdall （12）komga （13）alist
read -p "请选择需要安装的容器【0-13】:" doc
if [ $doc = 0 ];then
pkqb && nt && mtfwq && qtqb && qttr && vt && iy && po && fb && dd && npm && bwd && hm && kom && alist
elif [ $doc = 1 ];then
pkqb && nt && mtfwq
elif [ $doc = 2 ];then
qtqb
elif [ $doc = 3 ];then
qttr
elif [ $doc = 4 ];then
vt
elif [ $doc = 5 ];then
iy
elif [ $doc = 6 ];then
po
elif [ $doc = 7 ];then
fb
elif [ $doc = 8 ];then
dd
elif [ $doc = 9 ];then
npm
elif [ $doc = 10 ];then
bwd
elif [ $doc = 11 ];then
hm
elif [ $doc = 12 ];then
kom
elif [ $doc = 13 ];then
alist
fi
}

printf "%s\n" "【注意事项】" "1.解释一下路径，片库下载路径，如/volume1/dianying，映射为/dy，那么，该QB实际下载的路径为/volume1/dianying/dy，nt硬链接后的文件路径为/volume1/dianying/nt/dy" "2.以下运行过程中的所有输入，不可输入中文，请按提示输入英文/数字或直接回车" "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

user=`whoami`
uid1=`sudo cat /etc/passwd | grep $user | cut -f3 -d":"`
gid1=`sudo cat /etc/passwd | grep $user | cut -f4 -d":"`
read -p "docker设置文件路径设置为(如/volume1/docker或/volume1/A/docker,不需要写qb和里面的config这种):" docker
sudo mkdir $docker/note -p
sudo chown $uid1:$gid1 -R $docker

az
if [ $doc -gt 0 ];then
read -p "是否继续安装其他容器【是请直接回车，否请随意输入后回车】:" con
if [ $con ];then
echo 安装结束
else
az
fi
fi

echo '以后需要查看本次装机相关内容请输入cat $docker/note.txt可查看【这句指令建议记录好】' >> $docker/note.txt
echo " "
cat $docker/note.txt
