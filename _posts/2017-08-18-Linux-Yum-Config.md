---
layout: article
title: 配置Linux的yum源(RHEL7.3 x64为例)
categories: Linux
tags: Yum
---

* content
{:toc}

主要以RHEL7.3 64位为例，源是[163源](mirrors.163.com)。

## 1. 下载yum的安装包
登录`http://mirrors.163.com/centos/`，找到对应的版本yum的Packages文件并下载下来，比如如下命令获取
```bash
wget http://mirrors.163.com/centos/7.3.1611/os/x86_64/Packages/yum-3.4.3-150.el7.centos.noarch.rpm
wget http://mirrors.163.com/centos/7.3.1611/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.31-40.el7.noarch.rpm
wget http://mirrors.163.com/centos/7.3.1611/os/x86_64/Packages/yum-metadata-parser-1.1.4-10.el7.x86_64.rpm
```

<!--more-->

## 2. 删除原有yum安装包
```bash
rpm -qa|grep yum|xargs rpm -e --nodeps
```

## 3. 安装下载好的yum安装包
```  bash
rpm -ivh yum-*
```
如果提示缺少其他文件，则继续用wget下载并一起安装

## 4. 配置yum源
```bash
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
```
得到这个文件后将文件里的$releasever全部替换为版本号，比如此例的版本号是7.3.1611，执行如下命令：

```bash
sed -i s/\$releasever/7.3.1611/g CentOS7-Base-163.repo
```

并拷贝到目录`/etc/yum.repos.d/`

## 5. 更新yum源
```
yum clean all
yum makecache
```



## 附：国内linux源

1. 企业站
   * [阿里](mirrors.aliyun.com)
   * [163](mirrors.163.com)
   * [搜狐](mirrors.sohu.com)

2. 教育站
   * [清华](mirror.tuna.tsinghua.edu.cn)
   * [中科大](mirrors.ustc.edu.cn)
   * [华科](mirror.hust.edu.cn)