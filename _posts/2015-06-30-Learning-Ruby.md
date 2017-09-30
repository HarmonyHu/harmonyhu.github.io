---
layout: post
title:  Ruby学习整理
date:   2015-06-30
categories: Ruby
tags: Ruby
---

* content
{:toc}

### 执行方式  
1. 单行执行：`ruby -e 'print "hello,world"'`  
2. 交互方式：`irb`;使用`exit`退出  
3. 文件方式：`ruby test.rb`  


-----

### 注释与变量名  
1. 用#表示单行注释  
2. 用=begin ... =end表示多行注释  
3. 全局变量用$前缀；实例变量用@前缀；类变量用@@前缀  
4. 类名、模块名用大写开头；常量全大写；其他都小写  

-----

### 控制语句  

1. 条件判断语句  
`if ... elsif ... else ... end`  
`(...)if...`  
`case ... when ... when ... else ...end`  
`unless = if not`  

2. 循环控制语句  
`while...end`  
`(...) while ...`  
`until = while not`  
`for ... in ... end`  *#可以是区间、数组*  
`break`: 跳出循环
`next`: 直接进入下一次循环
`redo`: 重新进入本次循环
`retry`: 重新从头开始循环 

3. 迭代器  
定义函数，部分实现用yield代替，执行时加入{}取代yield部分代码  
如：`3.upto(9){|i| print i}`  *#3456789*  
{}也可以改成do...end  

----------

### 方法

* 语法  
```ruby
def method_name [( [arg [= default]]...[, * arg [, &expr ]])]
   expr
end
```

* 返回值  
最后一个语句作为返回值；  
return返回1个或多个值;   
块内不能使用return  

* 举例
```ruby
def myinfo (name,height=1.7,weight=120)
	print "My name is #{name},height:#{height},weight:#{weight}"
end
myinfo "HarmonyHu",1.74
#My name is HarmonyHu,height:1.74,weight:120
```
	
----------

### 文件操作

#### File操作

* **实例方法**
```ruby
#新建文件test.txt，r/r+/w/w+/a/a+
file = File.new("test.txt","w")
#打开文件test.txt
file = File.new("test.txt")
#打开文件，用UTF-8编码
file = File.new("test.txt","r:utf-8")
#关闭文件
file.close

#写入数据puts
file.puts("hello,world")
#写入数据syswrite
file.syswrite("new line,hello,world2")

#读取文件一行内容
puts file.gets
puts file.readline
#读取文件若干字符
puts file.sysread(10)

#调整当前位置，回到文件头
file.rewind
#调整当前位置，指定位置
file.seek(10)
file.seek(-10,IO:SEEK_END)
file.seek(1,IO:SEEK_CUR)
#读取当前位置,tell与pos等同
puts file.tell
puts file.pos
#获取当前文件大小
puts file.size

#stat成员访问
puts file.stat.size
puts file.stat.ctime

#迭代器操作，字节操作
file.each_byte{|ch|
	putc ch
}
#迭代器操作，逐行操作
file.each{|line|
	puts line
}
```
	
* 类方法  
```ruby
File.delete(filename)  #删除文件  
File.dirname(filename) #返回文件所在目录，字串  
File.extname(filename) #返回文件的扩展名，字串  
File.stat(filename)    #返回文件的信息，字串  
File.size(file.name)   #返回文件大小，数值  
File.exist?(filename)  #判断文件是否存在，布尔  
File.rename(oldname,newname) #文件重命名  
File.open(filename,atr){} #新建/打开文件，支持块操作  

File.open("hello.txt","w"){|file|
	file.puts "hello,world"
}
#块结束自动关闭file
```

#### Dir操作  

* 类方法  
```ruby
Dir.mkdir("MyDir")  #创建目录MyDir  
Dir.rmdir("MyDir")  #删除目录MyDir

Dir[pat]            #返回文件名数组  
Dir["foo.*"] #["foo.c","foo.rb","foo.h"]  
Dir["foo.?"] #["foo.c","foo.h"]

Dir.foreach(foldername) { |filename|
#遍历目录fordername下的所有文件及文件夹（不包括子目录），包括.和..
	puts foldername+filename
}
```

