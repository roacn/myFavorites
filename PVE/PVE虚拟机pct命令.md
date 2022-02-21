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





举例：





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





**pct config** \<vmid\> [OPTIONS]

获取容器配置





\<vmid\>: \<integer\> (1 - N)

容器的ID





举例

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





**pct exec** \<vmid\> [\<extra-args\>]

在容器内执行一条命令





**pct list**

列出当前所有的pct容器





**pct reboot** \<vmid\> [OPTIONS]

重启容器





**pct resize** \<vmid\> \<disk\> \<size\> [OPTIONS]

重新设置容器挂载点大小





**pct set** \<vmid\> [OPTIONS]

设置容器的各个选项，参考pct set的选项





**pct shutdown** \<vmid\> [OPTIONS]

关闭容器，触发关闭容器命令，并由容器自行关闭内部进程，进而关机。





**pct start** \<vmid\> [OPTIONS]

启动容器





**pct stop** \<vmid\> [OPTIONS]

停止容器，强制停止容器内的进程，并关闭容器

