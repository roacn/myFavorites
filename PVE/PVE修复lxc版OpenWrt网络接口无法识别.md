### PVE修复lxc版OpenWrt网络接口无法识别



#### 问题：

---



- [x] 网络接口无法识别，显示`-`、`半双工`，并且无法获取网卡名称eth0，显示为空；
- [x] 系统日志报错`ethtool: bad command line argument(s)`

```
Tue Feb  1 21:32:28 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:28 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:29 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:29 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:30 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:30 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:31 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:31 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:32 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:32 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:33 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:33 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:34 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:34 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:35 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:35 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:36 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:36 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:37 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:37 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:38 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:38 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
Tue Feb  1 21:32:39 2022 daemon.info uwsgi-luci: ethtool: bad command line argument(s) For more information run ethtool -h
Tue Feb  1 21:32:39 2022 daemon.info uwsgi-luci: ash: yes: unknown operand
```



#### 分析：

---



打开`WEB管理面板→状态→总览`，`/usr/lib/lua/luci/view/admin_status/index.htm`运行ethinfo出现错误！

```shell
local eth_info = luci.sys.exec("ethinfo")
```

问题出在LEDE源码中`/sbin/ethinfo`文件中`a`变量获取。

```shell
#!/bin/sh

a=$(ip address | grep ^[0-9] | awk -F: '{print $2}' | sed "s/ //g" | grep '^[e]' | grep -v "@" | grep -v "\.")
b=$(echo "$a" | wc -l)
rm -f /tmp/state/ethinfo

echo -n "[" > /tmp/state/ethinfo

for i in $(seq 1 $b)
do
	h=$(echo '{"name":' )
	c=$(echo "$a" | sed -n ${i}p)
	d=$(ethtool $c)

	e=$(echo "$d" | grep "Link detected" | awk -F: '{printf $2}' | sed 's/^[ \t]*//g')
	if [ $e = yes ]; then
		l=1
	else
		l=0
	fi

	f=$(echo "$d" | grep "Speed" | awk -F: '{printf $2}' | sed 's/^[ \t]*//g' | tr -d "Unknown!")
	[ -z "$f" ] && f=" - "

	g=$(echo "$d" | grep "Duplex" | awk -F: '{printf $2}' | sed 's/^[ \t]*//g')
	if [ "$g" == "Full" ]; then
		x=1
	else
		x=0
	fi

	echo -n "$h \"$c\", \"status\": $l, \"speed\": \"$f\", \"duplex\": $x}," >> /tmp/state/ethinfo
done

sed -i 's/.$//' /tmp/state/ethinfo

echo -n "]" >> /tmp/state/ethinfo

cat /tmp/state/ethinfo
```

在kvm虚拟机OpenWrt中可以正常获取网卡信息，并且不会出现ethtool报错，在lxc容器OpenWrt中无法获取网卡信息，并且会造成`d=$(ethtool $c)`运行出错，原本是执行`ethtool eth0`，结果变成执行`ethtool`，即如系统日志出现的错误提醒（ethtool: bad command line argument(s)）一样。

```shell
root@OpenWrt:~# ethtool
ethtool: bad command line argument(s)
For more information run ethtool -h
```

同时查看`/tmp/state/ethinfo`文件（这是`ethinfo`命令运行的结果保存路径）获取的网卡信息如下：

```json
[{"name": "", "status": 0, "speed": " - ", "duplex": 0}]
```



#### 解决：

---



- [x] 修改代码

打开`/sbin/ethinfo`，修改变量`a`的获取代码，如下：

```shell
a=$(ip address | grep ^[0-9] | awk -F: '{print $2}' | sed "s/ //g" | grep '^[e]' | awk -F "@" '{print $1}')
```

保存`/sbin/ethinfo`。



- [x] 查看结果

在ssh命令行运行`ethinfo`命令，然后查看`/tmp/state/ethinfo`文件，网卡信息显示如下：

```json
[{"name": "eth0", "status": 1, "speed": "10000Mb/s", "duplex": 1}]
```

再次打开WEB管理面板，不再出现错误，同时网卡显示正常：

`eth0` `10000Mb/s` `全双工`

系统日志不再报错！