### 其他

#### 环境变量
```ruby
#访问某个环境变量
puts ENV["Path"]
#C:\ProgramData\Oracle\Java\javapath;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\system32\config\systemprofile\.dnx\bin;C:\Program Files\Microsoft DNX\Dnvm\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;D:\Program Files\TortoiseSVN\bin;d:\Program Files 

#查看所有的环境变量
`puts ENV.inspect`

#Windows下常用的系统变量
%ALLUSERSPROFILE% 局部 返回所有“用户配置文件”的位置。
%APPDATA% 局部 返回默认情况下应用程序存储数据的位置。
%CD% 局部 返回当前目录字符串。
%CMDCMDLINE% 局部 返回用来启动当前的 Cmd.exe 的准确命令行。
%CMDEXTVERSION% 系统 返回当前的“命令处理程序扩展”的版本号。
%COMPUTERNAME% 系统 返回计算机的名称。
%COMSPEC% 系统 返回命令行解释器可执行程序的准确路径。
%DATE% 系统 返回当前日期。使用与 date /t 命令相同的格式。由 Cmd.exe 生成。有关 date 命令的详细信息，请参阅 Date。
%ERRORLEVEL% 系统 返回最近使用过的命令的错误代码。通常用非零值表示错误。
%HOMEDRIVE% 系统 返回连接到用户主目录的本地工作站驱动器号。基于主目录值的设置。用户主目录是在“本地用户和组”中指定的。
%HOMEPATH% 系统 返回用户主目录的完整路径。基于主目录值的设置。用户主目录是在“本地用户和组”中指定的。
%HOMESHARE% 系统 返回用户的共享主目录的网络路径。基于主目录值的设置。用户主目录是在“本地用户和组”中指定的。
%LOGONSEVER% 局部 返回验证当前登录会话的域控制器的名称。
%NUMBER_OF_PROCESSORS% 系统 指定安装在计算机上的处理器的数目。
%OS% 系统 返回操作系统的名称。Windows 2000 将操作系统显示为 Windows_NT。
%PATH% 系统 指定可执行文件的搜索路径。
%PATHEXT% 系统 返回操作系统认为可执行的文件扩展名的列表。
%PROCESSOR_ARCHITECTURE% 系统 返回处理器的芯片体系结构。值: x86，IA64。
%PROCESSOR_IDENTFIER% 系统 返回处理器说明。
%PROCESSOR_LEVEL% 系统 返回计算机上安装的处理器的型号。
%PROCESSOR_REVISION% 系统 返回处理器修订号的系统变量。
%PROMPT% 局部 返回当前解释程序的命令提示符设置。由 Cmd.exe 生成。
%RANDOM% 系统 返回 0 到 32767 之间的任意十进制数字。由 Cmd.exe 生成。
%SYSTEMDRIVE% 系统 返回包含 Windows XP 根目录（即系统根目录）的驱动器。
%SYSTEMROOT% 系统 返回 Windows XP 根目录的位置。
%TEMP% and %TMP% 系统和用户 返回对当前登录用户可用的应用程序所使用的默认临时目录。有些应用程序需要 TEMP，而其它应用程序则需要 TMP。
%TIME% 系统 返回当前时间。使用与 time /t 命令相同的格式。由 Cmd.exe 生成。有关 time 命令的详细信息，请参阅 Time。
%USERDOMAIN% 局部 返回包含用户帐户的域的名称。
%USERNAME% 局部 返回当前登录的用户的名称。
%UserProfile% 局部 返回当前用户的配置文件的位置。
%WINDIR% 系统 返回操作系统目录的位置。
```

#### 入参变量
`puts ARGV[0]` #第一个参数  
`puts ARGV[1]` #第二个参数

#### 执行命令
* 方式一
```ruby
file = "tmp.txt"
`rm -rf #{file}`
puts $? 
#结果保存在$?中，此处正常打印pid 10284 exit 0或者错误打印pid 10284 exit 1
```

* 方式二
```ruby
exec 'rm -rf tmp.txt'
#执行后会退出ruby进程
```

* 方式三
```ruby
file = "tmp.txt"
system "rm -rf #{file}"
puts $?
#同方式一
```
