---
layout: post
title:  Ruby学习整理
date:   2015-06-30
categories: Ruby
tags: Ruby
---

* content
{:toc}

### 一、执行方式  
1. 单行执行：`ruby -e 'print "hello,world"'`  
2. 交互方式：`irb`;使用`exit`退出  
3. 文件方式：`ruby test.rb`  

-----

### 二、注释与变量名  
1. 用#表示单行注释  
2. 用=begin ... =end表示多行注释  
3. 全局变量用$前缀；实例变量用@前缀；类变量用@@前缀  
4. 类名、模块名用大写开头；常量全大写；其他都小写  

-----

### 三、数据类型  

数据类型有：字符串、数字、数组、区间、散列、正则表达式。正则表达式后文单独描述。  

#### 1. 数字

数字     |描述  
--------:|:-----
`1_345`  |1345
`1e3`    |1000.0
`1.0e3`  |1000.0
`012`    |10(八进制)
`0x12`   |18(十六进制)
`0b11`   |3(二进制)
`2.to_s` |`"2"`


#### 2. 字符串

字符串           |描述      
----------------:|:---------
`str=""`         |空字符串  
`"a"+"bc"`       |`"abc"`   
`"a"<<"bc"`      |`"abc"`   
`"a"<<0x30`      |`"a0"`   
`"ab"*3`         |`"ababab"`
`x=5;"x=#{x}"`   |`"x=5"`   
`x=5;"x=#{x*10}"`|`"x=50"` 
`x=5;'x=#{x}'`   |`"x=#{x}"` 
`65.chr`         |`"A"`     
`"A".ord`        |65        
`"0x%x"%65`      |`"0x41"`  
`"1234567[2]`    |`"3"` 
`"1234567[2,3]`  |`"345"` 
`"1234567[-1]`   |`"7"` 
`"123".to_i`     |123       
`"123".to_f`     |123.0     
`str.upcase`     |返回大写字符串
`str.upcase!`    |str被修改
`str.downcase`   |返回小写字符串
`str.downcase!`  |str被修改
`str.empty?`     |是否为空
`str.eql?(other) |是否相等

* 单引号不转义，单引号内的单引号用`\'`表示
* 如果要支持中文，需要开头添加`# -*- coding: UTF-8 -*-`或者`#coding=utf-8`，且文件编码为utf-8
```
#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
puts "你好"
```

#### 3. 数组

数组                       |描述
--------------------------:|:---------
`["OK",[1,2]]`             |可包含各类成员
`["f"]<<2`                 |`["f",2]`
`["f"]+[2]`                |`["f",2]`
`["f"]<<[2]`               |`["f",[2]]`
`array=[]`                 |空数组
`array=Array.new(20)`      |含20个空元素
`array=Array.new(20,"ab")` |含20个"ab"元素
`array.size`               |元素个数,length,count相同
`array.to_s`               |转换成字串
`array[0]`                 |第0个元素
`array.clear`              |清空数组
`array.delete("ab")`       |删除所有内容为"ab"的元素
`array.delete_at(2)`       |删除第2个元素(0开始)
`array.empty?`             |如果为空,返回true
`array.include?("ab")`     |如果包含"ab",返回true
`array.each{ |item| block}`|遍历元素内容
`array.each_index{ |index| block }` |按Index遍历

#### 4. 区间  

-----------------------------|-------------
`months = 1..12`             |闭区间[1,12]
`1...12`                     |开区间[1,12)
`months.each{|index| block}` |按区间内容遍历

#### 5. 散列  

