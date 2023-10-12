## UCI命令系统



UCI是集中式配置信息管理接口(`Unified Configuration Interface`)的缩写，他是OpenWrt引进的一套配置参数管理系统。UCI管理了OpenWrt下最主要的系统配置参数并且提供了简单、容易、标准化的人机交互接口。UCI中已经包含了网络配置、无线配置、系统信息配置等作为基本路由器所需的主要配置参数。同时UCI也可以帮助开发人员快速的建立一套基于OpenWrt的智能路由产品控制界面。


### 一、UCI的文件和流程

UCI的配置文件全部存储在/etc/config目录下。

```
root@OpenWrt:~# ls /etc/config
dhcp         dropbear         firewall         network          samba4           system
```

日前已有大量软件包支持UCI模式管理，但不是所有的软件包，支持的软件包是这样来完成启动的(以samba举例):

- [x] 启动脚本/etc/init.d/samba4
- [x] 启动脚本通过UCI分析库从/etc/config/samba4获得启动参数
- [x] 启动脚本完成正常启动

由于UCI的数据文件较为简单，并且具备了很nice的直接观感，所以配置文件既可以使用UCI命令进行修改，也可以使用VI编辑器直接修改文件。但如果两种方式都是用时需要注意UCI命令修改会产生缓存，每次修改好要尽快确认保存避免出现冲突。

最常见的几个UCI配置作用说明

| 文件                 | 作用                              |
| -------------------- | --------------------------------- |
| /etc/config/dhcp     | 面向LAN口提供的IP地址分配服务配置 |
| /etc/config/dropbear | SSH服务配置                       |
| /etc/config/firewall | 路由转发，端口转发，防火墙规则    |
| /etc/config/network  | 网络接口配置                      |
| /etc/config/system   | 时间服务器时区配置                |
| /etc/config/wireless | 无线网络配置                      |



### 二、UCI的文件语法

```
config 'section-type' 'section'
        option        'key'           'value'
        list          'list_key'      'list_value'
config 'example'      'test'
        option        'string'        'some value'
        option        'boolean'       '1'
        list          'collection'    'first item'
        list          'collection'    'second item'
```

config 节点以关键字 config 开始的一行用来代表当前节点
            section-type 节点类型
            section 节点名称
option 选项 表示节点中的一个元素
            key 键
            value 值
list 列表选项 表示列表形式的一组参数。
           list_key 列表键
           list_value 列表值



**config 节点语法格式**

```
config 'section-type' 'section'
```

config 节点(后文统一称为节点)原则
           UCI 允许只有节点类型的匿名节点存在
           节点类型和名字建议使用单引号包含以免引起歧义
           节点中可以包含多个 option 选项或 list 列表选项。
           节点遇到文件结束或遇到下一个节点代表完成。



**option 选项语法格式**

```
option 'key' 'value'
```

option 选项(后文统一称为选项)原则
           选项的键与值建议使用单引号包含
           避免相同的选项键存在于同一个节点,否则只有一个生效



**list 列表选项语法格式**

```
list 'list_key' 'list_value'
```

list 列表选项(后文统一称为列表)原则
      选项的键与值建议使用单引号包含
      列表键的名字如果相同,则相同键的值将会被当作数组传递给相应软件



**UCI 的语法容错**

```
option example    value
option 'example'   value
option example    "value"
option "example"  'value'
option 'example'   "value"
```



**UCI 无法容忍的语法**

```
option 'example" "value'
option example some value with space
```

尽量使用常规字符去处理器 UCI,特殊字符有可能会破坏数据结构的完整性。



### 三、UCI 命令

语法格式：

```shell
Usage:
        uci [<options>] <command> [<arguments>]
```

命令:

```shell
Commands:
        batch
        export     [<config>]
        import     [<config>]
        changes    [<config>]
        commit     [<config>]
        add        <config> <section-type>
        add_list   <config>.<section>.<option>=<string>
        del_list   <config>.<section>.<option>=<string>
        show       [<config>[.<section>[.<option>]]]
        get        <config>.<section>[.<option>]
        set        <config>.<section>[.<option>]=<value>
        delete     <config>[.<section>[[.<option>][=]]]
        rename     <config>.<section>[.<option>]=<name>
        revert     <config>[.<section>[.<option>]]
        reorder    <config>.<section>=<position>
```

参数 <使用较少>:

```shell
Options:
        -c <path>  set the search path for config files (default: /etc/config)
        -d <str>   set the delimiter for list values in uci show
        -f <file>  use <file> as input instead of stdin
        -m         when importing, merge data into an existing package
        -n         name unnamed sections on export (default)
        -N         don't name unnamed sections
        -p <path>  add a search path for config change files
        -P <path>  add a search path for config change files and use as default
        -t <path>  set save path for config change files
        -q         quiet mode (don't print error messages)
        -s         force strict mode (stop on parser errors, default)
        -S         disable strict mode
        -X         do not use extended syntax on 'show'
```

