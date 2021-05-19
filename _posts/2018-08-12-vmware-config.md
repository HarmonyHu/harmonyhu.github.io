---
layout: single
title: VMware使用
categories:
  - Linux
tags:
  - vmware
---

* content
{:toc}

## 一、如何扩展磁盘容量

1. 在虚拟机系统下电后，选择`编辑虚拟机设置`->`硬盘`->`扩展`

2. 启动虚拟机系统后执行`sudo gparted`，然后进行配置

   1）`linux-swap`配置为`swap off`，然后`delete`

   2）`extended`区域delete

   3）`ext4`区域resize，预留4GB空间

   4）`unallocated`区域，`new`->`Extended Partition`，然后再`new`->`linux-swap`

   5）选√

   6）`linux-swap`区域选为`swap on`，然后记录下`linux-swap`区域的uuid

3. `sudo gedit /etc/fstab`，替换swap的uuid

4. 执行`sudo swapoff -a`，`sudo swapon -a`

5. 执行`reboot`，重启系统

<!--more-->

## 二、常见使用

* 按F2进入BIOS，按ESC进入boot menu


