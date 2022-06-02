## 1、创建容器

**pct create** \<vmid\> \<ostemplate\> [OPTIONS]

创建或恢复容器



\<vmid\>:\<integer\>(1 - N)

容器ID



\<ostemplate\>:\<string\>

容器模板的文件路径，local:vztmpl/openwrt-x86-64-generic-rootfs.tar.gz，local:vztmpl/ 指向/var/lib/vz/template/cache/目录，openwrt-x86-64-generic-rootfs.tar.gz即为容器模板文件。



--arch \<amd64 | arm64 | armhf | i386\> (*default =* amd64)

系统架构，默认为amd64



--cores \<integer\> (1 - 8192)

CPU核数，默认是全部CPU核数



--hostname \<string\>

lxc容器名称



--memory \<integer\> (16 - N) (*default =* 512)

内存，默认512MB



--mp[n] [volume=]\<volume\> ,mp=\<Path\> [,acl=\<1|0\>] [,backup=\<1|0\>] [,mountoptions=\<opt[;opt...]\>] [,quota=\<1|0\>] [,replicate=\<1|0\>] [,ro=\<1|0\>] [,shared=\<1|0\>] [,size=\<DiskSize\>]

挂载设置



--net[n] name=\<string\> [,bridge=\<bridge\>] [,firewall=\<1|0\>] [,gw=\<GatewayIPv4\>] [,gw6=\<GatewayIPv6\>] [,hwaddr=\<XX:XX:XX:XX:XX:XX\>] [,ip=\<(IPv4/CIDR|dhcp|manual)\>] [,ip6=\<(IPv6/CIDR|auto|dhcp|manual)\>] [,mtu=\<integer\>] [,rate=\<mbps\>] [,tag=\<integer\>] [,trunks=\<vlanid[;vlanid...]\>] [,type=\<veth\>]

网络设置，设置为--net0 bridge=vmbr0,name=eth0，设置网络0为容器中增加网卡eth0，桥接到主机的vmbr0接口。



--onboot \<boolean\> (*default =* 0)

是否开机自启，默认为否



--ostype \<alpine | archlinux | centos | debian | devuan | fedora | gentoo | opensuse | ubuntu | unmanaged\>

系统类型，用于设置容器内的系统类型，可以在设置文件中修改。

设置为相应的系统，即按照/usr/share/lxc/config/\<ostype\>.common.conf里的设置进行配置，如设置为debian，则按照/usr/share/lxc/config/debian.common.conf对容器内系统进行设置；如果设置为unmanaged，会跳过此处设置并对系统进行单独设置。对于openwrt，设置为unmanaged。



--password \<password\>

设置容器内系统root用户的密码，与图形化操作相同



--rootfs [volume=]\<volume\> [,acl=\<1|0\>] [,mountoptions=\<opt[;opt...]\>] [,quota=\<1|0\>] [,replicate=\<1|0\>] [,ro=\<1|0\>] [,shared=\<1|0\>] [,size=\<DiskSize\>]

linux类系统根文件系统设置，--rootfs local-lvm:2，即代表使用local-lvm本地存储，分配2GB容量



--ssh-public-keys \<filepath\>

设置ssh连接的公钥，一般不需要设置；对于openwrt可在web管理页面设置



--swap \<integer\> (0 - N) (*default =* 512)

交换区大小设置，默认为512MB，可以设置为0



--tty \<integer\> (0 - 6) (*default =* 2)

tty计数，默认为2，一般不需要设置



--unprivileged \<boolean\> (*default =* 0)

无特权的容器，默认为否。



#### 举例：



1、创建OpenWrt的lxc容器

```
pct create 102 \
local:vztmpl/openwrt.rootfs.tar.gz \
--rootfs local-lvm:1 \
--ostype unmanaged \
--hostname OpenWrtX \
--arch amd64 \
--cores 4 \
--memory 2048 \
--swap 0 \
--net0 bridge=vmbr0,name=eth0 \
--net1 bridge=vmbr1,name=eth1 \
--unprivileged 1 \
--features nesting=1
```



2、创建debian的LXC容器

```
pct create 106 \
local:vztmpl/debian-11-standard_11.0-1_amd64.tar.gz \
--rootfs local-lvm:8 \
--ostype debian \
--hostname Debian \
--arch amd64 \
--cores 2 \
--memory 4096 \
--swap 1024 \
--net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.1.2,ip=192.168.1.6/24,mtu=1492,type=veth \
--nameserver 192.168.1.2 \
--onboot 1 \
--startup order=3,up=60,down=60 \
--password 888888 \
--unprivileged 1 \
--features nesting=1
```



## 2、配置容器

