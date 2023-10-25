# 缓存加速

开启缓存加速，有助于缩减在线编译总时长。

在未开启缓存加速的情况下，编译时长在4~5小时时间，那么开启后，相应时间可以缩短至2小时，甚至1个多小时。



## 一、开启`缓存加速`



### 1、settings.ini文件设置

在`build`目录的子文件夹内，把`settings.ini`中的设置如下：

```ini
ENABLE_CACHEWRTBUILD="true"
```



### 2、.config配置文件设置

在.config配置文件内增加两行配置如下：

```ini
CONFIG_DEVEL=y
CONFIG_CCACHE=y
```



<br />



## 二、编译失败问题解决

如遇OpenWrt源码更新后，在线编译失败，确定不是源码bug问题；

可尝试清除对应的缓存文件，重新编译。



### 1、清除对应的缓存文件

按照如下操作：

点击存储库`Actions` -> `Caches` -> 选择需要删除的缓存，点击右侧`垃圾桶`图标，即可删除相应缓存。

然后尝试全新编译。



### 2、关闭`缓存加速`

如果依旧无法编译通过，也可以尝试关闭缓存加速，再次尝试。

在`build`目录的子文件夹内，把`settings.ini`中的设置如下

```ini
ENABLE_CACHEWRTBUILD="false"
```



<br />



