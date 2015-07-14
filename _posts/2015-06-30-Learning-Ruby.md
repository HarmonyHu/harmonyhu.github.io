---
layout: post
title:  Ruby学习整理
date:   2015-06-30
categories: 技术类 Ruby
excerpt: Ruby学习整理
---

* content
{:toc}

###一、执行方式  
1. 单行执行：`ruby -e 'print "hello,world"'`  
2. 交互方式：`irb`;使用`exit`退出  
3. 文件方式：`ruby test.rb`  

-----

###二、注释与变量名  
1. 用#表示单行注释  
2. 用=begin ... =end表示多行注释  
3. 全局变量用$前缀；实例变量用@前缀；类变量用@@前缀  
4. 类名、模块名用大写开头；常量全大写；其他都小写  

-----

###三、数据类型  

>数据类型有：字符串、数字、数组、区间、散列、正则表达式。正则表达式后文单独描述。  

####1. 常见类型 

字符串        |描述    |数字   |描述  |数组                  |描述
-------------:|:-------|------:|:-----|---------------------:|:---
`str=""`      |空字符串|`1e3`  |1000  |`array=[]`            |空数组
`"a"+"bc"`    |"abc"   |`1.0e3`|1000.0|`["OK",[1,2]]`        |可包含各类成员
`"a"<<"bc"`   |"abc"   |`012`  |10    |`"f"<<2`              |["f",2]
`"ab"*3`      |"ababab"|`0x12` |18    |`["f"]+[2]`           |["f",2]
`x=5;"x=#{x}"`|"x=5"   |`0b11` |3     |`["f"]<<[2]`          |[["f"],[2]]
`65.chr`      |"A"     |
`"A".ord`     |65      |
`"0x%x"%65`   |"0x41"  |
`"123".to_i`  |123     |

####2. 区间  

-----------------|-------------
`months = 1..12` |闭区间[1,12]
`1...12`         |开区间[1,12)


{:.lang-rb}
	#打印123456789101112
	months.each{|month|
	    print month
	}


####3. 散列  

----------------------------------|---------
`myhash={}`                       |定义空散列
`myhash={"name"=>"hu","age"=>25}` |key=>value 
`myhash["age"]`                   |25
`myhash["age"]=23`                |23
`myhash["weight"]=120`            |添加"weight"=>120
`myhash[:height]=1.7`             |添加:height=>1.7
`myhash.delete("weight")`         |去掉"weight"=>120
`myhash.keys`                     |["name","age",:height]

{:.lang-rb}
	#迭代器  
	myhash.each {|key,value|  
	    puts key.to_s+":"+value.to_s  
	}  

----

###四、正则表达式  

####1.定义  
`reg = /http:\/\//` *#能匹配http://*  
`reg = %r(http://)` *#同上，不需要转义*  
规则参见[正则表达式快速参考](http://harmonyhu.com/2015/06/10/Perl-RegEx-Quick-Reference/)  

####2.匹配  
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

####3.替换  
3.1 字符串.sub(regex,replace) 替换第一个匹配  
如：`"I love my home".sub(/home/,"family")` *#返回I love my family*  
3.2 字符串.gsub(regex,replace) 替换所有匹配  
如：`"I love my home".gsub(/\b\w/,"I")` *#返回I Iove Iy Iome*  

>sub!和gsub!表示变量本身也会因替换而改变  


###五、控制语句
1. **条件判断语句**  
if ... elsif ... else ... end  
(...)if...  
case ... when ... when ... else ...end  
unless = if not  

2. **循环控制语句**  
while...end  
(...) while ...  
until = while not  
for ... in ... end  *#可以是区间、数组*  
break与next用于终止循环和直接下一次循环  

3. **迭代器**  
定义函数，部分实现用yield代替，执行时加入{}取代yield部分代码  
如：`3.upto(9){|i| print i}`  *#3456789*  
{}也可以改成do...end  
