# PVE创建OpenWrt虚拟机配置命令



PVE的qm命令相关帮助文档见PVE WEB界面右上角文档，打开后地址如

https://192.168.1.3:8006/pve-docs/qm.1.html



## 1、创建虚拟机

```
qm create <vmid> [OPTIONS]
创建或恢复虚拟机

<vmid>: <integer> (1 - N) 
大于1的整数，虚拟机的ID

--bios <ovmf | seabios> (default = seabios)
虚拟机的BIOS设置，默认seabios

--boot [[legacy=]<[acdn]{1,4}>] [,order=<device[;device...]>]
引导选项，cdn，c即cdrom，d即disk，n即net，order=后面即设置的引导顺序

--bootdisk (ide|sata|scsi|virtio)
从某个盘启动

--cores <integer> (1 - N) (default = 1)
CPU的核心数

--cpu [[cputype=]<string>] [,flags=<+FLAG[;-FLAG...]>] [,hidden=<1|0>] [,hv-vendor-id=<vendor-id>] [,phys-bits=<8-64|host>] [,reported-model=<enum>]
CPU配置项，一般host类型性能较好；flags=后面是CPU的指令集

--hotplug <string> (default = network,disk,usb)
热插拔，默认为网络，硬盘，USB；个人按默认设置出现openwrt无法启动，需要将热插拔改为网络、硬盘。

--ipconfig[n] [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]
网络设置，openwrt忽略，linux系统可以设置，设置网关、IP等

--machine (pc|pc(-i440fx)?-\d+(\.\d+)+(\+pve\d+)?(\.pxe)?|q35|pc-q35-\d+(\.\d+)+(\+pve\d+)?(\.pxe)?|virt(?:-\d+(\.\d+)+)?(\+pve\d+)?)
机器类型，有q35与i440fx选项，先q35较好一些。

--memory <integer> (16 - N) (default = 512)
内存大小，默认512MB

--name <string>
虚拟机名称，可以设置如OpenWrt、Debian等

--nameserver <string>
DNS服务器设置

--net[n] [model=]<enum> [,bridge=<bridge>] [,firewall=<1|0>] [,link_down=<1|0>] [,macaddr=<XX:XX:XX:XX:XX:XX>] [,mtu=<integer>] [,queues=<integer>] [,rate=<number>] [,tag=<integer>] [,trunks=<vlanid[;vlanid...]>] [,<model>=<macaddr>]
设置网络类型，linux类系统一般选择半虚拟化，即virtio；桥接，设置为自己的网卡，如vmbr0；firewall默认开启，如需关闭，设置为firewall=0

--onboot <boolean> (default = 0)
是否开机自启动，默认关闭，如需开启设置为1

--ostype <l24 | l26 | other | solaris | w2k | w2k3 | w2k8 | win10 | win11 | win7 | win8 | wvista | wxp>
系统类型，openwrt设置为l26，即linux 2.6

--sata[n] [file=]<volume> [,aio=<native|threads|io_uring>] [,backup=<1|0>] [,bps=<bps>] [,bps_max_length=<seconds>] [,bps_rd=<bps>] [,bps_rd_max_length=<seconds>] [,bps_wr=<bps>] [,bps_wr_max_length=<seconds>] [,cache=<enum>] [,cyls=<integer>] [,detect_zeroes=<1|0>] [,discard=<ignore|on>] [,format=<enum>] [,heads=<integer>] [,iops=<iops>] [,iops_max=<iops>] [,iops_max_length=<seconds>] [,iops_rd=<iops>] [,iops_rd_max=<iops>] [,iops_rd_max_length=<seconds>] [,iops_wr=<iops>] [,iops_wr_max=<iops>] [,iops_wr_max_length=<seconds>] [,mbps=<mbps>] [,mbps_max=<mbps>] [,mbps_rd=<mbps>] [,mbps_rd_max=<mbps>] [,mbps_wr=<mbps>] [,mbps_wr_max=<mbps>] [,media=<cdrom|disk>] [,replicate=<1|0>] [,rerror=<ignore|report|stop>] [,secs=<integer>] [,serial=<serial>] [,shared=<1|0>] [,size=<DiskSize>] [,snapshot=<1|0>] [,ssd=<1|0>] [,trans=<none|lba|auto>] [,werror=<enum>] [,wwn=<wwn>]
硬盘选项，同类型还有--scsi，无需要设置，虚拟机建立后可以手动添加

--sockets <integer> (1 - N) (default = 1)
CPU插槽数，默认为1，即1个CPU插槽

--vcpus <integer> (1 - N) (default = 0)
热插拔的虚拟CPU数，一般不需要设置
```



