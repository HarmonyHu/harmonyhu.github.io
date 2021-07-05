---
layout: single
title:  UEFI Handle的来龙去脉
date:   2010-11-18
categories:
  - BIOS
tags:
  - UEFI
---

* content
{:toc}

>本文最初是2010-11-18发表于[BiosRen论坛](http://www.biosren.com/thread-3440-1-1.html), 现在挪到本人自己的域名博客

本文说明：本人刚学习UEFI不久，写该文一是为了将学到的东西做一个规范化的总结，二是为了给初学UEFI的兄弟起到借鉴作用。同样地，错误的地方肯定很多，还望能得到各位弟兄指正。要理解本文，您至少应该是读过UEFI Spec，不然请先阅读UEFI Spec。

## 一、一些概念的理解

UEFI中会有很多抽象概念，像service、protocol、handle等等，如果将这些抽象的概念放到实际的代码中理解的话，会有更清晰地认识，有了清晰的认识之后再把它们作为抽象来理解，就遂心应手的多了。

<!--more-->

首先说protocol，其实它就是一个由struct定义的结构体，这个结构体通常是由数据和函数指针组成，或其一。每个结构体的定义都有一个GUID与之对应。自然并不是所有的结构体都称之为protocol，protocol正如其名，它是一种规范，或称协议。比如要建立一个基于UEFI Driver Model的Driver，就必须要绑定一个`EFI_DRIVER_BINGING_PROTOCOL`的实例，并且要自定义且实现Support、Start、Stop函数以及填充实例中其他的数据成员。它就相当于已经规范了种种需求和步骤。

再说service，它就是UEFI定义的API函数，所有的service都被集中到`EFI_SYSTEM_TABLE`下面，都可以通过gST来调用(gST指向一个`EFI_SYSTEM_TABLE`的全局实例)。

接着本文重点说明handle。

## 二、`EFI_HANDLE`的定义

`EFI_HANDLE`定义是这样的：

	typedef void * EFI_HANDLE

`void *`用C语言来理解为不确定类型,它真正的类型是这样定义的(`EDK\Foundation\Core\Dxe\Hand\Hand.h`):

	typedef struct {
	  UINTN            Signature;
	  EFI_LIST_ENTRY   AllHandles;
	  EFI_LIST_ENTRY   Protocols;
	  UINTN            LocateRequest;
	  UINT64           Key;
	} IHANDLE;

比如定义一个变量`EFI_HANDLE hExample`，当你将它作为参数传递给service的时候，在service内部是这样使用它的：`IHANDLE * Handle=(IHANDLE*)hExample`。也就是说`IHANDLE*`才是handle的本来面目。为什么要弄的这么复杂呢？一是为了抽象以隐藏细节，二可能是为了安全。

## 三、关于`EFI_LIST_ENTRY`

要明白IHANDLE这个结构体，就要明白`EFI_LIST_ENTRY`是如何被使用的。`EFI_LIST_ENTRY`定义如下（`EDK\Foundation\Library\Dxe\Include\LinkedList.h`):

	typedef struct _EFI_LIST_ENTRY {
	    struct_EFI_LIST_ENTRY  *ForwardLink;
	    struct_EFI_LIST_ENTRY  *BackLink;
	} EFI_LIST_ENTRY;

大家立刻就会反应到，它用于实现双向链表。但是与一般的链表实现方式不一样，它纯粹是`EFI_LIST_ENTRY`这个成员的链接，而不用在乎这个成员所在的结构体。一般的链表要求结点之间的类型一致，而这种链表只要求结构体存在`EFI_LIST_ENTRY`这个成员就够了。比如说

	IHANDLE *handle1,*handle2;
	handle1->AllHandles->ForwardLink=handle2->AllHandles;
	handle2->AllHandles->BackLink=handle1->AllHandles;

这样handle1与handle2的AllHandles就链接到了一起。但是这样就只能进行AllHandles的遍历了，怎么样遍历IHANLE实例呢？。这时候就要用到`_CR`宏，`_CR`宏的定义如下：

	#define _CR(Record, TYPE, Field) ((TYPE *) ((CHAR8 *) (Record) - (CHAR8 *) &(((TYPE *) 0)->Field)))

这个宏可以通过结构体实例的成员访问到实例本身，它的原理可以参见
<http://www.biosren.com/thread-1407-1-1.html>或者<http://blog.csdn.net/hgf1011/archive/2009/10/06/4635888.aspx>
由handle1遍历到handle2的方法是这样的：

	IHANDLE *handle=
	    (IHANDLE*)_CR(handle1->ForwardLink,IHANDLE,AllHandles )

