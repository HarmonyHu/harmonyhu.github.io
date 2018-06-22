---
layout: post
title: Linux Driver的安装和卸载
categories: Linux
tags: Linux module
---

* content
{:toc}

## ko文件的安装与卸载

####  安装

```bash
# 将ko文件拷贝到目录
target_folder="/lib/modules/$(uname -r)/kernel/drivers/test"
mkdir -p -m 755 $target_folder
cp test.ko $target_folder -f
# 更新和加载模块
depmod -a
modprobe test
# 设备Driver安装完成后会更新/lib/modules/$(uname -r)/module.alias文件，
# 该文件保证设备与driver的安装关系，当系统重启后，如果存在该设备，driver则被自动加载
```


#### 卸载

```bash
modprobe -r test
rm -rf $target_folder
depmod -a
```

#### 其它命令

```bash
insmod test.ko # 单次加载test模块
rmmod test.ko  # 卸载test模块
lsmod          # 查看以加载模块列表
modinfo test   # 查看以安装的test模块的信息

#如何判断模块是否加载？
lsmod | grep -q test
if [ $? -eq 0 ]; then echo "Installed" fi
```

#### 如何保证每次重启都加载

1. 如果是设备Driver，上文已经说明，不需要特别动作
2. 如果是其他Driver，与设备无关，则需要以下动作：  
   * 通用做法：将module名称填到文件`/etc/modules-load.d/*.conf`
   * ubuntu：将module名称填到文件`/etc/modules`



## 安装包安装与卸载

#### Linux发行版本

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/linux_tree.jpg) 

#### deb文件 (Debian)

```bash
dpkg -i package.deb # 安装
dpkg -r package #  卸载
dpkg -c package.deb #查看安装包内容
dpkg -l #查看已经安装的包
```

#### rpm文件 (Fedora)

```bash
rpm -ivh package.rpm # 安装
rpm -e package #卸载
rpm -qa #查看已经安装的包
```

#### dkms (通用)

```bash
# 先将test拷贝到目录/usr/src/test-0.0.1，然后执行命令
# 添加，将/usr/src/test-0.0.1拷贝到/var/lib/dkms/test/0.0.1/source
dkms add -m test -v 0.0.1
# 编译 (需要先添加)
dkms build -m test -v 0.0.1
# 安装 (需要先编译)
dkms install -m test -v 0.0.1
# 卸载
dkms uninstall test/0.0.1
# 卸载和删除 （/var/lib/dkms/test/目录被删除)
dkms remove test/0.0.1 --all
# 制作rpm包 (需要先编译)
dkms mkrpm -m test -v 0.0.1
# 制作deb包 (需要先编译)
dkms mkdeb -m test -v 0.0.1
```

