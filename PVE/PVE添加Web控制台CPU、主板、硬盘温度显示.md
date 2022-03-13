

### 一、安装硬件温度监控软件 lm-sensors、hddtemp、nvme-cli



**安装lm-sensor**

lm-sensors（Linux-monitoring sensors，Linux监控传感器）是一款linux的硬件监控的软件，用来监控主板，CPU的工作电压，风扇转速、温度等数据。

```
apt update && apt install lm-sensors
```

查看sensors版本`sensors -v`

```
root@pve:~# sensors -v
sensors version 3.6.0 with libsensors version 3.6.0
```

执行sensors-detect命令

`sensors-detect`
基本一路`yes`，最后回车。

```
root@pve:~# sensors-detect

# sensors-detect version 3.6.0

# System: Default string Default string [Default string]

# Kernel: 5.13.19-6-pve x86_64

# Processor: Intel(R) Celeron(R) J4125 CPU @ 2.00GHz (6/122/8)

This program will help you determine which kernel modules you need
to load to use lm_sensors most effectively. It is generally safe
and recommended to accept the default answers to all questions,
unless you know what you're doing.

Some south bridges, CPUs or memory controllers contain embedded sensors.
Do you want to scan for them? This is totally safe. (YES/no): YES

...

To load everything that is needed, add this to /etc/modules:
#----cut here----
# Chip drivers
coretemp
it87
#----cut here----
If you have some drivers built into your kernel, the list above will
contain too many modules. Skip the appropriate ones!

Do you want to add these lines automatically to /etc/modules? (yes/NO)yes
Successful!

Monitoring programs won't work until the needed modules are
loaded. You may want to run '/etc/init.d/kmod start'
to load them.

Unloading cpuid... OK
```

执行sensors命令

```
root@pve:~# sensors
acpitz-acpi-0
Adapter: ACPI interface
temp1:        +36.0°C  (crit = +95.0°C)

coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +36.0°C  (high = +105.0°C, crit = +105.0°C)
Core 0:        +36.0°C  (high = +105.0°C, crit = +105.0°C)
Core 1:        +36.0°C  (high = +105.0°C, crit = +105.0°C)
Core 2:        +36.0°C  (high = +105.0°C, crit = +105.0°C)
Core 3:        +36.0°C  (high = +105.0°C, crit = +105.0°C)
```

> 注：temp1为主板温度。



**安装硬盘温度检测：hddtemp**

> 适用于msata、sata等接口硬盘

```shell
apt install hddtemp
```

执行命令`hddtemp /dev/sd?`检测下温度。

```shell
root@pve:~# hddtemp /dev/sd?
/dev/sda: GM512: 41°C

root@pve:~# hddtemp /dev/sda?
/dev/sda1: GM512: 42°C
/dev/sda2: GM512: 42°C
/dev/sda3: GM512: 42°C
```

修改hddtemp文件权限

PVE的web服务以用户www-data身份运行，需要修改hddtemp的权限。

查找下hddtemp的位置

```shell
root@pve:~# which hddtemp
/usr/sbin/hddtemp
```

修改hddtemp权限

```
chmod +s /usr/sbin/hddtemp
```



**安装安装nvme-cli**

> 适用于NVME(m.2)等接口硬盘

```shell
apt install nvme-cli
```

查看nvme硬盘列表

```shell
nvme list
```

执行命令

```shell
nvme smart-log /dev/nvme0 | grep "^temperature"
```

修改nvme-cli文件权限

```shell
chmod +s /usr/sbin/nvme
```



### 二、编辑PVE web服务文件



**修改Nodes.pm**

文件路径`/usr/share/perl5/PVE/API2/Nodes.pm`