关于`EFI_LIST_ENTRY`就说的这里了。总结一点就是只要看到`EFI_LIST_ENTRY`，就应该联想到它的链表。像IHANDLE结构体中有两个`EFI_LIST_ENTRY`成员，就应该联想到每个IHANDLE实例处在两条链表中。

## 四、各种链表的引出

**（1）由IHANDLE中AllHandles引出的链表**
与IHANDLE相关的链表有很多，后面一一牵扯出来。IHANDLE中的AllHandles成员用来链接IHANDLE实例的。这个链表的头部是一个空结点，

	EFI_LIST_ENTRY   gHandleList;
	gHandleList->ForwardLink=gHandleList;
	gHandleList->BackLink=gHandleList;

每次IHANDLE都从`gHandleList->BackLink`插入进来。这时候大家就意识到了这个链表是一个环形双向链表。每当Driver建立一个新的`EFI_HANDLE`的时候就会插入到这条链表中来。这条链表被称之为`handle database`。

**（2）由IHANDLE中Protocols引出的链表**
再来关注IHANDLE中的Protocols这个成员，它又是指向何方？它指向以`PROTOCOL_INTERFACE`这个结构体实例。`PROTOCOL_INTERFACE`定义如下：


	typedef struct {
	  UINTN           Signature;
	  EFI_HANDLE      Handle;     //Back pointer
	  EFI_LIST_ENTRY  Link;       //Link on IHANDLE.Protocols
	  EFI_LIST_ENTRY  ByProtocol; //Link on PROTOCOL_ENTRY.Protocols
	  PROTOCOL_ENTRY *Protocol;   //The protocol ID
	  VOID           *Interface;  //The interface value
	  EFI_LIST_ENTRY  OpenList;   //OPEN_PROTOCOL_DATA list.
	  UINTN           OpenListCount;
	  EFI_HANDLE      ControllerHandle;
	} PROTOCOL_INTERFACE;


Driver会为handle添加多个protocol实例，这些实例也是链表的形式存在。`PROTOCOL_INTERFACE`的link用于连接以IHANDLE为空头结点以`PPOTOCOL_INTERFACE`为后续结点的链表。这个结构体又牵扯出更多的`EFI_LIST_ENTRY`。成员中Handle指向头空结点的这个handle，Protocol指向`PROTOCOL_ENTRY`这个结构体实例，这个实例存在于另一个链表中，称之为`Protocol Database`。后面再说这个`Protocol Database`。先说OpenList引出的链表。

**（3）由`PROTOCOL_INTERFACE`中OpenList引出的链表**
注释中已经说明OpenList引出`OPEN_PROTOCOL_DATA list`。`OPEN_PROTOCOL_DATA`定义如下：

	typedef struct {
	  UINTN           Signature;
	  EFI_LIST_ENTRY  Link;
	  EFI_HANDLE      AgentHandle;
	  EFI_HANDLE      ControllerHandle;
	  UINT32          Attributes;
	  UINT32          OpenCount;
	} OPEN_PROTOCOL_DATA;

看到这个结构体就应该想到这个链表的模型了，不多说。看到只有一个`EFI_LIST_ENTRY`，松了一口气，这条线路上的链表总算是到头了。

**（4）链表`Protocol Database`**
`PROTOCOL_ENTRY`的定义如下：

	typedef struct {
	  UINTN           Signature;
	  EFI_LIST_ENTRY  AllEntries; //All entries
	  EFI_GUID        ProtocolID; //ID of the protocol
	  EFI_LIST_ENTRY  Protocols;  //All protocol interfaces
	  EFI_LIST_ENTRY  Notify;     //Registerd notification handlers
	} PROTOCOL_ENTRY;

这个链表也有个头空结点，定义为：`EFI_LIST_ENTRY  mProtocolDatabase`。 这个链表通过AllEntries这个成员来链接。这里又有几个`EFI_LIST_ENTRE`，这意味着又有好几个链表。这样大家的脑子里可能就乱了。为了对这些链表有清晰的认识，下面是用visio画的简图，省略部分结构体成员，为了不出现飞线，结构体成员位置也挪动了一下。（此图画起来好不容易，我也要署名，呵呵）。


