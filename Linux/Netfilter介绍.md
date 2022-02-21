**Netfilter介绍**

  linux内核中的netfilter是一款强大的基于状态的防火墙，具有连接跟踪（conntrack）的实现。conntrack是netfilter的核心，许多增强的功能，例如，地址转换（NAT），基于内容的业务识别（l7， layer-7 module）都是基于连接跟踪。

  nf_conntrack模块在kernel 2.6.15（2006-01-03发布） 被引入，支持ipv4和ipv6，取代只支持ipv4的ip_connktrack，用于跟踪连接的状态，供其他模块使用。



**主要参数介绍**

```shell
# 哈希表大小（只读）（64位系统、8G内存默认 65536，16G翻倍，如此类推）
net.netfilter.nf_conntrack_buckets
# 最大跟踪连接数，默认 nf_conntrack_buckets * 4
net.netfilter.nf_conntrack_max
net.nf_conntrack_max
```

> 注：跟踪的连接用哈希表存储，每个桶（bucket）里都是1个链表，默认长度为4KB
>
> 注：netfilter的哈希表存储在内核空间，这部分内存不能swap
>
> 注：哈希表大小 64位 最大连接数/8 32 最大连接数/4
>
> 注：32位系统一条跟踪几率约为300字节。
>
> 注：在64位下，当CONNTRACK_MAX为 1048576，HASHSIZE 为 262144 时，最多占350多MB



**状态查看**



1、查找：buckets哈希表大小，max最大几率的连接条数

```shell
# netfilter模块加载时的bucket和max配置:
sudo dmesg | grep conntrack
```

结果

```
[6010550.921211] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
```



2、查找：哈希表使用情况

```shell
# 前4个数字分别为：当前活动对象数、可用对象总数、每个对象的大小（字节）、包含至少1个活动对象的分页数
grep conntrack /proc/slabinfo
```

结果

```
nf_conntrack_ffffffff81ad9d40    865    918    320   51    4 : tunables    0    0    0 : slabdata     18     18      0
```



３、查找：当前跟踪的连接数

```shell
sudo sysctl net.netfilter.nf_conntrack_count
cat /proc/net/nf_conntrack | wc -l
```



４、跟踪连接详细信息

```shell
cat /proc/net/nf_conntrack
```

结果说明

```shell
ipv4     2 tcp      6 2 CLOSE src=100.116.203.128 dst=172.16.105.212 sport=62226 dport=8080 src=172.16.105.212 dst=100.116.203.128 sport=8080 dport=62226 [ASSURED] mark=0 zone=0 use=2
```



> 记录格式
>
> 网络层协议名、网络层协议编号、传输层协议名、传输层协议编号、记录失效前剩余秒数、连接状态（不是所有协议都有）
>
> 之后都是key=value或flag格式，1行里最多2个同名key（如 src 和 dst），第1次出现的来自请求，第2次出现的来自响应



**连接跟踪调优**



nf_conntrack_max计算公式

```shell
CONNTRACK_MAX（最大几率的连接条数） = 内存容量（GB）*1024 * 1024 * 1024 / 16384 /  (x / 32) 这里x是指针的bit数，（例如，32或者64bit） = ***
示例，16G的64位操作系统计算方法：
CONNTRACK_MAX =16*1024*1024*1024/16384/（64/32）= 524288
```

nf_conntrack_buckets计算公式

```
conntrack_buckets = CONNTRACK_MAX / 4 = ***（Byte字节）
```

运行状态中通过 sysctl net.netfilter.nf_conntrack_buckets 进行查看，通过文件 /sys/module/nf_conntrack/parameters/hashsize 进行设置。

`哈希表大小通常为总表的1/8，最大为1/2，CONNTRACK_MAX / 8 ~CONNTRACK_MAX / 2`

示例，16G的64位操作系统计算方法：524288 /8 ~ 524288 /2 =  65536 ~ 262144

