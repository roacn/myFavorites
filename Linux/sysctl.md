# sysctl



## sysctl简介

sysctl命令被用于在内核运行时动态地修改内核的运行参数，可用的内核参数在目录`/proc/sys/`中。它包含一些TCP/ip堆栈和虚拟内存系统的高级选项， 这可以让有经验的管理员提高引人注目的系统性能。用sysctl可以读取设置超过五百个系统变量。



## 基础命令

```bash
# 查看内核参数
sysctl -a
# 从配置文件/etc/sysctl.conf加载内核参数设置
sysctl -p
# 设置一个参数
sysctl -w kernel.sysrq=0
```



## [net.ipv4.ip_forward](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.kernel.org%2Fdoc%2FDocumentation%2Fnetworking%2Fip-sysctl.txt)

端口转发

> 参数为/porc/sys/后面的目录，以.分割

```bash
cat /proc/sys/net/ipv4/ip_forward
net.ipv4.ip_forward = 0
```



## net.ipv4.ip_local_port_range

每个ip的可以分配的端口范围，默认32768-60999

```bash
$ ss -ant |grep 10.0.2.15:61
ESTAB   0        0                10.0.2.15:61001       123.125.114.144:443  # 本机:61001
ESTAB   0        0                10.0.2.15:61001       123.125.114.144:80
```



```bash
$ vi /etc/sysctl.conf
net.ipv4.ip_local_port_range = 8192 60999
$ sysctl -w net.ipv4.ip_local_port_range='8192 60999'
```



## ip_conntrack_max

允许的最大跟踪连接条目，默认值是 2^16=65536

ip_conntrack链接满导致无法建立链接，导致网络丢包。因为iptables防火墙使用了ip_conntrack内核模块实现连接跟踪功能，所有的进出数据包都会记录在连接跟踪表中，包括tcp，udp，icmp等，一旦连接跟踪表被填满以后，就会发生丢包，导致网络不稳定。

```bash
kernel: ip_conntrack: table full, dropping packet.
kernel: printk: 1 messages suppressed.
```

```bash
$ cat /proc/net/nf_conntrack | wc -l
$ vi /etc/sysctl.conf
net.ipv4.netfilter.ip_conntrack_max = 4194304
#降低 ip_conntrack timeout时间
net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 300
net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait = 120
net.ipv4.netfilter.ip_conntrack_tcp_timeout_close_wait = 60
net.ipv4.netfilter.ip_conntrack_tcp_timeout_fin_wait = 120
```



## gc_threshX

```bash
net.ipv4.neigh.default.gc_thresh1 = 2048  # 最小gc数量
net.ipv4.neigh.default.gc_thresh2 = 8192  # gc阈值，超过5s会被清除
net.ipv4.neigh.default.gc_thresh3 = 16384 # 最大gc数量
```



## icmp_echo_ignore_all

示例：禁ping

```ruby
$ vi /etc/sysctl.conf
# Disable ping requests
net.ipv4.icmp_echo_ignore_all = 1

# 编辑完成后，请执行以下命令使变动立即生效：
$ /sbin/sysctl -p
$ /sbin/sysctl -w net.ipv4.route.flush=1
```