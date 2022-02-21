### PVE修改网络接口名称

---

打开`/etc/network/interfaces`，个人的`enp3s0`在PVE中默认是`en0l`，直接将其修改为`enp3s0`

```shell
auto lo
iface lo inet loopback

auto enp1s0
iface enp1s0 inet manual
	mtu 1492

auto enp2s0
iface enp2s0 inet manual
	mtu 1492

auto enp3s0
iface enp3s0 inet manual
	mtu 1492

auto enp4s0
iface enp4s0 inet manual
	mtu 1492

auto vmbr0
iface vmbr0 inet static
	address 192.168.1.3/24
	gateway 192.168.1.1
	bridge-ports enp1s0
	bridge-stp off
	bridge-fd 0
	mtu 1492

auto vmbr1
iface vmbr1 inet manual
	bridge-ports enp2s0
	bridge-stp off
	bridge-fd 0
	mtu 1492
```

然后重启网络

```shell
service networking restart
```