**（5）链表综述**
![](https://harmonyhu.github.io/img/Handle3.jpg)

恕我唠叨：

*   图中1表示以gHandleList为头空结点，以`EFI_HANDLE`实例的AllHandle成员为后续成员结点的环形双向链表；
*   图中2表示以`EFI_HANDLE`实例中Protocols成员为头空结点，以`PROTOCOL_INTERFACE`实例的Link成员为后续成员结点的环形双向链表；
*   图中3表示以`PROTOCOL_INTERFACE`实例中的OpenList成员为头空结点，以`OPEN_PROTOCOL_DATA`实例的Link成员为后续成员结点的环形双向链表（篇幅原因省略一部分）。
*   图中4表示以mProtocolDatabase为头空结点，以`PROTOCOL_ENTRY`实例的AllEntries成员为后续成员结点的环形双向链表。

后文直接将它们分别称之为链表1，链表2，链表3，链表4。 上面叙述过的链表这里就全部标识出来了， 如果把所有的链表都画出来的话，上图就乱了，所有剩下没有标志出来的我就直接叙述了。

*   链表5：关于`PROTOCOL_INTERFAC`E中的ByProtocol。 UEFI spec中已经说一个Protocol对应一个GUID， 一个Protocol因不同情况实例化多个实例。所有一个GUID对应着多个Protocol的实例。上图中GUID由`Protocol Database`来管理，而Protocol实例由`PROTOCOL_INTERFACE`链表来管理。所以ByProtocol成员所在的链表就要以一个链表4中的`PROTOCOL_ENTRY`中的Protocols成员为头空结点，以`PROTOCOL_INTERFACE`中的ByProtocol作为后续结点的双向环链表。比如说图中链表1的第一个handle加载有`ABC_PROTOCOL`实例，假如第二个handle也加载有`ABC_PROTOCOL`实例，那么这两个对应的`PROTOCOL_INTERFACE`实例就会连接到`ABC_PROTOCOL_GUID`对应的`PROTOCOL_ENTRY`实例上面。可以想象的到吧？呵呵。
*   链表6：关于`PROTOCOL_ENTRY`中的Notify。这就要涉及到新的结构体`PROTOCOL_NOTIFY`。我觉得有必要在Notity这里打住。

上图经过抽象后就成了我们经常看到的图，如下：

 ![](https://harmonyhu.github.io/img/handle0.JPG)

对比之前的链表图，是否对这个图有更清晰的认识呢？

## 五、以InstallProtocolInterface为例来看handle的内部运作
有了上面的准备后，我就以InstallProtocolInterface这个service来讲述handle的内部运作了。
经过一番顺藤摸瓜后，就会发现InstallProtocolInterface最终的形式是(`EDK\Foundation\Core\Dxe\Hand\Handle.c`):

	EFI_STATUS
	CoreInstallProtocolInterfaceNotify (
	  IN OUT EFI_HANDLE     *UserHandle,
	  IN EFI_GUID           *Protocol,
	  IN EFI_INTERFACE_TYPE  InterfaceType,
	  IN VOID               *Interface,
	  IN BOOLEAN             Notify
	)

对比与UEFI spec中InstallProtocolInterface的定义，CoreInstallProtocolInterfaceNotify中的Notify为TRUE。这个service的作用就是：当UserHandle为空时，就向handle database中插入新的handle，并且将参数中的Interface所指定的protocol加载到这个handle上面；当UserHandle不为空，就在`handle database`中找到这个handle，在将这个protocol加载上去。如果通过上面的链表图，你已经想象到了它是如何运作的，那么下文就已经多余了。
代码就不贴了，请直接对照EDK中的代码，从`handle.c`找到CoreInstallProtocolInterfaceNotify这个函数，想必这个文件大家都有。
从394行开始看：

*   462行用`CoreHandleProtocol(...)`检索链表1，查看UserHandle是否已存在于`handle database`中。
*   476行用`CoreFindProtocolEntry(...)`检索链表4，查看GUID是否已经存在于链表中，若不存在在创建一个以参数Protocol为GUID的`PROTOCOL_ENTRY`实例ProtEntry插入链表4中。
*   493行露出`EFI_HANDLE`的本质了，它是`(IHANDLE*)`。
*   494行到518行为创建一个handle及初始化它的过程，看仔细了，对理解handle很有用。初始化后就插入到链表1中。
*   533行到554行，对新创建的`PROTOCOL_INTERFACE`实例Prot进行初始化，对照链表结构库看仔细了，尤其是各种指针的去向（参数Interface挂接到了Prot下面）。初始化后将Prot插入到链表2中。

这样这个函数就介绍的差不多了，这也只是为了做一个引子，像其他有关handle的函数想必也都在这个文件中，头文件的定义很多都在`hand.h`中，只要有耐心，应该都能看的懂。
附件是EDK中的源码[Hand.rar](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/other/Hand.rar)