----------------------------------|---------
`myhash={}`                       |定义空散列
`myhash={"name"=>"hu","age"=>25}` |key=>value 
`myhash["age"]`                   |25
`myhash["age"]=23`                |23
`myhash["weight"]=120`            |添加\"weight\"=>120
`myhash[:height]=1.7`             |添加:height=>1.7
`myhash.delete("weight")`         |去掉\"weight\"=>120
`myhash.keys`                     |[\"name\",\"age\",:height]
`myhash.key?("age")`              |yes

```ruby
#迭代器,打印散列  
myhash.each {|key,value| puts key.to_s+":"+value.to_s}    
#迭代器,散列排序  
hash={"0012"=>["Lily","Female",18],"0011"=>["Jack","Male",19]}  
#按工号从小到大排序  
hash.sort{|a,b| a[0] <=> b[0]}  
#按名字字符表排列
hash.sort{|a,b| a[1][0] <=> b[1][0]}
#按年龄从大到小排序  
hash.sort{|a,b| b[1][2] <=> a[1][2]}  
```

----

### 四、正则表达式  

#### 1.定义  
`reg = /http:\/\//` *#能匹配http://*  
`reg = %r(http://)` *#同上，不需要转义*  
规则参见[正则表达式快速参考](http://harmonyhu.com/2015/06/10/Perl-RegEx-Quick-Reference/)  

#### 2.匹配  
2.1  =~ 如果匹配，返回匹配位置，否则返回nil  
如：`">>http://www.baidu.com" =~ reg` *#返回2*  
如：`">>www.baidu.com" =~ reg` *#返回nil*  

2.2  !~ 如果匹配，返回false，否则返回true  
如：`">>http://www.baidu.com" !~ reg` *#返回false*  
如：`">>www.baidu.com" =~ reg` *#返回true*  

2.3 字符串.match(regex) 返回匹配的字符串;否则nil  
如：`">>http://www.baidu.com".match(reg)` *#返回http://*  
如：`">>www.baidu.com".match(reg)` *#返回nil*  

2.4 字符串.scan(regex) 返回所有匹配字符串以数组保存  
如：`"I love my home".scan(/\w*o\w*/)` *#返回["love","home"]*  
如：`"I love my home".scan(/family/)` *#返回[]*  

2.5 字符串.scan(regex){...} 块操作  
如：`"I love my home".scan(/\w*o\w*/){print $&.upcase}` *#打印LOVEHOME*  

#### 3.替换  
3.1 字符串.sub(regex,replace) 替换第一个匹配，\1、\2...表示匹配的子字串    
如：`"I love my home".sub(/home/,"family")` *#返回I love my family*  

3.2 字符串.gsub(regex,replace) 替换所有匹配  
如：`"I love my home".gsub(/\b\w/,"I")` *#返回I Iove Iy Iome*  

3.3 sub和gsub都可以使用块操作，块内$&表示匹配字串，$1/$2/..表示匹配子字串  
如：`"I love my home".gsub(/\b\w/){$&.upcase}` *#返回I Love My Home*  

3.4 sub!和gsub!表示变量本身也会因替换而改变  

----------

### 五、控制语句  

#### 1. 条件判断语句  
`if ... elsif ... else ... end`  
`(...)if...`  
`case ... when ... when ... else ...end`  
`unless = if not`  

#### 2. 循环控制语句  
`while...end`  
`(...) while ...`  
`until = while not`  
`for ... in ... end`  *#可以是区间、数组*  
break与next用于终止循环和直接下一次循环  

#### 3. 迭代器  
定义函数，部分实现用yield代替，执行时加入{}取代yield部分代码  
如：`3.upto(9){|i| print i}`  *#3456789*  
{}也可以改成do...end  

----------

### 六、方法

#### 1. 语法  
```ruby
def method_name [( [arg [= default]]...[, * arg [, &expr ]])]
   expr
end
```

#### 2. 返回值  

* 最后一个语句作为返回值
* return返回1个或多个值

#### 3. 举例

```ruby
def myinfo (name,height=1.7,weight=120)
	print "My name is #{name},height:#{height},weight:#{weight}"
end
myinfo "HarmonyHu",1.74
#My name is HarmonyHu,height:1.74,weight:120
```
	
----------

### 七、文件操作

#### 1. File操作

* **实例方法**

```ruby
#新建文件test.txt，r/r+/w/w+/a/a+
file = File.new("test.txt","w")
#打开文件test.txt
file = File.new("test.txt")
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
	
* **类方法**  

File.delete(filename)  #删除文件  
File.dirname(filename) #返回文件所在目录，字串  
File.extname(filename) #返回文件的扩展名，字串  
File.stat(filename)    #返回文件的信息，字串  
File.size(file.name)   #返回文件大小，数值  
File.exist?(filename)  #判断文件是否存在，布尔  
File.rename(oldname,newname) #文件重命名  
File.open(filename,atr){} #新建/打开文件，支持块操作  

```ruby
File.open("hello.txt","w"){|file|
	file.puts "hello,world"
}
#块结束自动关闭file
```

#### 2. Dir操作  

* **类方法**  

Dir.mkdir("MyDir")  #创建目录  
Dir.rmdir("MyDir")  #删除目录  
Dir[pat]            #返回文件名数组  
如：`Dir["foo.*"]` #["foo.c","foo.rb","foo.h"]  
如：`Dir["foo.?"]` #["foo.c","foo.h"]  

### 八、其他
#### 环境变量
`puts ENV["Path"]`  

```ruby
puts ENV["Path"]
#C:\ProgramData\Oracle\Java\javapath;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\system32\config\systemprofile\.dnx\bin;C:\Program Files\Microsoft DNX\Dnvm\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;D:\Program Files\TortoiseSVN\bin;d:\Program Files (x86)\010 Editor;D:\Program Files\TortoiseGit\bin;d:\Ruby24-x64\bin;C:\Users\HarmonyHu\AppData\Local\Microsoft\WindowsApps
```

#### 入参变量
`puts ARGV[0]` #第一个参数  
`puts ARGV[1]` #第二个参数