> 注：如果不能关掉防火墙，基本思路就是，调大nf_conntrack_buckets和nf_conntrack_max，调小超时时间。
> 注：除了有关联的参数，尽量一次只改一处，记下默认值，效果不明显或更差就还原。



1、哈希表桶大小 调优

> 注：net.netfilter.nf_conntrack_buckets 不能直接改（报错）

```shell
# 临时生效
echo 262144 > /sys/module/nf_conntrack/parameters/hashsize

------------------------------------------------------

# 重启永久生效
新建文件：/etc/modprobe.d/iptables.conf
options nf_conntrack hashsize = 262144 
```



2、最大追踪连接数修改 调优

```shell
# 临时生效
sudo sysctl -w net.netfilter.nf_conntrack_max=1048576
suod sysctl -w net.nf_conntrack_max=1048576

------------------------------------------------------

# 永久生效
# 添加修改内核配置文件（/etc/sysctl.conf） 
net.netfilter.nf_conntrack_max=1048576
net.nf_conntrack_max=1048576
# 如果要马上应用配置文件里的设置：
sudo sysctl -p /etc/sysctl.conf
```



3、响应时间 调优

```shell
# 临时生效
# 主动方的最后1个状态。默认120秒
sudo sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
sudo sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
# CLOSE_WAIT是被动方收到FIN发ACK，然后会转到LAST_ACK发FIN，除非程序写得有问题，正常来说这状态持续时间很短。#默认 60 秒
sudo sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=15
# 理论上不用这么长，不小于 net.ipv4.tcp_keepalive_time 就行了。默认 432000 秒（5天）
sudo sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=300

-----------------------------------------------------

# 永久生效
# 修改内核配置文件（/etc/sysctl.conf） 
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.netfilter.nf_conntrack_tcp_timeout_close_wait=15
net.netfilter.nf_conntrack_tcp_timeout_established=300
# 如果要马上应用配置文件里的设置：
sudo sysctl -p /etc/sysctl.conf
```



**禁用连接跟踪模块**

> 注：只要iptables还有规则用到nat和state模块，就不适合关掉netfilter，否则这些规则会失效。

```
# 条件举例
# 关掉netfilter会拿不到状态，导致每个请求都要从头到尾检查一次，影响性能：
# 例如这条默认规则（通常写在第1条或很靠前的位置）：
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```



**禁用步骤**

1、整理确认关闭该模块后不会影响功能

```shell
# 1
# 查找相关模块
sudo lsmod | egrep "ip_table|iptable|nat|conntrack"

# 2
# 把带 -t nat 、-m state 的规则都干掉
# 或删掉 /etc/sysconfig/iptables 里相应内容
# 查看iptables规则
sudo iptables-save

# 3
# 编辑 iptables 配置文件
# 找到 IPTABLES_MODULES ，删掉跟conntrack有关的模块（如果有）
sudo vim /etc/sysconfig/iptables-config

# 4
# 停掉iptables
# Centos 6
sudo service iptables stop
# Centos 7
sudo systemctl stop iptables
```



2、移除相关模块

```shell
sudo rmmod iptable_nat
sudo rmmod ip6table_nat
sudo rmmod nf_defrag_ipv4
sudo rmmod nf_defrag_ipv6
# 移除相关模块
sudo rmmod nf_nat
sudo rmmod nf_nat_ipv4
sudo rmmod nf_nat_ipv6
sudo rmmod nf_conntrack
sudo rmmod nf_conntrack_ipv4
sudo rmmod nf_conntrack_ipv6
sudo rmmod xt_conntrack

--------------------------

# 开启相关模块 
sudo modprobe iptable_nat
sudo modprobe ip6table_nat
sudo modprobe nf_defrag_ipv4
sudo modprobe nf_defrag_ipv6
sudo modprobe nf_nat
sudo modprobe nf_nat_ipv4
sudo modprobe nf_nat_ipv6
sudo modprobe nf_conntrack
sudo modprobe nf_conntrack_ipv4
sudo modprobe nf_conntrack_ipv6
sudo modprobe xt_conntrack
```
