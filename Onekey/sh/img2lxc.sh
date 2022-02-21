#!/bin/bash
# 恩山论坛有说云编译出来的Lede-x86-64-generic-rootfs.tar.gz可以直接当模板用，未验证
# 云编译Lede-x86-64-generic-squashfs-rootfs.img.gz，下载转换模板
# 安装解包软件
# apt install squashfs-tools
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export LANG=en_US.UTF-8
cpath=$(cd `dirname $0`; pwd)
# 下载最新的x86-64-generic-squashfs-rootfs.img.gz文件
# wget https://ghproxy.com/https://api.github.com/repos/roacn/build-actions/releases/latest
# wget https://ghproxy.com/`awk '{print $2}'  ./latest | grep "x86-64-generic-squashfs-rootfs.img.gz" | grep "github.com" | sed 's/\"//g'`
# rm -f ./latest
# 对下载的img进行解包
# gzip -d  *-x86-64-generic-squashfs-rootfs.img.gz
cd /var/lib/vz/template/iso
unsquashfs *-x86-64-generic-squashfs-rootfs.img
# 打包为pve的CT模板并上传CT模板
if [[ -f /var/lib/vz/template/cache/openwrt.rootfs.tar.gz ]]; then
	rm -f /var/lib/vz/template/cache/openwrt.rootfs.tar.gz
fi
cd squashfs-root && tar zcf /var/lib/vz/template/cache/openwrt.rootfs.tar.gz ./* && cd .. && rm -rf squashfs-root