**读写规则**
       UCI 读取总是先读取内存中的缓存,然后再读取文件中的
       进行过增加,修改,删除操作后要执行生效指令,否则所做修改只存留在缓存中



### 四、读取类语法
**取得节点类型**

```
uci get <config>.<section>
```

**取得一个值**

```
uci get <config>.<section>.<option>
```

**显示全部 UCI 配置**

```
uci show
```

**显示指定文件配置**

```
uci show <config>
```

**显示指定节点名字配置**

```
uci show <config>.<section>
```

**显示指定选项配置**

```
uci show <config>.<section>.<option>
```

**显示尚未生效的修改记录**

```
uci changes <config>
```

**匿名节点显示**

> 如果所显示内容有匿名节点,使用-X 参数可以显示出匿名节点的 ID

```
uci show -X <config>.<section>.<option>
```



### 五、写入类语法


**增加一个匿名节点到文件**

```
uci add <config> <section-type>
```

> 例如：/etc/config/dhcp配置中的节点配置项
>

> ```
> config domain
> 	option name 'openwrt'
> 	option ip '192.168.1.2'
> 	
> config domain
> 	option name 'cdn.jsdelivr.net'
> 	option ip '104.16.86.20'
> ```
>

> 以上 uci 命令为
>

> ```
> uci add dhcp domain
> uci set dhcp.@domain[0].name='openwrt'                                          # 网络→主机名→主机目录——“openwrt”
> uci set dhcp.@domain[0].ip='192.168.1.2'
> uci add dhcp domain
> uci set dhcp.@domain[1].name='cdn.jsdelivr.net'                                 # 网络→主机名→主机目录——“cdn.jsdelivr.net”
> uci set dhcp.@domain[1].ip='104.16.86.20'
> uci commit dhcp
> ```
>

> uci add dhcp domain即为将domain匿名节点添加至dhcp配置文件(/etc/config/dhcp文件)
>



**增加一个节点到文件中**

```
uci set <config>.<section>=<section-type>
```

> 例如：/etc/config/network配置中的节点配置项
>

> ```
> config interface 'lan'
> 	option type 'bridge'
> 	option proto 'static'
> 	option netmask '255.255.255.0'
> 	option ipaddr '192.168.1.2'
> 	option gateway '192.168.1.1'
> 	option dns '192.168.1.2'
> 	option delegate '0'
> 	option ifname 'eth0 eth1'
> 	option mtu '1492'
> ```
>

> 以上 uci 命令为
>

> ```
> uci set network.lan.type='bridge'                                                # lan口桥接
> uci set network.lan.proto='static'                                               # lan口静态IP
> uci set network.lan.ipaddr='192.168.1.2'                                         # IPv4 地址(openwrt后台地址)
> uci set network.lan.netmask='255.255.255.0'                                      # IPv4 子网掩码
> uci set network.lan.gateway='192.168.1.1'                                        # IPv4 网关
> #uci set network.lan.broadcast='192.168.1.255'                                   # IPv4 广播
> uci set network.lan.dns='192.168.1.2'                                            # DNS(多个DNS要用空格分开)
> uci set network.lan.delegate='0'                                                 # 去掉LAN口使用内置的 IPv6 管理
> uci set network.lan.ifname='eth0 eth1'                                           # 设置lan口物理接口为eth0、eth1
> uci set network.lan.mtu='1492'                                                   # lan口mtu设置为1492
> ```
>

> 类似的，如果network文件中没有wan选项，需要增加wan配置，uci 命令如下
>

> ```
> uci set network.wan=interface
> ```
>



**增加一个选项和值到节点中**

```
uci set <config>.<section>.<option>=<value>
```

> 例如：在 wan 口设置为pppoe拨号，以及相应的用户名、密码
>

> ```
> uci set network.wan.proto=pppoe  //设置wan口类型为pppoe加密
> uci set network.wan.username=[上网帐号]spa
> uci set network.wan.passworld=[上网密码].n
> ```
>



**增加一个值到列表中**

```
uci add_list <config>.<section>.<option>=<value>
```

> 例如：系统→时间同步→候选 NTP 服务器
>

> ```
> config timeserver 'ntp'
> 	option enabled '1'
> 	option enable_server '0'
> 	list server 'ntp.aliyun.com'
> 	list server 'time1.cloud.tencent.com'
> 	list server 'time.ustc.edu.cn'	
> ```
>

