---
layout: post
title: Linux Device Driver
categories: Linux
tags: ARM
---

* content
{:toc}
## 设备驱动模型

* 由描述设备相关的结构与描述驱动相关的结构组成。如usb总线有`usb_device`和`usb_driver`，dts描述设备有`platform_device`和`platform_driver`

* 通常device由总线或者kernel生成，然后由相应的driver与其绑定

* 设备抽象结构体`strcut device`(include/linux/device.h)，具体设备都会包含一个struct device成员，如`usb_device`定义如下：

  ```c++
  // include\linux\usb.h
  struct usb_device {
  	int		devnum;
  	......
  	struct device dev;
      ......
  ```

* 驱动抽象结构体`struct device_driver`(include/linux/device.h)

* class用于对设备进行分类管理

<!--more-->

## 相关目录

#### /sys

sysfs挂载点目录，主要用于描述设备驱动模型，包含如下子目录：

```bash
$ ls /sys
block  class  devices   fs          kernel  power
bus    dev    firmware  hypervisor  module
```

* module: 所有被安装到内核的模块，都会在该目录下存在同名文件夹

  ```bash
  $ ls /sys/module/
  8250                 i8042        rng_core
  ablk_helper          ima          scsi_mod
  acpi                 input_leds   scsi_transport_spi
  acpi_cpufreq         intel_idle   serio_raw
  acpiphp              ipv6         sg
  aesni_intel          joydev       shpchp
  aes_x86_64           kdb          spurious
  ```

* bus: 所有的系统总线存在于在目录下，各个子目录又包含该总线下的设备和对应的驱动，如下：

  ```bash
  # 各个系统总线
  $ ls /sys/bus
  acpi         event_source  mipi-dsi  pci          scsi   virtio
  clockevents  i2c           mmc       pci_express  sdio   vme
  clocksource  machinecheck  nd        platform     serio  workqueue
  # pci总线下的设备
  $ ls /sys/bus/pci/devices
  0000:00:00.0  0000:00:15.0  0000:00:16.1  0000:00:17.2  0000:00:18.3
  0000:00:01.0  0000:00:15.1  0000:00:16.2  0000:00:17.3  0000:00:18.4
  0000:00:07.0  0000:00:15.2  0000:00:16.3  0000:00:17.4  0000:00:18.5
  # pci设设备相应的driver
  $ ls /sys/bus/pci/drivers
  agpgart-intel  bmdrv           iosf_mbi_pci  pcieport     vmwgfx
  agpgart-via    dwc2-pci        mptspi        piix4_smbus  vmw_pvscsi
  ahci           e1000           ohci-pci      serial       vmw_vmci
  ```

* class: 所有设备类的目录，如下：

  ```bash
  # 各个设备类
  $ ls /sys/class/
  ata_device     dmi             leds          ppp           spi_master
  ata_link       drm             mdio_bus      printer       spi_transport
  ata_port       drm_dp_aux_dev  mem           pwm           pci_bus
  # pci_bus类下的设备
  $ ls /sys/class/pci_bus
  0000:00  0000:04  0000:08  0000:0c  0000:10  0000:14  0000:18  0000:1c  0000:20
  0000:01  0000:05  0000:09  0000:0d  0000:11  0000:15  0000:19  0000:1d  0000:21
  ```

* devices: 包含系统所有的设备，按照层次结构分布，如下：

  ```bash
  $ ls /sys/devices
  breakpoint  LNXSYSTM:00  pci0000:00  pnp0      system      virtual
  cpu         msr          platform    software  tracepoint
  $ ls /sys/devices/system/cpu #cpu信息
  ```

* dev: 包含block和char，存放块设备和字符设备的主次号(major:minor)，指向/sys/devices中的设备，如下：

  ```bash
  $ ll /sys/dev/char
  10:1 -> ../../devices/virtual/misc/psaux/
  10:175 -> ../../devices/virtual/misc/agpgart/
  10:183 -> ../../devices/virtual/misc/hw_random/
  10:200 -> ../../devices/virtual/misc/tun/
  10:223 -> ../../devices/virtual/misc/uinput/
  10:227 -> ../../devices/virtual/misc/mcelog/
  ```

#### /dev

该目录存放**设备文件**，可以理解成对上层应用提供使用的接口文件，该文件通常由驱动创建，内容参考如下：

  ```bash
  $ ls /dev
  agpgart          loop4               stderr  tty35  tty8       ttyS8
  autofs           loop5               stdin   tty36  tty9       ttyS9
  block            loop6               stdout  tty37  ttyprintk  uhid
  cdrom            mapper              tty1    tty4   ttyS10     userio
  ```

