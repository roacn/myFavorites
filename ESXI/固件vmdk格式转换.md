使用ESXI，附件vmdk格式不兼容，需要转换为兼容的vmdk格式



1. ssh至ESXi主机

   ```shell
   ssh <用户>@<ESXi主机>
   如：<用户>为root，<ESXi主机>的IP地址为192.168.1.3，命令如下ssh root@192.168.1.3；
   ```

   

2. 切换至vmdk的路径

   ```shell
   cd vmfs/volumes/datastore1
   ```

   

3. 查询vmdk文件

   ```shell
   ls
   ```

   查找上传至ESXI的镜像openwrt-x86-64-generic-squashfs-combined-efi.vmdk是否存在

   

4. 转换vmdk

   使用vmkfstools将不支持的.vmdk转换为ESXi支持的.vmdk格式，

   ```shell
   vmkfstools -i <旧的.vmdk> <新的.vmdk>，
   如：vmkfstools -i  openwrt-x86-64-generic-squashfs-combined-efi.vmdk  openwrt-x86-64-generic-squashfs-combined-efi-esxi.vmdk
   ```

   

5. 调整vmdk大小，

   已避免后期修改虚拟机时保存时"请输入大于原始容量的磁盘大小"出错，执行命令：

   ```shell
   vmkfstools -X 1.5G openwrt-x86-64-generic-squashfs-combined-efi-esxi.vmdk
   ( -X 为大写X   1.5G是要修改成为的磁盘大小 openwrt-x86-64-generic-squashfs-combined-efi-esxi.vmdk是需要修改的磁盘文件，大小 为1K的那个。）
   ```

   当看到Grow: 100% done.说明成功了

