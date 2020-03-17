---
layout: post
title: Ubuntu下的文件共享(tftp/nfs)
categories: Linux
tags: Linux
---

* content
{:toc}

## tftp

####  服务器端

* `sudo apt-get install tftpd-hpa`，安装tftpd-hpa

* `sudo vim /etc/default/tftpd-hpa`，配置tftp目录

  ```bash
  # /etc/default/tftpd-hpa
  TFTP_USERNAME="tftp"
  TFTP_ADDRESS=":69"
  TFTP_DIRECTORY="tftp根目录" #服务器目录,需要设置权限为777,chomd 777
  TFTP_OPTIONS="-l -c -s" # l表示listen模式，c可以创建新文件,s不需要指定路径
  ```

* `sudo service tftpd-hpa restart `，启动tftp服务

* `service tftpd-hpa status`，查看服务状态

<!--more-->

#### 客户端

* `apt-get install tftp-hpa`，安装tftp-hpa

* `tftp 127.0.0.1`，访问tftp服务器

  ```bash
  tftp>get test.txt  # 从服务器端下载test.txt文件
  tftp>put test1.txt # 将本地test1.txt上传到服务器端，注意服务端要配置-c，且777权限
  tftp>?             # 查看所有tftp子命令
  tftp>q             # 退出
  ```

* `tftp 127.0.0.1 -c get test.txt`，可以直接执行



## nfs

#### 服务器端

* `sudo apt-get install nfs-kernel-server`，安装nfs软件

* `sudo vim /etc/exports`，配置nfs目录，注意该目录配置成777权限

  ```bash
  # /etc/exports
  /home/nfs *(rw,sync,insecure,no_root_squash,no_subtree_check)
  ```

* `sudo /etc/init.d/rpcbind restart`，启动rpcbind服务，nfs共享时负责通知客户端

* `sudo /etc/init.d/nfs-kernel-server restart`，启动nfs服务

* `sudo exportfs -r `，如果/etc/exports更新则需要该命令刷新

#### 客户端

* `showmount -e 127.0.0.1`，显示NFS服务器上exports的目录，如下：

  ```bash
  Export list for 127.0.0.1:
  /home/nfs *
  ```

* 挂载和卸载，如下：

  ```bash
  # 挂载到本地/mnt/nfs
  mkdir /mnt/nfs
  chmod 777 /mnt/nfs
  sudo mount -t nfs 127.0.0.1:/home/nfs /mnt/nfs
  
  # 卸载
  sudo umount -f /mnt/nfs
  ```
