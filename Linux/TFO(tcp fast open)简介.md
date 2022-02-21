## TFO(tcp fast open)简介



一直以来对内核没有太多研究，最近国外业务扩展较快，国外没有节点。所以国外用户访问国内服务器时，延时比较大。为了解决这个问题，在香港上了一个proxy，通过proxy回国内节点获取数据，最后返回客户端。为提高回源性能，有人提出TFO解决方案，以前没有听说过。所以来学习一下。



#### TFO(tcp fast open)简介

---

为了改善web应用相应时延方面的一个工作，google通过修改TCP协议利用三次握手时进行数据交换的TFO。和TCP相比TFO在3次握手期间也会传输数据。TFO是GOOGLE发布的。目前chrome已经支持TFO，但默认是关闭的，因为它有一些特定的使用场景。



TFO：

1.首先HTTP请求需要TCP三次握手，尽管开启keepalive(长连接)，可以依然有35%的请求是重新发起一条连接。而三次握手会造成一个RTT(Round Trip Time)的延时，因此TFO的目标就是去除这个延时，在三次握手期间也能交换数据。RTT在比较低时，客户端页面加载时间优化大约在4%~5%；RTT越长，好处越大，平均大约在25%。

除了页面加载变快改善了用户体验之外，TFO给服务器也带来了一些好处。由于每个请求都节省了一个RRT，相应地也减少了服务器端Cpu消耗。经过测试TFO每秒食物数有2876.5提升到3548.7



![TFO](https://raw.githubusercontent.com/roacn/myFavorites/main/img/TFO%E7%AE%80%E4%BB%8B.jpg)

#### TFO工作原理

---

> 客户端发送SYN包，包尾加一个FOC请求，只有4个字节。

> 服务端受到FOC请求，验证后根据来源ip地址声称cookie(8个字节)，将这个COOKIE加载SYN+ACK包的末尾发送回去。

> 客户端缓存住获取到的Cookie 可以给下一次使用。

> 下一次请求开始，客户端发送SYN包，这时候后面带上缓存的COOKIE，然后就是正式发送的数据。

> 服务器端验证COOKIE正确，将数据交给上层应用处理得到相应结果，然后在发送SYN+ACK时，不再等待客户端的ACK确认，即开始发送相应数据。

-----------------------------------
在使用TFO之前，client首先需要通过一个普通的三次握手连接获取FOC(Fast Open Cookie)

- client发送一个带有Fast Open选项的SYN包，同时携带一个空的cookie域来请求一个cookie
- server产生一个cookie，然后通过SYN-ACK包的Fast Open选项来返回给client
- client缓存这个cookie以备将来使用TFO连接的时候使用

执行TFO

- client发送一个带有数据的SYN包，同时在Fast Open选项中携带之前通过正常连接获取的cookie
- server验证这个cookie。如果这个cookie是有效的，server会返回SYN-ACK报文，然后这个server把接收到的数据传递给应用层。如果这个cookie是无效的，server会丢掉SYN包中的数据，同时返回一个SYN-ACK包来确认SYN包中的系列号
- 如果cookie有效，在连接完成之前server可以给client发送响应数据，携带的数据量受到TCP拥塞控制的限制(RFC5681，后面文章会介绍拥塞控制)。
- client发送ACK包来确认server的SYN和数据，如果client端SYN包中的数据没有被服务器确认，client会在这个ACK包中重传对应的数据
- 剩下的连接处理就类似正常的TCP连接了，client一旦获取到FOC，可以重复Fast Open直到cookie过期。



![TFO](https://raw.githubusercontent.com/roacn/myFavorites/main/img/TFO%E5%B7%A5%E4%BD%9C%E5%8E%9F%E7%90%86.jpg)



#### 延时分析

假设单程延时为 t，如果没有用 TFO，那么需要三次握手后才会开始发送数据，即发送数据延时至少为 2t，而用了 TFO，发送数据延时就是0。当然从用户体验来看，从发起请求到接收到服务端发送过来数据的延时分别是4t和2t。



#### TFO 的一些问题

由于带了 cookie 有些防火墙认为数据包异常，在这种环境下用起来就会有问题。有报告说某些4G网络就有这种问题。



#### TFO的客户端支持情况

Linux 3.7 以后的内核，可以手动开启。3.13以后的内核默认开启（默认为1）。
Windows10 默认开启1607+（自动更新打开的情况下）
windows默认的Edge浏览器14352以后的版本。
Chrome浏览器在Linux、 Android上的版本。在windows上版本不支持。
Firefox浏览器默认关闭，可以手动开启。
Apple的 iOS 9 和 OS X 10.11 可以支持，但可能默认未启用。
linux下的curl 7.49以后的版本支持。



#### 环境搭建

---

![image-20220202220755952](https://raw.githubusercontent.com/roacn/myFavorites/main/img/TFO%E6%90%AD%E5%BB%BA.jpg)



#### 测试结果

---

![image-20220202220755952](https://raw.githubusercontent.com/roacn/myFavorites/main/img/%E6%B5%8B%E8%AF%95%E7%BB%93%E6%9E%9C.jpg)



#### TFO开启方法



命令方式（临时性）：

```
sysctl -w net.ipv4.tcp_fastopen = 3
其中1表示启用客户端（sendto)，2表示启用服务端（bind），3表示两者都启用。
```

以上，重启失效。



文件方式（永久性）：

```
Linux开启TFO选项
vi /etc/sysctl.conf
加入
net.ipv4.tcp_fastopen = 3
修改后使用 sysctl -p 命令重加载内核参数文件sysctl.conf
```

以上，重启有效。



#### 注释

> Round Trip Time
> 往返时延。在计算机网络中它是一个重要的性能指标，表示从发送端发送数据开始，到发送端收到来自接收端的确认（接收端收到数据后便立即发送确认），总共经历的时延。



https://lwn.net/Articles/508865/

