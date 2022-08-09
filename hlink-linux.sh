#!/bin/bash
wget https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz
mv node-v16.16.0-linux-x64.tar.xz node.tar.gz
chown 1000:1000 -R /mnt/Z && chmod 777 -R /mnt/Z
apt-get install npm -y
npm install -g hlink
tar -xvf /mnt/Z/node.tar.gz
mv node-v16.16.0-linux-x64 node
ln -s /mnt/Z/node/bin/npm /usr/local/bin/
ln -s /mnt/Z/node/bin/node /usr/local/bin/
ln -s /mnt/Z/node/bin/hlink /usr/local/bin/
hlink -g
tee /root/hlink.config.mjs  <<-'EOB'
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
chown 1000:1000 -R /mnt/Z/ && chmod 777 -R /mnt/Z/
cp /root/hlink.config.mjs /mnt/Z/hlink.config.mjs
tee /mnt/Z/hlinkhj.sh <<-'EOF'
#! /bin/bash
ln -s /mnt/Z/node/bin/npm /usr/local/bin/
ln -s /mnt/Z/node/bin/node /usr/local/bin/
ln -s /mnt/Z/node/bin/hlink /usr/local/bin/
ln -s /mnt/Z/hlink.config.mjs /root/hlink.config.mjs
EOF
cp /mnt/Z/hlinkhj.sh /etc/init.d/
chmod 750 /etc/init.d/hlinkhj.sh
update-rc.d hlinkhj.sh defaults