**pct config** \<vmid\> [OPTIONS]

获取容器配置



\<vmid\>: \<integer\> (1 - N)

容器的ID



#### 举例

pct config 102即为获取lxc容器ID为102的配置 。

```
root@pve:/var/lib/vz/template/cache# pct config 102
arch: amd64
cores: 4
features: nesting=1
hostname: OpenWrtX
memory: 2048
nameserver: 192.168.1.1
net0: name=eth0,bridge=vmbr0,gw=192.168.1.1,hwaddr=CE:91:0A:25:A2:9A,ip=192.168.1.2/24,type=veth
onboot: 1
ostype: unmanaged
rootfs: local-lvm:vm-102-disk-0,size=1G
startup: order=2,up=30,down=30
swap: 1024
```



## 3、执行命令

**pct exec** \<vmid\> [\<extra-args\>]

在容器内执行一条命令



## 4、容器列表

**pct list**

列出当前所有的pct容器



## 5、容器挂载至PVE目录

**pct mount** \<vmid>

在主机上挂载容器的文件系统。这将锁定容器，仅用于紧急维护，因为它将阻止容器上的进一步操作，而不是启动和停止。

\<vmid> : <整数> (1 - N)
VM 的（唯一）ID。

一般在ID为\<vmid>的LXC容器出了问题，无法正常启动，需要维护时使用，比如复制该容器内的重要资料。

#### 举例：

ID为116的LXC容器无法启动，需要复制容器内资料出来。



1、挂载

```shell
pct mount 116	#将116容器挂载至PVE系统
```

> 注意：pct挂载容器后，该容器处于“锁定”状态，容器将暂时无法启动，后期如有启动需求，需要先解锁容器状态。

然后就可以通过进入该目录操作容器116的文件。

恢复资料后的后续操作



2、解除116容器挂载

```shell
umount /var/lib/lxc/116/rootfs
```

> 注意，只有在分区未被程序使用的情况下才能成功用此法卸载，否则会报错，如：

```shell
root@pve:~# umount /var/lib/lxc/116/rootfs
umount: /var/lib/lxc/116/rootfs: target is busy.
```

则可以使用如下命令卸载：

```shell
umount -l /var/lib/lxc/116/rootfs	#lazy umount正是针对上面错误中的busy而提出的，即可以卸载“busy”的文件系统。
```



3、解除容器锁定

命令：`pct unlock <vmid>`	#\<vmid>替换为实际的容器ID

比如本例为：

```shell
pct unlock 116
```

通过以上，

具体操作如下：

```shell
Linux pve 5.15.35-1-pve #1 SMP PVE 5.15.35-3 (Wed, 11 May 2022 07:57:51 +0200) x86_64
Last login: Wed May 25 16:33:56 2022 from 192.168.1.8
root@pve:~# cd /var/lib/lxc/116/rootfs		#查看/var/lib/lxc/116/rootfs目录，未挂载前此目录为空
root@pve:/var/lib/lxc/116/rootfs# ls
root@pve:/var/lib/lxc/116/rootfs# cd /root
root@pve:~# pct mount 116					#将116容器挂载至PVE系统的/var/lib/lxc/116/rootfs目录
mounted CT 116 in '/var/lib/lxc/116/rootfs'
root@pve:~# cd /var/lib/lxc/116/rootfs
root@pve:/var/lib/lxc/116/rootfs# ls		#查看/var/lib/lxc/116/rootfs目录，此目录内为116容器内目录、文件
bin  boot  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  tmp.rej  usr  var
root@pve:/var/lib/lxc/116/rootfs# cd opt	#进入目标目录
root@pve:/var/lib/lxc/116/rootfs/opt# ls
backup  containerd  lost+found  ql  qls  qlx
root@pve:/var/lib/lxc/116/rootfs/opt# cd ql
root@pve:/var/lib/lxc/116/rootfs/opt/ql# ls
config  db  deps  log  raw  repo  scripts
root@pve:/var/lib/lxc/116/rootfs/opt/ql# cp -r config /tmp	#将116容器内的ql配置文件复制至PVE系统的/tmp目录
root@pve:/var/lib/lxc/116/rootfs/opt/ql# cd /tmp
root@pve:/tmp# ls
config
root@pve:/tmp# cd config
root@pve:/tmp/config# ls
auth.json  config.sh  crontab.list  diy-repo-hw.sh  diy-repo-leafxcy.sh  diy-repo-smiek2221.sh  diy-repo-zero205.sh  env.sh  extra.sh  npm-g.sh  npm.sh  task_after.sh  task_before.sh	#就可以通过WinSCP等工具保存
root@pve:/tmp# umount -l /var/lib/lxc/116/rootfs			#解除挂载
root@pve:/tmp# pct lock 116									#解锁116容器（未）
```