## Platform驱动模型

* 相对USB、PCI等物理总线来说，platform总线是虚拟出来的。在Soc系统中许多外部设备直接挂在CPU的内存空间，不依附任何总线；虚拟出platform总线，用于与驱动模型保持一致。
* 直接挂在Soc空间的设备，通过dts(Device tree source) 描述资源。linux启动时根据dtb文件，生成platform device设备。
* platform总线相关代码：`driver\base\platform.c`
* 结构体和方法定义：`include\linux\platform_device.h`

#### platform_device

```c
struct platform_device {
	const char	*name;  //平台设备的名字
	int		    id;     //ID是用来区分设备名字相同时通过在后面添加一个数字来区分
	struct device	dev; //内置的device结构体
	u32		num_resources; //resource数组数量
	struct resource	*resource;  //指向资源结构体数组
	const struct platform_device_id	*id_entry; //用于与设备驱动匹配的id_table表
	char *driver_override; /* Driver name to force a match */
	struct pdev_archdata	archdata; //自留数据
};

struct resource {      // 资源结构体
    resource_size_t start;  // 资源的起始值，如果是地址，那么是物理地址，不是虚拟地址
    resource_size_t end;    // 资源的结束值，如果是地址，那么是物理地址，不是虚拟地址
    const char *name;       // 资源名
    unsigned long flags;    // 资源的标示，用来识别不同的资源
    struct resource *parent, *sibling, *child;   // 资源指针，可以构成链表
};
```

#### platform_device与dts关系

```c
// dts片段
test@0x10000000 {
    compatible = "mytest,test";
    reg = <0x0 0x10000000 0x0 0x1000>,
          <0x0 0x10002000 0x0 0x1000>;
    reg-names = "rega", "regb";
};
```

linux启动后，会生成/sys/bus/platform/10000000.test设备，相应的platform_device结构体数据如下：

```c
platform_device {
	name = "10000000.test",
	id = 0,
	num_resources = 2,
	resource = {"rega":[0x10000000,0x10001000], 
                "regb":[0x10002000,0x10003000]}
};
```

#### platform_driver的定义

```c
struct platform_driver {
	int (*probe)(struct platform_device *);  //设备添加后会触发
	int (*remove)(struct platform_device *); //设备删除后会触发
	void (*shutdown)(struct platform_device *);
	int (*suspend)(struct platform_device *, pm_message_t state);
	int (*resume)(struct platform_device *);
	struct device_driver driver;   //内置device_driver
	const struct platform_device_id *id_table; //设备驱动支持列表
	bool prevent_deferred_probe;
};
```

#### driver与device的匹配

```c
static int platform_match(struct device *dev, struct device_driver *drv) 
// 总线下的设备与设备驱动的匹配函数
{
    if (pdrv->id_table)    //如果pdrv中的id_table表存在，则匹配id_table
        return platform_match_id(pdrv->id_table, pdev) != NULL;  
    //  匹配 pdev->name与drv->name名字是否形同
    return (strcmp(pdev->name, drv->name) == 0);
}
```

#### driver典型写法

```c
static const struct of_device_id my_test_match[] = {
    { .compatible = "mytest,test" },{ }, //与dts中的compatible保持一致
};

MODULE_DEVICE_TABLE(of, my_test_match); //映射设备，/lib/modules/KERNEL/modules.alias

static struct platform_driver my_test_driver = {
    .probe  = my_test_probe,
    .remove = my_test_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "my-test", //此处可以写成10000000.test，用name匹配device，但没必要
        .of_match_table = my_test_match,
    }
};
module_platform_driver(my_test_driver);

// pdev由kernel传入
static int my_test_probe(struct platform_device *pdev){
    platform_get_resource(pdev, ...); // 获取资源
    class_create(THIS_MODULE, ...);  // 创建class，生成/sys/class/my-test
    alloc_chrdev_region(...);  //申请id
    device_create(...); //创建device, 生成/sys/devices/.../my-test
    cdev_init(...);  //创建字符设备，生成/dev/my-test0
    return 0;
}

static int my_test_remove(struct platform_device *pdev) {
	device_destroy(...); // 释放资源
	class_destroy(...); // 释放资源
	return 0;
}
```

