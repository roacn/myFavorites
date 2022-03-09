

### 安装curl命令

使用root用户登录，执行以下命令

```shell
apt update && apt install -y curl
```



### 设置中文语言包

命令行

```shell
dpkg-reconfigure locales → [ * ] en_US.UF8
```

文件编译

```shell
/etc/locale.gen去除en_US.UF8前面#
```

重启PVE即可



### PVE一键换源、去订阅等

> 以下请在PVE命令行中运行！

国内网络

```shell
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/pve_onekey.sh)"
```

国外网络

```shell
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/pve_onekey.sh)"
```



### LXC容器OpenWrt安装、更新

> 以下请在PVE命令行中运行！


- [x] PVE中直接使用`openwrt`命令运行自动安装更新脚本

国内网络

```shell
wget https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh -O /usr/sbin/openwrt && chmod +x /usr/sbin/openwrt
```

国外网络

```shell
wget https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh -O /usr/sbin/openwrt && chmod +x /usr/sbin/openwrt
```

即可在PVE命令行中使用`openwrt`运行脚本


- [x] 直接运行

国内网络

```shell
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh)"
```

国外网络

```shell
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh)"
```

![openwrt11.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt11.png)

![openwrt12.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt12.png)

![openwrt2.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt2.png)

![openwrt3.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt3.png)

![openwrt4.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt4.png)

![openwrt5.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt5.png)
