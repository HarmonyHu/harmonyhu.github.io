---
layout: post
title:  SMBus读取从设备数据总结
date:   2010-09-01
categories: BIOS
tags: BIOS SMBus
---

* content
{:toc}

>本文最初是2010-11-18发表于[BiosRen论坛](http://www.biosren.com/thread-3072-1-1.html),现在挪到本人自己的域名博客  

说明：本人刚入门，写该文只是为了总结刚学到的知识。全部内容都是经过实践得出来的。但实践上的结果并不能反映理论上的正确。所以若有不对的地方还请指正。另外本文也借鉴了LightSeed前辈(<http://www.biosren.com/thread-1075-1-1.html>)的相关文章。  
要阅读本文，您可能需要ICH9 spec。要实践本文，您需要纯DOS环境，RU软件或者ADU软件。  
本打算贴上图片说明问题，但是不知道怎么贴图片，所以就都改用文字描述了。

<!--more-->

## 1. 简单介绍  
SMBus主要读取方式有byte data(字节读取)方式和block(块读取)方式。当用byte data读取方式时，涉及到的IO寄存器有HST_STS，HST_CNT，HST_CMD，XMIT_SLVA，HST_D0。如果采用block的读取方式，除了前面需要关注的几个寄存器，还要关注两个寄存器，HOST_BLOCK_DB和AUX_CTL。当然这些只是最需要关注的寄存器，还有其他的寄存器可能也会影响到读取数据的过程，比如SMBUS PCI配置中的I2C_EN以及HST_EN等等（目前测试过程以及对应的程序无法保证百分百的考虑到位）。这里只把它们当成是默认设置。  
   
在ICH9 spec中有一段关于SMBus执行命令过程中HST_STS变化情况的描述，很重要，如下：  

>In all of the following commands, the Host Status Register (offset 00h) is used to determine the progress of the command. While the command is in operation, the HOST_BUSY bit is set. If the command completes successfully, the INTR bit will be set in the Host Status Register. If the device does not respond with an acknowledge, and the transaction times out, the DEV_ERR bit is set. If software sets the KILL bit in the Host Control Register while the command is running, the transaction will stop and the FAILED bit will be set.
    
这段话表明，HOST_BUSY被置1可以作为SMBus忙的标志，INTR被置1可以作为命名被成功执行到结束的标志，DEV_ERR可以作为命名执行出错的标志，另外还有其他一些错误标志位都可以作为出错标志。FAILED可以作为命名被KILL中断的标志。  

这里将用两种方式来说明读取数据的过程，一是采用RU软件测试的方式；二是采用汇编代码。  


## 2. SMBus读取数据过程测试

### 2.1 Byte Data读取方式测试 

第一步，将`HST_STS`(00H)设置为1EH（清掉各个标志位），可以看到HST_STS数值变成了40H。  
第二步，将`XMIT_SLVA`(04H)设置为A1H，说明是要读取SPD。  
第三步，将`HST_CMD`(03H)设置为00H，说明读取SPD中的00H处的数据，若要读取01H处的数据，就设置为01H。  
第四步，将`HST_CNT`(02H)设置为48H(采用字节读取方式，并START)，这是可以看到`HST_CNT`变成了08H，`HST_STS`变成了42H(说明INTR并且！`HOST_BUSY`，对比前面的英文描述)，`HST_D0`变成了7F(这个是本测试电脑的SPD的第一个数据)，也说明读取数据的目的已经达到。  

以上是严格按照正确的方式读取的，现在不将`HST_STS`清掉，即现在的值是42H，再按照第二步做到第四步，可以看到并没有读取到数据，说明`HST_STS`中的一些标志位对读取成功与否至关重要，这时如果用1EH清掉`HST_STS`中的相关标志位，也就是说将第一步换成最后一步，可以看到仍然可以读取到数据，这说明了什么呢？暂时记录这个测试结果，但并不表明这种方式可取。  
    
### 2.2 Block 读取方式测试

该种读取方式比之于Byte Data方式要复杂一些，首先要特别关注AUX_CTL(0DH)中的E32B位。该为置1与否，也决定了读取过程。以下分别进行测试。


**`AUX_CTL`设置为02H**  

* 第一步，将`HST_STS`(00H)设置为1EH（清掉各个标志位），可以看到HST_STS数值变成了40H。  
* 第二步，将`XMIT_SLVA`(04H)设置为A1H，说明是要读取SPD。  
* 第三步，将`HST_CMD`(03H)设置为00H，其实也是设置偏移地址的，如果设置成10H，那么就从10H位置读取数据。  
* 第四步， 将`HST_CNT`(02H)设置为54H(采用Block读取方式，并START)，这是可以看到`HST_CNT`变成14H，`HST_STS`变成了41H(说明！INTR并且`HOST_BUSY`)，`HST_D0`变为7FH(说明该寄存器保存第一个数据，并且这第一个数据也是后面的COUNT。)，`HOST_BLOCK_DB`在不停的闪动(说明该寄存器每被读取一次就变化一次，也就是E32B被置1的效果)。  


**`AUX_CTL`设置为00H**  

前面三步同上。 
 
* 第四步，将`HST_CNT`(02H)设置为54H，`HST_CNT`变成14H，`HST_STS`变成C1H（注意这里是C1H,即DS被置1），`HST_D0`变成1F，`HOST_BLOCK_DB`变成了08H（注意它并没有闪），本机的SPD数据序列为：7F,08,08,0E,…。这明显的说明`HST_D0`保存的是第一个数据，它也是count。  
* 第五步，将`HST_STS`设置为C1H（注意`HST_STS`的数据本来就是C1H,用这种方式清掉DS位，清掉之后发现`HST_STS`还是C1，没有变化，其实这一过程是有变化的，`HST_STS`先变成41，然后再变成C1，速度太快，看不到变化，在后面程序中用这一过程作为判断），发现`HST_D0`变为08H（这里还不能说是变化，值一样）。  
* 第六步，继续第五步，发现`HST_D0`变为0EH。接着重复，可以把这个Block缓存数据读取完。以什么作为结束标志呢？INTR和!`HOST_BUS`。另外也可以将KILL位（在`HST_CNT`中）置1，中断传输。这种方式下可以读取超过32个字节的数据，有多少就能读多少。  



## 3. 汇编代码验证过程 

由于代码不同于用RU软件测试，应为代码的执行过程是很快的，需要通过状态位精确地读取数据，而用RU进行设置时这些过程是看不到的，比如在block读取方式中，不采用32-byte buffer，需要通过HST_CNT中的DS位来遍历所有的数据，DS每置1清0一次，HOST_BLOCK_DB就会读取新的数据，那么什么时候读这个数据呢？是在DS由0再一次变为1的时候（当然也可以通过IODELAY，但究竟需要延时多久呢？）。而这一个过程在RU软件测试的时候是看不到的。所以代码需要更加关注标志的变化。  
   
### 3.1 Byte读取方式的代码过程 

像Byte数据的读取过程比较简单，仍然强调`HST_STS`的变化，如前面一段英文描述，命名是否成功结束可以用INTR位来得到，命名执行失败可以通过`HST_STS`&1CH是否为0来判断（也就是各种错误标志位）。

* 第一步：通过`HST_STS`判断SMBus是否空闲可用(`HST_STS`&1EH==0？不为0则1EH=>`HST_STS`。`HST_STS`&01H==0?不为0则循环)  
* 第二步：设置`XMIT_SLVA` (SMBA+04h), 选择设备地址，以及读写设为01h  
* 第三步：设置`HST_CMD`（SMBASE+03h),选择设备对应的Register Index  
* 第四步：设置`HST_CNT`（SMBASE+02h)，写48h表Byte Data形式读取  
* 第五步：循环判断`HST_STS`(`HST_STS`&1CH不为0则报错，`HOST_BUSY`应为0且INTR应为1否则循环)  
* 第六步：从`HST_D0`(SMBASE+05h)中读取数据  

