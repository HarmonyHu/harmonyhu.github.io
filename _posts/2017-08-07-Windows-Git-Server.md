---
layout: article
title: Windows下用gogs搭建Git服务器
categories: Git
tags: gogs
---

* content
{:toc}

#### 需要的软件及官网
[MySQL](https://www.mysql.com)
[git](https://git-scm.com)
[gogs](https://gogs.io)

<!--more-->

#### 搭建过程
1. 安装MySQL，并创建gogs数据库:`create database gogs;`。
2. 安装git，并将git安装路径下的bin和usr/bin路径添加到系统变量Path中。
3. 解压gogs，cmd命令到gogs目录，执行gogs web。
4. 浏览器地址输入127.0.1.1:3000，进入配置界面配置。
5. 将gogs配置为系统服务，如下gogs路径为D:\gogs，
创建服务：`sc create gogs start= delayed-auto binPath= ""D:\gogs\gogs.exe" web"`
启动服务：`sc start gogs`
停止服务：`sc stop gogs`
删除服务：`sc delete gogs`

#### 注意事项
1. 请都用管理员权限安装和运行。
2. 如果浏览器打开地址无法访问，在Windows防火墙入栈规则里面添加3000端口。
3. 完成配置后，对应gogs/custom/conf的app.ini文件。
后续改配置可以直接修改该文件，[配置参考说明](https://gogs.io/docs/advanced/configuration_cheat_sheet)。
如下几个配置比较有用：
```
[repository]
DISABLE_HTTP_GIT = true (注：关闭git http访问库）
[repository.upload]
ENABLED = false （注：关闭直接网页上传功能）
[server]
START_SSH_SERVER = true （注：开启内置ssh功能）
OFFLINE_MODE     = true （注：开启离线模式）
LANDING_PAGE     = explore （注：主页显示explore页面）
```
4. 如果客户端的ssh连接出现如下错误：
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
```
则客户端执行如下命令，查看和更新对应的host:
```
ssh-keygen -l -f ~/.ssh/known_hosts
ssh-keygen -R 服务器端的ip地址
```