> 如果增加`list server 'cn.pool.ntp.org'`的项，则uci 命令如下：
>

> ```
> uci add_list system.ntp.server='cn.pool.ntp.org'
> uci commit system
> ```
>



**修改一个节点的类型**

```
uci set <config>.<section>=<section-type>
```



**修改一个选项的值**

```
uci set <config>.<section>.<option>=<value>
```

> 例如：将 wan 口由 pppoe 修改为 dhcp 动态IP
>

> ```
> uci set network.wan.proto=dhcp //设置wan口类型为dhcp
> ```
>



**删除指定名字的节点**

```
uci delete <config>.<section>
```

> 例如：删除 wan 口
>

> ```
> uci delete network.wan                                                              # 删除wan口
> uci delete network.wan6                                                             # 删除wan6口
> ```
>



**删除指定选项**

```
uci delete <config>.<section>.<option>
```

> 例如：由于设置错误，或者需要直接删除 lan 口广播设置
>

> ```
> uci delete network.lan.broadcast                                                    # 删除 IPv4 广播
> ```
>



**删除列表**

```
uci delete <config>.<section>.<list>
```

> 例如：如果删除时间服务器的列表，则uci命令如下
>

> ```
> uci delete system.ntp.server
> ```
>

> ```shell
> root@OpenWrt:~# uci show system
> system.@system[0]=system
> system.@system[0].hostname='OpenWrt'
> system.@system[0].ttylogin='0'
> system.@system[0].log_size='64'
> system.@system[0].urandom_seed='0'
> system.@system[0].timezone='CST-8'
> system.@system[0].zonename='Asia/Shanghai'
> system.ntp=timeserver
> system.ntp.enabled='1'
> system.ntp.enable_server='0'
> system.ntp.server='ntp.aliyun.com' 'time1.cloud.tencent.com' 'time.ustc.edu.cn' 'cn.pool.ntp.org'
> root@OpenWrt:~# uci delete system.ntp.server
> root@OpenWrt:~# uci show system
> system.@system[0]=system
> system.@system[0].hostname='OpenWrt'
> system.@system[0].ttylogin='0'
> system.@system[0].log_size='64'
> system.@system[0].urandom_seed='0'
> system.@system[0].timezone='CST-8'
> system.@system[0].zonename='Asia/Shanghai'
> system.ntp=timeserver
> system.ntp.enabled='1'
> system.ntp.enable_server='0'
> ```
>



**删除列表中一个值**

```
uci del_list <config>.<section>.<option>=<string>
```

> 例如：如果删除`list server 'cn.pool.ntp.org'`的列表，uci命令如下
>

> ```
> uci del_list system.ntp.server='cn.pool.ntp.org'
> ```
>



**生效修改**

> 任何写入类的语法,最终都要执行生效修改,否则所做修改只在缓存中,切记!

```
uci commit <config>
```

> 例如：修改ssh端口后，需要提交确认修改
>

> ```
> uci set dropbear.@dropbear[0].Port='8822'                                # SSH端口设置为'8822'
> uci commit dropbear
> ```
>


### 七、批量运行CUI命令

**格式**

```shell
uci -q batch <<-EOF >/dev/null
    <command> [<arguments>]
    ...
    <command> [<arguments>]
EOF

```
说明：进入uci命令操作模式，与在终端操作的区别是，
- [x] 操作不需要加uci前缀；
- [x] 该模式下，只能识别uci命令；


如，[12_network-generate-ula](https://github.com/coolsnowwolf/lede/blob/master/package/base-files/files/etc/uci-defaults/12_network-generate-ula)


```shell
[ "$(uci -q get network.globals.ula_prefix)" != "auto" ] && exit 0

r1=$(dd if=/dev/urandom bs=1 count=1 |hexdump -e '1/1 "%02x"')
r2=$(dd if=/dev/urandom bs=2 count=1 |hexdump -e '2/1 "%02x"')
r3=$(dd if=/dev/urandom bs=2 count=1 |hexdump -e '2/1 "%02x"')

uci -q batch <<-EOF >/dev/null
	set network.globals.ula_prefix=fd$r1:$r2:$r3::/48
	commit network
EOF

exit 0
```

如，[dsmboot](https://github.com/coolsnowwolf/lede/blob/master/package/lean/dsmboot/files/dsmboot)

```shell
#!/bin/sh

uci -q batch <<-EOF >/dev/null
	set dhcp.@dnsmasq[0].enable_tftp='1'
	set dhcp.@dnsmasq[0].dhcp_boot='pxelinux.0'
	set dhcp.@dnsmasq[0].tftp_root='/root'
	commit dhcp
EOF

exit 0
```