### 3.2 Block读取方式 

这里需要说明的是block读取方式中`HST_D0`保存的既是smbus slave device的第一个数据，又是后续读取数据的count。由于测试的时候发现在将所以数据读取完毕之后，有时INTR会被置1，有时却不会被置1，所以保险起见，采用KILL直接中断该过程。  
另外前面说到block读取数据也会因E32B的设置而有所差异。若E32B为1，block data每读一次就会变化一次，该情况下一次只能读32个字节，若数据超过32个字节可以设置`HST_CMD`作为偏移，读取偏移处的32个字节。若E32B为0，block data读一次后需要将`HST_STS`中的DS置1清0，然后等待DS重新被硬置1时读下一次，如此持续可以读取超过32个字节的数据，直到读完。  
下面是E32B被置0时的读取过程。（注意：第一步以后的`HST_STS`的判断中都应加上对错误标志位的判断，若出错则KILL命令，报错）

* 第一步：通过`HST_STS`判断SMBus是否空闲可用(参考：`HST_STS`&9EH==0？不为0则`HST_STS`=>`HST_STS`。`HST_STS`&01H==0?)  
* 第二步：设置`XMIT_SLVA`（SMBASE+04h), 选择设备地址，以及读写设为01h  
* 第三步：设置`HST_CMD`(SMBASE+03h)为00H，index清0  
* 第四步：设置`AUX_CTL`(SMBASE+0DH)为00H，将E32B置0  
* 第五步：设置`HST_CNT`（SMBASE+02h)，写54H表Block Data形式读取  
* 第六步：判断`HST_STS`,循环直到DS(bit7)被置1  
* 第七步：`HST_D0`(SMBASE+05h)读取第一个数据，也将该数据作为后面总字节数  
* 第八步：`HOST_BLOCK_DB`(SMBASE+07h)中读取一个字节  
* 第九步：`HST_STS`的DS位置1清0  
* 第十步：循环判断`HST_STS`,直到DS(bit7)被置1，再重复第七步，直到读完所以字节数  
* 第十一步：设置HST_CNT为16H,KILL命令过程  
* 第十二步：用`HST_STS`的数据清掉`HST_STS`  

以上是E32B被置0的过程，当E32B被置1时，第四步改为设置`AUX_CTL`为02H，第五步先读取`HST_CNT`清buffer，再设置`HST_CNT`为54H，第六步改为IODELAY，第七到第十步的循环改为重复读取`HOST_BLOCK_DB`，直到31次。然后就进入第十一步。
