---
layout: post
title: Windows下用gogs搭建Git服务器
date: 2017-08-07 00:00
categories: git
tags: git gogs
---

* content
{:toc}

#### 需要的软件及官网  
[MySQL](https://www.mysql.com)  
[git](https://git-scm.com)  
[nssm](http://nssm.cc)  
[gogs](https://gogs.io)  
[freesshd](http://www.freesshd.com)  

#### 搭建过程  
1. 安装MySQL，并创建gogs数据库:`create database gogs;`  
2. 安装git，并将安装路径下的Git/bin和Git/usr/bin路径添加到系统变量Path中  
3. 安装freesshd，并在安装路径下根据需要修改配置文件，比如允许最大连接数等等  
4. 将nssm.exe放到`%PATH%`路径，比如system32  
5. 安装gogs，过程如下：
* 将gogs解压，比如解压后路径为D:/gogs  
* `gogs/scripts/windows/install-as-service.bat`文件中内容更新:`SET gogspath=D:/gogs`  
* cmd命令到gogs目录，执行gogs web  
6. 浏览器地址输入127.0.1.1:3000，进入配置界面。完成配置后，对应gogs/custom/conf的app.ini文件。后续改配置可以直接修改该文件。

#### 注意事项  
1. 尽量都用管理员权限安装和运行  
2. 如果浏览器打开地址无法访问，在Windows防火墙入栈规则里面添加3000端口  