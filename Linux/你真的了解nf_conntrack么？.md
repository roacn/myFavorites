你真的了解nf_conntrack么？



### 背景描述

最近在日常运维云平台的过程中，遇到了nf_conntrack table full，然后开始drop packet的问题。当然这个问题属于老问题了，在网上一搜资料也能搜到一大堆，但是真正深入研究的文章没多少，浅尝则止的居多。所以今天针对这个现场，我们深入分析一下这个模块的一些技术细节，让大家对这个问题的产生原因和背后细节能有更好的了解。

首先看看我们的问题现场，看看log

```shell
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
Dec 14 15:00:05 w-openstack08 kernel: nf_conntrack: table full, dropping packet
```

我们的问题是出现在ansible更新M版本openstack的时候触发的问题，但是该问题的产生从这个问题的日志上看，与ansible中的一些具体步骤没啥关系，但是有个共同的关系应该是ansible的一些高并发的连接触发了nf_conntrack的保护性机制，table满了以后，开始主动drop packet。

所以这里就需要先了解一下nf_conntrack，该内核模块主要是干嘛的。



### 实际场景

`nf_conntrack`从名字上看是`connection tracking`，是内核模块中的连接追踪模块。与iptables有关。计算节点上的iptables的规则，是因为我们的neutron网络中使用了安全组，当前我们的计算节点上用了`iptables filter表`做包的最后一步过滤。

在iptables filter过滤packet的时候用了状态跟踪机制，我们使用 -state参数指定了两种userspace的状态，`ESTABLISHED`，`RELATED`，当使用状态跟踪机制的时候，我们就需要nf_conntrack模块来对每个连接进行tracking。

具体计算节点规则如下，我们的规则中针对ESTABLISHED 和RELATED的连接做了放行，那些不知道属于哪个连接的和没有任何状态的连接，一律drop掉。

```shell
[root@w-openstack53 /home]# iptables -S|grep state
-A neutron-openvswi-i6db946b2-1 -m state --state RELATED,ESTABLISHED -m comment --comment "Direct packets associated with a known session to the RETURN chain." -j RETURN
-A neutron-openvswi-i6db946b2-1 -m state --state INVALID -m comment --comment "Drop packets that appear related to an existing connection (e.g. TCP ACK/FIN) but do not have an entry in conntrack." -j DROP
```

所以这里我们的nf_conntrack模块会对宿主机上所有经过该iptables的连接都进行跟踪。这里就需要知道具体跟踪是咋跟踪的，会记录连接的那些信息，最后会将这些信息怎么存储，又怎么查询怎么信息。

这里我们可以先看看conntrack的跟踪信息记录，我们可以在`/proc/net/nf_conntrack`中看到已经被跟踪的连接，如下：

```shell
[root@w-openstack53 /home]# head /proc/net/nf_conntrack
ipv4 2 tcp 6 115 TIME_WAIT src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=54585 dport=9000 src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=9000 dport=54585 [ASSURED] mark=0 zone=3 use=2
ipv4 2 tcp 6 100 TIME_WAIT src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=40460 dport=9000 src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=9000 dport=40460 [ASSURED] mark=0 zone=3 use=2
ipv4 2 tcp 6 431999 ESTABLISHED src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=42482 dport=80 src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=80 dport=42482 [ASSURED] mark=0 zone=3 use=2
ipv4 2 tcp 6 85 TIME_WAIT
```

这里我们看看其中的一条ESTABLISHED状态的trace记录。

```shell
tcp 6 431999 ESTABLISHED src=xx.xx.xx.xx dst=1xx.xx.xx.xx sport=42482 dport=80 src=xx.xx.xx.xx dst=xx.xx.xx.xx sport=80 dport=42482 [ASSURED] mark=0 zone=3 use=2
```

tcp是跟踪的协议类型，6很明显是tcp的协议代码，这里conntrack可以跟踪tcp/udp/icmp等各种协议类型。这里431999 就是该连接的生命时间了，默认值是5天。在收到新包之前该值会逐渐变小，如果收到新包，该值会被重置一下，然后又开始重新计时。