#### 举例：

```shell
qm create 102 \
--name OpenWrt \
--ostype l26 \
--machine q35 \
--bios ovmf \
--scsihw virtio-scsi-pci \
--cores 4 \
--sockets 1 \
--cpu host,flags=+aes \
--memory 2048 \
--bios ovmf \
--net0 model=virtio,bridge=vmbr0,firewall=0 \
--hotplug network,disk \
--boot dn,order=sata0 \
--bootdisk sata0 \
--onboot 1 \
--startup order=2,up=30,down=30
```



## 2、删除虚拟机

```
qm destroy <vmid> [OPTIONS]
```

Destroy the VM and all used/owned volumes. Removes any VM specific permissions and firewall rules



## 3、设置虚拟机选项

```
qm set <vmid> [OPTIONS]
```

Set virtual machine options (synchrounous API) - You should consider using the POST method instead for any actions involving hotplug or storage allocation.



## 4、导入硬盘镜像

```
qm importdisk <vmid> <source> <storage> [OPTIONS]
#############例如#############
#qm importdisk id /home/qcow2/openwrt.qcow2  储存的目录,默认是 local-lvm

#qm importdisk 102 /var/lib/vz/template/iso/openwrt.img local-lvm
102即虚拟机的VM ID，openwrt.img即为ISO镜像文件，local-lvm即本地存储ID
```



## 5、转移虚拟机硬盘

qm move-disk \<vmid> \<disk> [\<storage>] [OPTIONS]

将卷移动到不同的存储或不同的 VM。



\<vmid> : \<integer> (1 - N)
VM 的（唯一）ID。



\<disk>: <efidisk0 | ide0 | ide1 | ...>

虚拟机磁盘



\<storage>: \<string>

目标存储，如local-lvm，local



--format <qcow2 | raw | vmdk>

目标卷格式，默认为raw



--target-disk <efidisk0 | ide0 | ide1 | ...>

目标磁盘



--target-vmid <integer> (1 - N)

目标虚拟机ID



> 其它，请参照pct命令。





## 6、其它qm命令

```
   USAGE: qm <COMMAND> [ARGS] [OPTIONS]
   qm agent <vmid> <command>
   qm clone <vmid> <newid> [OPTIONS]
   qm config <vmid> [OPTIONS]
   qm create <vmid> [OPTIONS]
   qm delsnapshot <vmid> <snapname> [OPTIONS]
   qm destroy <vmid> [OPTIONS]
   qm list  [OPTIONS]
   qm listsnapshot <vmid>
   qm migrate <vmid> <target> [OPTIONS]
   qm move_disk <vmid> <disk> <storage> [OPTIONS]
   qm pending <vmid>
   qm reset <vmid> [OPTIONS]
   qm resize <vmid> <disk> <size> [OPTIONS]
   qm resume <vmid> [OPTIONS]
   qm rollback <vmid> <snapname>
   qm sendkey <vmid> <key> [OPTIONS]
   qm set <vmid> [OPTIONS]
   qm shutdown <vmid> [OPTIONS]
   qm snapshot <vmid> <snapname> [OPTIONS]
   qm start <vmid> [OPTIONS]
   qm stop <vmid> [OPTIONS]
   qm suspend <vmid> [OPTIONS]
   qm template <vmid> [OPTIONS]
   qm unlink <vmid> -idlist <string> [OPTIONS]
   qm monitor <vmid>
   qm mtunnel 
   qm rescan  [OPTIONS]
   qm showcmd <vmid>
   qm status <vmid> [OPTIONS]
   qm terminal <vmid> [OPTIONS]
   qm unlock <vmid>
   qm vncproxy <vmid>
   qm wait <vmid> [OPTIONS]
   qm help [<cmd>] [OPTIONS]
```



#### 举例：

设置虚拟系统vm的cpu类型为host

```
qm set <vmid> --cpu cputype=host
```
对应图形界面设置：选择vm,“硬件”–“处理器”–“类型”–“host"
