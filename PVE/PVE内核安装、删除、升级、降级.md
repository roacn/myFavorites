### 当前版本信息

```bash
root@pve:~# uname -r
5.13.19-6-pve
```

```bash
root@pve:~# lsb_release -a
Distributor ID: Debian
Description:    Debian GNU/Linux 11 (bullseye)
Release:        11
Codename:       bullseye
```

### 查询已安装内核

```
dpkg --get-selections | grep "kernel"
```

```bash
root@pve:~# dpkg --get-selections | grep "kernel"
pve-kernel-5.13                                 install
pve-kernel-5.13.19-2-pve                        install
pve-kernel-5.13.19-6-pve                        install
pve-kernel-5.15.30-1-pve                        install
pve-kernel-helper                               install
```

### 查询支持内核

```bash
root@pve:~# apt-cache search linux | grep 'PVE Kernel Image'
pve-kernel-5.10.6-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.0-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.12-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.17-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.21-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-2-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-3-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-4-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-5-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-6-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.22-7-pve - The Proxmox PVE Kernel Image
pve-kernel-5.11.7-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.14-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.18-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-2-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-3-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-4-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-5-pve - The Proxmox PVE Kernel Image
pve-kernel-5.13.19-6-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.12-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.17-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.19-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.19-2-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.27-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.30-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.5-1-pve - The Proxmox PVE Kernel Image
pve-kernel-5.15.7-1-pve - The Proxmox PVE Kernel Image
```

### 安装内核

```bash
apt-get install pve-kernel-5.15.30-1-pve
```

### 查看内核启动顺序

```bash
grep menuentry /boot/grub/grub.cfg
# 或者
cat /boot/grub/grub.cfg | grep menuentry
```

```bash
root@pve:~# grep menuentry /boot/grub/grub.cfg
if [ x"${feature_menuentry_id}" = xy ]; then
  menuentry_id_option="--id"
  menuentry_id_option=""
export menuentry_id_option
menuentry 'Proxmox VE GNU/Linux' --class proxmox --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-d1a3417b-b116-4377-a074-ec74c33d1112' {
submenu 'Advanced options for Proxmox VE GNU/Linux' $menuentry_id_option 'gnulinux-advanced-d1a3417b-b116-4377-a074-ec74c33d1112' {
        menuentry 'Proxmox VE GNU/Linux, with Linux 5.15.30-1-pve' --class proxmox --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.15.30-1-pve-advanced-d1a3417b-b116-4377-a074-ec74c33d1112' {
        menuentry 'Proxmox VE GNU/Linux, with Linux 5.15.30-1-pve (recovery mode)' --class proxmox --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.15.30-1-pve-recovery-d1a3417b-b116-4377-a074-ec74c33d1112' {
        menuentry 'Proxmox VE GNU/Linux, with Linux 5.13.19-6-pve' --class proxmox --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.13.19-6-pve-advanced-d1a3417b-b116-4377-a074-ec74c33d1112' {
        menuentry 'Proxmox VE GNU/Linux, with Linux 5.13.19-6-pve (recovery mode)' --class proxmox --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.13.19-6-pve-recovery-d1a3417b-b116-4377-a074-ec74c33d1112' {
menuentry "Memory test (memtest86+)" {
menuentry "Memory test (memtest86+, serial console 115200)" {
menuentry "Memory test (memtest86+, experimental multiboot)" {
menuentry "Memory test (memtest86+, serial console 115200, experimental multiboot)" {
menuentry 'System setup' $menuentry_id_option 'uefi-firmware' {
```

### 修改内核启动顺序
如果你升级的版本比当前内核版本高的话，默认新安装的内核就是第一顺序启动的，只需重启系统就行了，否则，则需要修改配置文件

找到上一步中的名称（启动到时候可以看到）

```bash
Advanced options for Proxmox VE GNU/Linux
Proxmox VE GNU/Linux, with Linux 5.15.30-1-pve
```

修改/etc/default/grub中 GRUB_DEFAULT
可以使用顺序号（从0开始）或使用菜单名称

```bash
vi /etc/default/grub
# 将 GRUB_DEFAULT=0 修改想要的菜单，如果有二级菜单的，用 > 符合指定
# 如这里的改成第二个菜单的第三项

GRUB_DEFAULT="1>2"
# 或者
#GRUB_DEFAULT="Advanced options for Proxmox VE GNU/Linux>Proxmox VE GNU/Linux, with Linux 5.13.19-6-pve"
```

注意有二级菜单时要有引号

其他示例：

```bash
GRUB_DEFAULT= “Previous Linux versions>Ubuntu, with Linux 3.2.0-18-generic-pae”
GRUB_DEFAULT= “Previous Linux versions>0”
GRUB_DEFAULT= “2>0”
GRUB_DEFAULT= “2>Ubuntu, with Linux 3.2.0-18-generic-pae”
```

### 卸载内核

```bash
dpkg --purge --force-remove-essential pve-kernel-5.13.19-2-pve
```

### 更新引导并重启

```bash
update-grub
reboot
```

重启后，使用命令uname -r查看

```bash
root@pve:~# uname -r
5.15.30-1-pve
```