接下来就是四元组了，接下来是反向连接的四元组，最后的ASSURED就是该状态已经确认。



### 场景分析

其实整体宿主机中conntrack跟踪的连接基本状态都已经是time_wait，因为上面的vm提供的都是web短连接服务，server端主动断开连接成功就会有个2MLS的time_wait，这些连接也都被track，该conntrack也会占用2分钟的时间。

这都不用并发太高的环境，比如我们的vm web每秒并发个100，2MLS的时间2分钟得生成2 * 60 * 100=12000，基本上这一秒的并发会生成1万多的time_wait，conntrack记录。再按每条并发连接持续的时间长短，大概预估一下。

每天产生的time_wait状态的conntrack数是，就按个比较活跃的业务来说，一天也能产生大概5万多的conntrack记录。

我们可以通过查看nf_conntrack_count看看当前，在bjcc的53节点上nf_conntrack跟踪了多少连接，如下：

```
[root@w-openstack53 /home]# sysctl net.netfilter.nf_conntrack_count
net.netfilter.nf_conntrack_count = 215168
```

差不多21万的conntrack记录。基本上97%的都是处于server主动断开并且处于time_wait状态的连接，3%是正在建立的establishted状态的连接。

```shell
[root@w-openstack53 /home]# ss -s
Total: 363 (kernel 1225)
TCP: 34 (estab 24, closed 3, orphaned 0, synrecv 0, timewait 1/0), ports 0
Transport Total IP IPv6
\* 1225 - -
RAW 0 0 0
UDP 2 2 0
TCP 31 31 0
INET 33 33 0
FRAG 0 0 0
```

这里就是个短连接不断积累的过程，不断地server主动断开，不断地timewait，这些都会被conntrack跟踪记录。所以一般默认的`nf_conntrack_max=65535`，很快就被塞满了。一旦塞满了就会随机的drop包。在外面看来就是丢包情况非常厉害。



### 原理剖析

前面都是说的nf_conntrack怎么记录我们的connection。慢慢就轮到了nf_conntrack怎么存储这些track记录。

nf_conntrack对connection的track最后都会扔到一个hashtable里面，这里就涉及到一个查询时间与存储空间的效率问题了。

我们肯定都希望将这些entry每一条都塞到一个哈希桶里，每个桶都只有一个link node，该node只存储一个connection entry。这样每次查询connection entry就是完美的O(1)的效率，多美好。

但是这样的存储空间要爆表了。

好吧，到这里先不说成本的问题，先说说如果真有这么多connection track连接，我们这个hashtable究竟要咋放这么多entry。

这里我们的都知道我们的entry最后会先经过hash，扔到我们的一定数量的hash桶里面。如果桶数量不等于entry数量的话，那一个桶里还得多放几个entry。

这里官方的hashtable处理冲突用的是链地址法，该冲突处理方法也是比较常用的地址冲突处理方法。桶里放得是头指针，然后相同key的node用单链表连起来。

这里hash桶的查找效率肯定是O(1)的，在hash桶里面是常用的link node list单链表。单链表的查询效率肯定是O(n)的，所以我们都希望每个entry放在一个桶里，我们希望最快的查询速度。

但是每个entry都放到桶里，内存消耗是非常大的。

因为看官方对conntrack entry的优化说明，每一条entry会占用大概300字节的空间。我们这里如果上来就分配一个超级大的hashtable，并且`nf_conntrack_buckets == nf_conntrack_max` 。

比如我们设置`nf_conntrack_max = nf_conntrack_max = 12262144`，该参数的意思就是我们的hashtable非常大，并且每个桶只放一条entry，可以放12262144条connection entry。

这样我们会需要12262144308字节= 12262144308/(1024 * 1024) = 3508.22753906MB ，大约3个G的内存。。当然有余数是因为这个max值没有设置成2的幂次方。

