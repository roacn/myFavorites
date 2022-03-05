LXC容器安装OpenWrt



#### 编译OpenWrt

---

需编译rootfs.img.gz

`make meunconfig` ，然后 `targert images` --> 选中[ * ] ` GZip images`



#### 安装OpenWrt

---

- [x] 上传img文件

把编译的OpenWrt固件x86-64-generic-squashfs-rootfs.img.gz解压缩，并上传至PVE比如上传至存储镜像目录`/var/lib/vz/template/iso`


- [x] 安装解包软件

```
apt install squashfs-tools
```


- [x] 解包img

```shell
gzip -d  *-x86-64-generic-squashfs-rootfs.img.gz
unsquashfs *-x86-64-generic-squashfs-rootfs.img
```


- [x] 上传CT模板

打包为pve的CT模板并上传CT模板

```shell
cd squashfs-root && tar zcf /var/lib/vz/template/cache/openwrt.rootfs.tar.gz ./* && cd .. && rm -rf squashfs-root
```



- [x] 创建lxc容器

```shell
pct create 100 \
local:vztmpl/openwrt.rootfs.tar.gz \
--rootfs local-lvm:2 \
--ostype unmanaged \
--hostname OpenWrt \
--arch amd64 \
--cores 4 \
--memory 2048 \
--swap 0 \
--net0 bridge=vmbr0,name=eth0 \
--net1 bridge=vmbr1,name=eth1 \
--unprivileged 1 \
--features keyctl=1,nesting=1
```

> 注意：

> 其中`local:vztmpl/openwrt.rootfs.tar.gz`，即为`/var/lib/vz/template/cache/openwrt.rootfs.tar.gz`



启动OpenWrt！



#### Fullconenat安装



以下主要为PVE环境下操作



- [x] 软件下载

[netfilter-fullconenat-dkms-git](https://github.com/roacn/myFavorites/blob/main/PVE/lxc%E5%AE%B9%E5%99%A8/netfilter-fullconenat-dkms-git.tar.gz)



- [x] 软件安装

ssh至PVE，运行以下命令

```shell
apt update
apt install pve-headers-`uname -r` -y
apt install dkms -y
```



- [x] 解压netfilter-fullconenat-dkms-git.tar.gz

```shell
tar -xvf netfilter-fullconenat-dkms-git.tar.gz -C /usr/src
```



- [x] 安装netfilter-fullconenat-dkms-git.tar.gz

```shell
dkms install -m netfilter-fullconenat-dkms -v git
```



- [x] 检查是否安装成功

运行`dkms status`

```shell
root@pve:~# dkms status
netfilter-fullconenat-dkms, git, 5.13.19-3-pve, x86_64: installed
```

运行`modinfo xt_FULLCONENAT`

```shell
root@pve:~# modinfo xt_FULLCONENAT
filename:       /lib/modules/5.13.19-3-pve/updates/dkms/xt_FULLCONENAT.ko
alias:          ipt_FULLCONENAT
author:         Chion Tang <tech@chionlab.moe>
description:    Xtables: implementation of RFC3489 full cone NAT
license:        GPL
srcversion:     CE0EBE32D25F6F43D755D2E
depends:        x_tables,nf_nat,nf_conntrack
retpoline:      Y
name:           xt_FULLCONENAT
vermagic:       5.13.19-3-pve SMP mod_unload modversions 
```

出现如上信息，说明fullconenat已经安装成功，OpenWrt在防火墙内开启fullconenat，重启PVE生效。
