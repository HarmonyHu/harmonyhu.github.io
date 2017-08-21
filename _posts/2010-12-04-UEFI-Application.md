---
layout: post
title:  UEFI Application入门
date:   2010-12-04
categories: BIOS
tags: BIOS UEFI
---
>本文最初是2010-11-18发表于[BiosRen论坛](http://www.biosren.com/thread-3515-1-1.html), 现在挪到本人自己的域名博客  

本文说明：关于UEFI Application编写及测试，论坛里的很多帖子及其回复都有说过，过程并不复杂，但是如果不知道的话可能也会像我一样折腾很久很久的时间。自然很多弟兄都已经轻车熟路了，写本文希望对不知道的弟兄做一个引导作用。我觉得先了解Application，再来学习UEFI是很有帮助的，可以写写小程序来亲身体会像Service或者Protocol的运作。小弟我还是一如既往的唠唠叨叨的写的很长，希望已经把关键地方都说明白了。
   
## 一.环境配置  

### 1．VS2008  
为避免一些奇怪的问题，切记完整安装，我的是安装的默认路径。
   
### 2．UDK    
下载完UDK(<http://sourceforge.net/projects/edk2/files/>)后，把它放在D:\MyWorkspace目录下面。安装Release Notes里面“HOW TO BUILD NT32”所说方法进行编译，步骤简单，我就翻译过来：  
第一步，打开VS2008命令行，进入D:\MyWorkspace。  
第二步，运行edksetup.bat。  
第三步，运行命令：build  -a IA32 -p Nt32pkg\nt32pkg.dsc。  
第四步，启动模拟器命令build run。（自然以后运行模拟器的时候就不用第三步了，我很唠叨，呵呵）  

看到的模拟器界面是如下：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/uefiapp1.JPG)  

其中fsnt0对应的目录是D:\MyWorkspace\Build\NT32\DEBUG_MYTOOLS\IA32，fsnt1对应的目录是D:\MyWorkspace\EdkShellBinPkg\Bin\Ia32\Apps。
      
### 3.EFI_Toolkit
下载`EFI_Toolkit`(<http://sourceforge.net/projects/efi-toolkit/files/>)后，我的是把它放在`D:\EFI_Toolkit_2.0`下面。然后就修改一下配置：
一是build.cmd里面`SDK_INSTALL_DIR=D:\EFI_Toolkit_2.0`，`SDK_BUILD_ENV=bios32`。
二是build\bios32\sdk.env里面将/Gs8192改为/GS-，然后为了以后方便修改`SDK_BIN_DIR`：`SDK_BIN_DIR=D:\MyWorkspace\Build\NT32\DEBUG_MYTOOLS\IA32\MyProject`，这样编译后的程序就到了这个目录下面，在UDK模拟器中对应的也就是fsnt0\MyProject。
可以编译`EFI_Toolkit`了，再翻译一下步骤：
第一步：打开VS2008命令行，进入`D:\EFI_Toolkit_2.0`  
第二步：运行build (或者build bios32)  
第三步：nmake  

这样就编译完成了，所有的efi程序都生成到指定的目录下面了，可以在模拟器上运行。
   
## 二.几个简单的Application例子

在`EFI_Toolkit_2.0\apps`下面建立目录hello，并在该目录下新建hello.c和hello.mak。  

hello.c程序如下：  

	#include <efi.h>      
	EFI_STATUS   
	HelloEntry(IN EFI_HANDLE ImageHandle,IN EFI_SYSTEM_TABLE *SystemTable){
	    UINTN Index;
	    SystemTable->ConOut->OutputString(SystemTable->ConOut,L"Hello,World!\r\n");
	    SystemTable->ConOut->OutputString(SystemTable->ConOut,L"Press any key to continue...");
	    SystemTable->BootServices->WaitForEvent(1,&(SystemTable->ConIn->WaitForKey),&Index);
	    return EFI_SUCCESS; 
	}      


hello.mak如下(除了红色字体部分，其余可以作为模板来理解)：  

	!include $(SDK_INSTALL_DIR)\build\$(SDK_BUILD_ENV)\sdk.env   
	BASE_NAME= hello  
	IMAGE_ENTRY_POINT = HelloEntry   
	TARGET_APP = $(BASE_NAME)   
	SOURCE_DIR = $(SDK_INSTALL_DIR)\apps\hello      
	BUILD_DIR= $(SDK_BUILD_DIR)\apps\$(BASE_NAME)    
	!include $(SDK_INSTALL_DIR)\include\$(EFI_INC_DIR)\makefile.hdr  
	INC = -I $(SDK_INSTALL_DIR)\include\$(EFI_INC_DIR) \   
	           -I $(SDK_INSTALL_DIR)\include\$(EFI_INC_DIR)\$(PROCESSOR) $(INC)  
	LIBS = $(LIBS) $(SDK_BUILD_DIR)\lib\libefi\libefi.lib    
	all : dirs $(LIBS) $(OBJECTS)     
	OBJECTS = $(OBJECTS) $(BUILD_DIR)\$(BASE_NAME).obj    
	$(BUILD_DIR)\$(BASE_NAME).obj : $(*B).c $(INC_DEPS)   
	!include $(SDK_INSTALL_DIR)\build\master.mak

VS2008命令行模式下进入`D:\EFI_Toolkit_2.0\`目录，运行build之后，进入`apps\hello`目录，执行命令`nmake –f hello.mak`。这样`hello.efi`就生成在指定目录了。  

再举个使用了efilib的例子(makefile文件模仿上面写):  

	//ShowTime.c   
	#include <efi.h>    
	#include <efilib.h>   
	EFI_STATUS     
	ShowTimeEntry(IN EFI_HANDLE ImageHandle,IN EFI_SYSTEM_TABLE *SystemTable)
	{
	    EFI_TIME time;   
	    EFI_RUNTIME_SERVICES * mRT=SystemTable->RuntimeServices;      
	    InitializeLib(ImageHandle,SystemTable);    
	    mRT->GetTime(&time,NULL);   
	    Print(L"%04d-%02d-%02d %02d:%02d:%02d",   \
	          time.Year,time.Month,time.Day,time.Hour,time.Minute,time.Second);          
	    return EFI_SUCCESS;      
	}
 

上面两个程序运行效果如下：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/uefiapp2.JPG)  
  
下面再举一个例子，用来说明参数ImageHandle的作用，正如这个名字，它用来反映程序的在Image上面的信息。Handle本身是没有任何意义的，它的意义在于通过它可以访问到挂接在它下面的各种Protocol实例。而这个ImageHandle是调用者（比如说Shell)在调用这个程序之前，检索程序Image信息时创建的，并传入给这个程序作为入口参数。这个程序就可以通过这个ImageHandle访问到自己的Image相关信息。（Image相当于存储设备上的文件）。下面的例子是通过ImageHandle获得当前程序的Image路径（差不多也就是文件路径了）。  

	#include <efi.h>      
	#include <efilib.h>     
	EFI_STATUS     
	TestEntry(IN EFI_HANDLE ImageHandle,IN EFI_SYSTEM_TABLE *SystemTable){  
	    EFI_LOADED_IMAGE *LoadedImage;  
	    EFI_DEVICE_PATH *DevicePath;  
	    EFI_STATUS Status;  
	    CHAR16 *DevicePathAsString;  
	    InitializeLib(ImageHandle,SystemTable);   
	    Status = BS->HandleProtocol (ImageHandle,&LoadedImageProtocol,&LoadedImage);  
	    if(EFI_ERROR(Status)){  
	        Print(L"Error Occur!");  
	        return EFI_SUCCESS;  
	    }  
	    Status = BS->HandleProtocol (LoadedImage->DeviceHandle,&DevicePathProtocol,&DevicePath);  
	    if(EFI_ERROR(Status)){  
	        Print(L"Error Occur!");  
	        return EFI_SUCCESS;  
	    }  
	    DevicePathAsString = DevicePathToStr(LoadedImage->FilePath);  
	    if (DevicePathAsString != NULL) {
	        Print (L"Image file : %s\n", DevicePathAsString);   
	        FreePool(DevicePathAsString);   
	    }   
	    return EFI_SUCCESS;   
	} 

上面程序运行效果图如下：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/uefiapp3.JPG)  
关于UEFI Application就说明到这里。

附：  
1.有些efi程序在模拟器中运行失败，可以尝试在U盘UEFI Shell下面运行。制作U盘UEFI Shell的方法在UDK的ReleaseNote中有介绍。  
2.发帖至今已经很久没有搞BIOS了，一些编译环境现在也没有了，弟兄们搭建环境过程中的各种问题我也没办法回答。所以有什么问题，可以发帖问问，总有人知道的。对不住了。
