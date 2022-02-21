nf_conntrack连接跟踪模块



### nf_conntrack跟踪机制

在[iptables](https://so.csdn.net/so/search?q=iptables&spm=1001.2101.3001.7020)里，包是和被跟踪连接的四种不同状态有关的。它们分别是`NEW`，`ESTABLISHED`，`RELATED`和`INVALID`。

使用iptables的`state`模块可以匹配操作这几种状态，我们能很容易地控制“谁或什么能发起新的会话”。

为什么需要这种状态跟踪机制呢？

比如你的80端口开启，而你的程序被植入反弹式木马，导致服务器主动从80端口向外部发起连接请求，这个时候你怎么控制呢。关掉80端口，那么你的网站也无法正常运行了。但有了连接跟踪你就可以设置只允许回复关于80端口的外部请求（ESATBLISHED状态），而无法发起向外部的请求（NEW状态）。所以有了连接跟踪就可以做到在这种层面上的限制，慢慢往下看就明白了各状态的意义。

所有在内核中由`Netfilter`的特定框架做的连接跟踪称作`conntrack`（connection tracking）。conntrack可以作为模块安装，也可以作为内核的一部分。大部分情况下，我们想要也需要更详细的连接跟踪，这是相比于缺省的conntrack而言。也因为此，conntrack中有许多用来处理TCP，UDP或ICMP协议的部件。这些模块从数据包中提取详细的、唯一的信息，因此能保持对每一个数据流的跟踪。这些信息也告知conntrack流当前的状态。例如，UDP流一般由他们的目的地址、源地址、目的端口和源端口唯一确定。

在以前的内核里，我们可以打开或关闭重组功能。然而连接跟踪被引入内核后，这个选项就被取消了。因为没有包的重组，连接跟踪就不能正常工作。现在重组已经整合入conntrack，并且在conntrack启动时自动启动。不要关闭重组功能，除非你要关闭连接跟踪。

除了本地产生的包由`OUTPUT`链处理外，所有连接跟踪都是在`PREROUTING`链里进行处理的，意思就是， iptables会在`PREROUTING`链里从新计算所有的状态。如果我们发送一个流的初始化包，状态就会在`OUTPUT`链里被设置为`NEW`，当我们收到回应的包时，状态就会在`PREROUTING`链里被设置为`ESTABLISHED`。如果第一个包不是本地产生的，那就会在`PREROUTING`链里被设置为`NEW`状态。综上，所有状态的改变和计算都是在`nat`表中的`PREROUTING`链和`OUTPUT`链里完成的。

conntrack默认最大跟踪65536个连接，查看当前系统设置最大连接数

```ruby
[root@server ~]# cat /proc/sys/net/netfilter/nf_conntrack_max
65536
```

查看连接跟踪有多少条目

```ruby
[root@server ~]# cat /proc/sys/net/netfilter/nf_conntrack_count
1
```

当服务器连接多于最大连接数时会出现`kernel: ip_conntrack: table full, dropping packet`的错误。

解决方法，修改conntrack最大跟踪连接数：

```ruby
[root@server ~]# vim /etc/sysctl.conf
[root@server ~]# sysctl -p
net.nf_conntrack_max = 100000
```

查看established连接状态最多保留几天，默认是432000秒，就是5天；如果觉得时间太长可以修改。还有各种tcp连接状态的保留时间，都可以修改的。

```ruby
[root@server ~]# cat /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
432000  
```

### 连接跟踪（conntrack）记录

IP_conntrack模块根据IP地址可以实时追踪本机TCP/UDP/ICMP的连接详细信息并保存在内存中`/proc/net/nf_conntrack`文件中（Centos5中使用的是`/proc/net/ip_conntrack`）。查看这个文件的记录会有如下信息：

```rust
ipv4     2 tcp      6 89  SYN_SENT src=101.81.225.225 dst=112.74.99.130 sport=33952 dport=80 
src=112.74.99.130 dst=101.81.225.225 sport=80 dport=33952 [UNREPLIED] mark=0 secmark=0 use=2
1
2
ipv4     2 tcp      6 89  SYN_SENT src=101.81.225.225 dst=112.74.99.130 sport=33952 dport=80 
src=112.74.99.130 dst=101.81.225.225 sport=80 dport=33952 [UNREPLIED] mark=0 secmark=0 use=2
```

IP_conntrack模块维护的所有信息都包含在这个例子中了，通过它们就可以知道某个特定的连接处于什么状态。

首先显示的是IP类型，然后是协议，这里是tcp，接着是十进制的6（tcp的协议类型代码是6）。之后的89是这条conntrack记录的生存时间（TTL），它会有规律地被消耗，直到收到这个连接的更多的包。那时，这个值就会被设为当时那个状态的缺省值。接下来的是这个连接在当前时间点的状态。上面的例子说明这个包处在状态 SYN_SENT，这个值是iptables显示的，以便我们好理解，而内部用的值稍有不同。SYN_SENT说明我们正在观察的这个连接只在一个方向发送了一TCP SYN包。再下面是源地址、目的地址、源端口和目的端口。最后，是希望接收的应答包的信息，他们的地址和端口和前面是相反的。其中有个特殊的词[UNREPLIED]，说明这个连接还没有收到任何回应。

当一个连接在两个方向上都有传输时，conntrack记录就删除[UNREPLIED]标志，然后重置。在末尾有[ASSURED]的记录说明两个方向已没有流量。

```rust
ipv4     2 tcp      6 431962 ESTABLISHED src=101.81.225.225 dst=112.74.99.130 sport=33952 dport=80 
src=112.74.99.130 dst=101.81.225.225 sport=80 dport=33952 [ASSURED] mark=0 secmark=0 use=2
1
2
ipv4     2 tcp      6 431962 ESTABLISHED src=101.81.225.225 dst=112.74.99.130 sport=33952 dport=80 
src=112.74.99.130 dst=101.81.225.225 sport=80 dport=33952 [ASSURED] mark=0 secmark=0 use=2
```

这样的记录是确定的，在连接跟踪表满时，是不会被删除的，没有[ASSURED]的记录就要被删除。连接跟踪表能容纳多少记录是被一个变量控制的，默认值取决于你的内存大小，128MB可以包含8192条目录，256MB是16376条，在拥有较大内存的机器中默认65536条。对于一个高并发的web服务器来说，如果你的请求数大过`/proc/sys/net/netfilter/nf_conntrack_max`文件中定义的数目，那么就会出现用户连接失败并且报错，报错信息如下：

```sql
nf_conntrack: table full, dropping packet.
1
nf_conntrack: table full, dropping packet.
```

而我们第一时间想到的办法就是关闭防火墙或是增大默认连接数，修改默认最大值，如下:

```ruby
[root@localhost ~]# echo "100000" > /proc/sys/net/netfilter/nf_conntrack_max
1
[root@localhost ~]# echo "100000" > /proc/sys/net/netfilter/nf_conntrack_max
```

### 但不要盲目增大nf_conntrack_max的值！

理解Linux内核内存分配

连接追踪模块属于内核的，所以我们知道`所有的连接跟踪信息都是保存于内存`中的，因此会考虑`单纯放大这个nf_conntrack_max参数会占据多少内存`，会权衡内存的占用，如果系统没有太大的内存，就不会将此值设置的太高。但是如果你的系统有很大的内存呢？比如有8G的内存，分个1G给连接跟踪也不算什么啊，这是合理的，然而在传统的32位架构Linux中是做不到，为什么？首先32位架构中最大寻址能力是4G，而Linux内存管理是虚拟内存的方式，4G内存分给内存的是1G，其他3G是理论上分给单个进程的，每个进程认为自己有3G内存可用，最后是根据每个进程实际使用的内存映射到物理内存中去。

内存越来越便宜的今天，Linux的内存映射方式确实有点过时了。

然而事实就摆在那里，nf_conntrack处于内核空间，它所需的内存必须映射到内核空间，而传统的32位Linux内存映射方式只有1G属于内核，这1G的地址空间中，前896M是和物理内存一一线性映射的，后面的若干空洞之后，有若干vmalloc的空间，这些vmalloc空间和一一映射空间相比，很小很小，算上4G封顶下面的很小的映射空间，一共可以让内核使用的地址空间不超过1G。对于`ip_conntrack来讲，由于其使用slab分配器，因此它还必须使用一一映射的地址空间`，这就是说，它`最多只能使用不到896M的内存`！

为何Linux使用如此“落后”的内存映射机制这么多年还不改进？

其实这种对内核空间内存十分苛刻的设计在64位架构下有了很大的改观，也可以放心根据内存调整最大连接追踪条目了。但问题依然存在，即使64位架构，内核也无法做到透明访问所有的物理内存，它同样需要把物理内存映射到内核地址空间后才能访问，对于一一映射，这种映射是事先确定的，对于大小有限(实际上很小)非一一映射空间，需要动态创建页表，页目录等。所以条目太多就会消耗性能且会产生内存碎片。另外`如果不需要用到连接跟踪功能可以选择在Iptables中关闭，以此来提高系统的网络连接性能（因为开启会产生大量的IO操作）`。卸载ip_conntrack模块如下，必须要先关闭防火墙才能卸载。另外注意当你试图`查看iptables规则之后，就会激活ip_conntrack模块`，无法真正卸载掉哦。

```ruby
$ service iptables stop
$ modprobe -r nf_conntrack
1
2
$ service iptables stop
$ modprobe -r nf_conntrack
```

### 查看实时连接信息

查看实时连接状态信息

```shell
sysctl net.netfilter.nf_conntrack_count
```

执行命令

```shell
root@OpenWrt:/proc/9276/net# sysctl net.netfilter.nf_conntrack_count
net.netfilter.nf_conntrack_count = 2250
root@OpenWrt:/proc/9276/net# sysctl net.netfilter.nf_conntrack_count
net.netfilter.nf_conntrack_count = 2250
root@OpenWrt:/proc/9276/net# sysctl net.netfilter.nf_conntrack_count
net.netfilter.nf_conntrack_count = 594
```



### 相关的内核参数

```shell
[root@server ~]# sysctl -a | grep conntrack
net.netfilter.nf_conntrack_acct = 0
net.netfilter.nf_conntrack_buckets = 16384
net.netfilter.nf_conntrack_checksum = 1
net.netfilter.nf_conntrack_count = 1
net.netfilter.nf_conntrack_events = 1
net.netfilter.nf_conntrack_events_retry_timeout = 15
net.netfilter.nf_conntrack_expect_max = 256
net.netfilter.nf_conntrack_generic_timeout = 600
net.netfilter.nf_conntrack_helper = 1
net.netfilter.nf_conntrack_icmp_timeout = 30
net.netfilter.nf_conntrack_log_invalid = 0
net.netfilter.nf_conntrack_max = 65536
net.netfilter.nf_conntrack_tcp_be_liberal = 0
net.netfilter.nf_conntrack_tcp_loose = 1
net.netfilter.nf_conntrack_tcp_max_retrans = 3
net.netfilter.nf_conntrack_tcp_timeout_close = 10
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_established = 432000
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 30
net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 300
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 60
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 300
net.netfilter.nf_conntrack_timestamp = 0
net.netfilter.nf_conntrack_udp_timeout = 30
net.netfilter.nf_conntrack_udp_timeout_stream = 180
net.nf_conntrack_max = 65536
```

也可以使用 dmesg 查看。

```shell
[root@server ~]# dmesg | tail -f
[    3.656918] ppdev: user-space parallel port driver
[    3.680022] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    3.772029] alg: No test for crc32 (crc32-pclmul)
[    3.785294] intel_rapl: no valid rapl domains found in package 0
[    7.120138] EXT4-fs (vda1): resizing filesystem from 786176 to 5242304 blocks
[    7.422160] EXT4-fs (vda1): resized filesystem to 5242304
[ 1994.617368] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[ 3657.011241] nr_pdflush_threads exported in /proc is scheduled for removal
[ 4538.293958] Netfilter messages via NETLINK v0.30.
[ 4538.300128] ctnetlink v0.93: registering with nfnetlink.
```