我们总共就64的内存，光给一个connection track，并且track到的连接都是些没有实际意义的已经被释放掉的time_wait的连接。所以这样配置成本是有点高的。当然我们的服务器上不是这样的。

所以我们一般都选择hashtable + linknode list的方案。这样能在存储空间和查询效率之间取个平衡。

因为桶是直接内存占用，这里的内存分配是按nf_conntrack的struck结构体来分配的，可以稍微去看看源码中这个结构体就能看到有多庞大了。大约300字节。

每个桶里放的是该单链表的头指针，指针要的内存空间要比nf_conntrack结构体要的明显小太多了，一般这个与cpu架构和编译环境都有关系，这里一般就按8字节算了。这样会省很多存储空间

比如官方一般都推荐一个桶里放4条entry。所以官方的默认参数里面，你一般会看到`nf_conntrack_max = nf_conntrack_buckets * 4`，四倍的关系

如果nf_conntrack_max 远远大于nf_conntrack_buckets ，就意味着每个桶里面会放非常长的单链表。。这样查询速率肯定是会有比较大影响的。

比如我们现在的服务器配置：

```
[root@w-openstack53 /home]# sysctl -a|grep nf_conntrack_max
net.netfilter.nf_conntrack_max = 12262144
[root@w-openstack53 /home]# sysctl -a|grep nf_conntrack_buckets
net.netfilter.nf_conntrack_buckets = 16384
```

我们创建了一个hashtable，该table设置了16384个桶。那就是每个桶里面可以存放 12262144/16384 = 748.421875，大约可以放750条entry。这样我们的entry查询延迟就比官方的大了200多倍。

其实这里我们对线上的修改都只是更改了nf_conntrack_max ，把这个值设置成12262144，但是没有改过nf_conntrack_buckets ，这个值足够大，足以满足我们的目前的connection entry日常产生记录。

因为我们的线上一般就是30万左右connection entry数。但是这不是个兼顾空间与时间的最优配置。

在`官方建议中一般大于4GB的内存空间，默认nf_conntrack_buckets = 65536`，如下。现在centos7.2版本中已经改成这个参数了。

`nf_conntrack_max 默认四倍的关系。一个桶里放四个entry`。兼顾时间和存储空间

```
[root@w-openstack175 /home]# sysctl -a|grep nf_conntrack_buckets
net.netfilter.nf_conntrack_buckets = 65536
[root@w-openstack175 /home]# sysctl -a|grep nf_conntrack_max
net.netfilter.nf_conntrack_max = 262144
```

但是在centos7.1中还是默认的1GB的内存空间配置。`默认nf_conntrack_buckets = 16384，默认的nf_conntrack_max 4倍关系 65536`，这个max值肯定是满足不了我们当前的业务记录的。所以得调大点。

还有一个影响conntrack积累记录的参数就是`nf_conntrack_tcp_timeout_established` ，该参数会跟踪一个记录5days，这太长了。当然这是官方推荐的时间。

调到一天等，但是我们的connection tracking记录中只有3%的是established状态的连接，所以该参数对降低线上table full丢包问题没啥太大影响。

`nf_conntrack_tcp_timeout_established = 432000`

### 总结

所以最后针对该内核模块的使用，有很多种方法。

- [x] **拥抱高版本ovs**

就是不用该模块了。这样的场景是在以后，比如说M版本支持ovs2.6，高版本ovs本身就支持在ovs层面做安全限制，不需要在用qbr这种蹩脚的设计了，这样宿主机就不用启用iptables，自然就不用connection track了。更不会有现在这个问题了。

- [x] **修改iptables规则**

继续用这个模块，但是我们直接在neutron 代码中改一下，针对这些状态机制的iptables规则做一个动作， -j notrack，这样的好处是治本，把不需要track的iptables直接notrack，那自然就不会去占hashtable空间了，更不会报错了。

- [x] **优化核心参数**