搜索pveversion关键字，然后按照下面修改添加即可。

	$res->{swap} = {
	    free => $meminfo->{swapfree},
	    total => $meminfo->{swaptotal},
	    used => $meminfo->{swapused},
	};
	
	$res->{pveversion} = PVE::pvecfg::package() . "/" .
	    PVE::pvecfg::version_text();
	
	#$res->{cpu_sensors} = `lscpu | grep MHz`;		# 获取 CPU频率，当前频率，最小频率，最大频率
	
	$res->{cpusensors} = `cat /proc/cpuinfo | grep -i  "cpu MHz"`;	# 获取 CPU频率，每个核心的当前频率
		
	$res->{temperature} = `sensors`;				# 获取 CPU 与主板温度
	
	$res->{hdd_temperature} = `hddtemp /dev/sd?`;	# 获取msata、sata硬盘温度
	
	#$res->{hdd_temperature} = `nvme smart-log /dev/nvme0 | grep "^temperature" | awk -F: '{print $2}'`;	# 获取NVME硬盘温度
	
	my $dinfo = df('/', 1);     # output is bytes
	
	$res->{rootfs} = {
	    total => $dinfo->{blocks},
	    avail => $dinfo->{bavail},
	    used => $dinfo->{used},
	    free => $dinfo->{blocks} - $dinfo->{used},
	};

> 注：如果为NVME硬盘，需要将上面获取NVME硬盘温度前的#去掉，同时将msata硬盘温度获取代码前加#



**修改pvemanagerlib.js**

文件路径`/usr/share/pve-manager/js/pvemanagerlib.js`

搜索kversion关键字，然后按照下面修改添加即可。

	{
	    itemId: 'kversion',
	    colspan: 2,
	    title: gettext('Kernel Version'),
	    printBar: false,
	    textField: 'kversion',
	    value: '',
	},
	//{
	//    itemId: 'version',
	//    colspan: 2,
	//    printBar: false,
	//    title: gettext('PVE Manager Version'),
	//    textField: 'pveversion',
	//    value: '',
	//},
	{
	    itemId: 'CPUMHz',
	    colspan: 2,
	    printBar: false,
	    title: gettext('CPU频率'),
	    textField: 'cpusensors',
	    renderer:function(value){
	        const m = value.match(/(?<=:\s+)(\d+)/g);
	        return `${m[0]} | ${m[1]} | ${m[2]} | ${m[3]} MHz`;
	    }
	},
	{
	    itemId: 'thermal',
	    colspan: 2,
	    printBar: false,
	    title: gettext('CPU温度'),
	    textField: 'temperature',
	    renderer: function(value){
	        const p0 = value.match(/Package id 0.*?\+([\d\.]+)?/)[1];
	        const b0 = value.match(/temp1.*?\+([\d\.]+)?/)[1];
	        const c0 = value.match(/Core 0.*?\+([\d\.]+)?/)[1];
	        const c1 = value.match(/Core 1.*?\+([\d\.]+)?/)[1];
	        const c2 = value.match(/Core 2.*?\+([\d\.]+)?/)[1];
	        const c3 = value.match(/Core 3.*?\+([\d\.]+)?/)[1];
	        return `CPU: +${p0}℃（+${c0}，+${c1}，+${c2}，+${c3}）℃ | Board: +${b0}℃`
		}
	},
	{
		itemId: 'thermal-hdd',
		colspan: 2,
		printBar: false,
		title: gettext('HDD温度'),
		textField: 'hdd_temperature',
		renderer: function(value) {
			value = value.replaceAll('Â', '');
			return value.replaceAll('\n', '<br>');
		}
	},
	],

> 注：其中`value = value.replaceAll('Â', '');`是替换显示中的错乱码，如`/dev/sda: GM512: 42Â°C`



### 三、重启Web控制台

```shell
systemctl restart pveproxy
```

> 注意：
>

> 若浏览器显示内容没有发生变化，可以按ctrl+F5强制刷新或者清理缓存后重试。
> 若 Web 管理页面不能正常显示，如白屏，则可能代码有错误，应修改后重试。
> 若 温度的显示值为null，请打开开发者工具，在Console中进行查看