## 6、移动卷至不同容器

**pct move-volume \<vmid> \<volume> [\<storage>] [\<target-vmid>] [\<target-volume>] [OPTIONS]**

将 rootfs-/mp-volume 移动到不同的存储或不同的容器。



\<vmid> : <整数> (1 - N)
VM 的（唯一）ID。



\<volume>: <mp0 | mp1 | ... >

被移动的卷，即挂载的mp0、mp1等



\<storage>: \<string>

目标存储，如local-lvm，local



\<target-vmid>: \<integer> (1 - N)

目标容器ID



\<target-volume>: \<mp0 | mp1 | ...>

目录卷，即挂载的mp0、mp1等





#### 举例：

将116容器的mp0移动至106容器的mp2

使用命令：`pct move-volume 116 mp0 --target-vmid 106 --target-volume mp2`

```shell
root@pve:/var/lib/lxc/116# pct move-volume 116 mp0 --target-vmid 106 --target-volume mp2
moving volume 'mp0' from container '116' to '106'
  Renamed "vm-116-disk-1" to "vm-106-disk-3" in volume group "pve"
removing volume 'mp0' from container '116' config
explicitly configured lxc.apparmor.profile overrides the following settings: features:fuse, features:nesting, features:mount
target container '106' updated with 'mp2'
```

以上移动在web管理页面操作如下：

- [ ] 1、选中要转移的挂载点，如容器106的mp2挂载点
- [ ] 2、点击上方“Volume Action”
- [ ] 3、点击“Reassign Owner”
- [ ] 4、选择目标容器
- [ ] 5、修改目标挂载点为正确的挂载点
- [ ] 6、点击“Reassign Volume”确认！

![转移挂载1](/img/转移挂载1.jpg)

![转移挂载2](/img/转移挂载2.jpg)

![转移挂载3](/img/转移挂载3.jpg)



#### 举例：

将106的mp2挂载从local-lvm转移至local存储下

使用命令：`pct move-volume 106 mp2 --storage local`或`pct move-volume 106 mp2 local`

> 注意：原存储下的挂载仍然存在，处于分离状态，可以登录web管理页面手动删除。

```shell
root@pve:/var/lib/lxc/116# pct move-volume 106 mp2 --storage local
Formatting '/var/lib/vz/images/106/vm-106-disk-0.raw', fmt=raw size=8589934592 preallocation=off
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: b771605f-d33e-4db5-8cac-3465131a7298
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Number of files: 80,465 (reg: 64,334, dir: 14,461, link: 1,670)
Number of created files: 80,463 (reg: 64,334, dir: 14,459, link: 1,670)
Number of deleted files: 0
Number of regular files transferred: 48,327
Total file size: 879,361,570 bytes
Total transferred file size: 758,022,378 bytes
Literal data: 758,022,378 bytes
Matched data: 0 bytes
File list size: 4,584,713
File list generation time: 0.005 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 767,212,246
Total bytes received: 3,619,969

sent 767,212,246 bytes  received 3,619,969 bytes  27,046,744.39 bytes/sec
total size is 879,361,570  speedup is 1.14
```





## 7、重启容器

**pct reboot** \<vmid\> [OPTIONS]

重启容器



## 8、调整挂载点容量

**pct resize** \<vmid\> \<disk\> \<size\> [OPTIONS]

重新设置容器挂载点大小，仅支持增加容量，不支持缩小磁盘容量



\<vmid>:\<integer> (1 - N)

容器ID



\<disk>: <mp0 | mp1 | ...>

挂载点，如mp0、mp1等



\<size>: \+?\d+(\.\d+)?[KMGT]?

新的磁盘大小。如果在磁盘大小前包含“+”，表示增加多少容量，如，+10G，表示“增加10G”；如果不包含，则表示磁盘新的容量，如，50G，表示“将磁盘变更为50G容量”（需要比原来容量大，因为不支持减小磁盘容量）

其中，KMGT，分别表示“KB”、“MB”、“GB”、“TB”容量单位



## 9、容器设置

**pct set** \<vmid\> [OPTIONS]

设置容器的各个选项，参考pct set的选项



## 10、关闭容器

**pct shutdown** \<vmid\> [OPTIONS]

关闭容器，触发关闭容器命令，并由容器自行关闭内部进程，进而关机。



## 11、启动容器

**pct start** \<vmid\> [OPTIONS]

启动容器



## 12、停止容器

**pct stop** \<vmid\> [OPTIONS]

停止容器，强制停止容器内的进程，并关闭容器

