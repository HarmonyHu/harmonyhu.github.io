---
layout: post
title: arm-trusted-firmware学习整理
categories: Linux
tags: Linux ARM
---

* content
{:toc}
本文以AArch64为准，内容以翻译原文为主。

## 资源说明

* 源码地址：[arm-trusted-firmware](https://github.com/ARM-software/arm-trusted-firmware)
* 使用说明：[user-guide](https://github.com/ARM-software/arm-trusted-firmware/blob/master/docs/user-guide.rst)
* 框架流程：[firmware-design](https://github.com/ARM-software/arm-trusted-firmware/blob/master/docs/firmware-design.rst)



## 基本介绍

#### 权限模型 (Exception Levels)

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/el.jpg) 

基本分为EL3-EL0，从高level转低level通过ERET指令，从低level转高level通过exception方式。

各个级别说明：

* **Non-secure EL0**: Unprivileged applications, such as applications downloaded from an App Store.
* **Non-secure EL1**: Rich OS kernels from, for example, Linux, Microsoft Windows, iOS.
* **Non-secure EL2**: Hypervisors, from vendors such as Citrix, VMWare, or OK-Labs.
* **Secure EL0**: Trusted OS applications.
* **Secure EL1**: Trusted OS kernels from Trusted OS vendors such as Trustonic.
* **Secure EL3:** Secure Monitor, executing secure platform firmware provided by Silicon vendors and OEMs ARM Trusted Firmware 



## 启动过程

基本分为BL1->BL2->(BL31/BL32/BL33)这几个阶段，整体框图如下：

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/atf_boot_flow.jpg)