继续用这个模块。但是我们要对参数进行一下调优。参数得设置的更合理一些。

nf_conntrack_buckets 和nf_conntrack_max 的平衡关系就不说了，具体我们的max应该设置成多少呢？

这个与宿主机内存有关系，并且官方有个计算公式，

$$
CONNTRACK_MAX=RAMSIZE(in bytes)/16384/(x/32)
$$
这里我们的宿主机内存一般都是64GB，所以CONNTRACK_MAX = 64 * 1024 * 64 = 4194304，最大支持400多万；然后桶的数量就是四倍的关系4194304/4 = 1048576

`nf_conntrack_max = 4194304`

`nf_conntrack_buckets = 1048576`

这样就ok了。已经远远大于我们现在业务conn track 记录数量了。

这样的配置，用在我们的业务环境中。比如53上

`net.netfilter.nf_conntrack_count = 218570`

如果换这个参数的话。

我们有100万个桶，20万左右的entry放进去足以，每个桶就一个entry，查询效率o(1)，非常高。

同时效率高了，我们继续算算内存占用。前面已经说了nf_conntrack struck本身初始化就得占用300左右字节，我们的link node指针也就是占用个8个字节而已。

所以我们算算 内存占用 = 4194304 * 300 + 1048576 * 8 = 1266679808字节 = 1208M。一个G而已

对应我们64GB的空间占用这点内存，换个o(1)的iptables查询效率还是可以的。

看看当前可用mem还有8个G，还是可以接受的

```
[root@w-openstack53 /home]# free -m
total   used   free   shared   buff/cache  available
Mem:   64237  50988     8308    1284/4940      10751
Swap:  32255    803    31452
```

当前服务器上的配置前面我们已经算过了，内存占用 = 12262144 *300 + 16384 *8 = 3508.35253906M 大约3个G。

至于效率前面更已经算过了。`时间等于 = o(n) + o(1) = o(n)`，这里的n = 12262144/16384 = 748.421875，而我们上面的配置中时间是o(1)的，现在的配置是我们优化后的配置的耗时700倍。

但是cpu真是太快了，700倍在cpu那里都不是个事。但是明显该优化后的参数再时间和存储空间两个维度都是优于线上的。

但是优化后的配置有个不足就是，同时支持track的连接数是400万。线上是1200万。意思就是如果我们的宿主机上track的connection到了无可救药的400万以上了。那就会触发丢包。

但是当前观察所有的业务下的conntrack数目都只是30万左右。并且track的都是一些time_wait状态的connection，如下面的shm08，无效的connection track比例达到了97%。。

```
[root@w-openstack08 /home]# cat /proc/net/nf_conntrack|grep ESTABLISHED|wc -l
5125
[root@w-openstack08 /home]# cat /proc/net/nf_conntrack|grep TIME_WAIT|wc -l
136767
```

所以到这里有两个选择，就是在tcp层面去消除time_wait太多的问题。这就选择范围太多了。主流的还是tcp_tw_recycle内核参数的使用等等。这里就不展开了。

第二个就是在改一下`nf_conntrack_tcp_timeout_time_wait = 120`，改的小点。大家都知道time_wait其实就是为了让包收收尾，以前的网络太烂，包的路由和传输都很慢。预留2分钟是为了让这些释放连接的包能在2分钟内顺利到达。现在网络环境这么好。我们connection track没必要跟踪这么长时间。设置成60s，我们的connection track数量立马就能降一半。

整体来说我们的max设置成400万，桶的数量100万，是在64G内存服务器上最优的解决方案，兼顾内存占用和查询效率。其他的timeout参数，我们iptables没必要对time_wait状态的连接tracking 2分钟之久。1分钟就行。establishted状态我们tracking 5天可以接受。

所以最后推荐配置如下：

```
nf_conntrack_max = 4194304
nf_conntrack_buckets = 1048576
nf_conntrack_tcp_timeout_time_wait = 60
```

