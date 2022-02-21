- 为防止系统没安装curl，使用不了一键命令，使用下面的一键命令之前先执行一次安装curl命令

# 

- 使用root用户登录ubuntu或者debian系统，后执行以下命令安装curl

```
apt -y update && apt -y install curl
```

- 使用root用户登录centos系统，后执行以下命令安装curl

```
yum install -y curl
```

- 使用root用户登录alpine系统，后执行以下命令安装curl

```
apk add curl bash
```

# 

- ### (centos、ubuntu、debian、alpine)一键开启root用户SSH

国内网络
```
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/Debian/ssh.sh)"
```
国外网络
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/roacn/myFavorites/main/Debian/ssh.sh)"
```

------

- ### PVE一键换源、去订阅等

> 以下请在PVE命令行中运行！

国内网络
```
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/pve_onekey.sh)"
```
国外网络
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/pve_onekey.sh)"
```

------

- ### LXC容器OpenWrt安装

> 以下请在PVE命令行中运行！

国内网络
```
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh)"
```
国外网络
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/roacn/myFavorites/main/PVE/openwrt_lxc_onekey.sh)"
```

![openwrt11.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt11.png)

![openwrt12.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt12.png)

![openwrt2.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt2.png)

![openwrt3.png](https://raw.githubusercontent.com/roacn/myFavorites/main/img/openwrt3.png)


