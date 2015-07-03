---
layout: post
title:  Ruby学习整理
date:   2015-06-30
categories: 技术类 Ruby
excerpt: Ruby学习整理
---

* content
{:toc}

##执行方式  
1. 单行执行：`ruby -e 'print "hello,world"'`  
2. 交互方式：`irb`;使用`exit`退出  
3. 文件方式：`ruby test.rb`

##注释与变量名  
用#表示单行注释  
用=begin ... =end表示多行注释  
全局变量用$前缀；实例变量用@前缀；类变量用@@前缀  
类名、模块名用大写开头；常量全大写；其他都小写  

##数据类型
1. **数字**  
1e3   => 1000  
1.0e3 => 1000.0  
012   => 10  
0x12  => 18  
0b11  => 3  

2. **数组**  
array = [] *#定义空数组*  
[2.4,"hello",[1,2]] *#可包含各类成员*  
array<<"f"<<2 *#array=["f",2]*  
array+=["f"]+[2] *#数组相加，["f",2]*  
array<<["f"]<<[2] *#注意与+的差别，[["f"],[2]]*  

3. **字符**  
str = "" *#定义空字符串*  
"a"+"bc" *#"abc"*  
"a"<<"bc" *#"abc"*  
"ab"*3 *#"ababab"*  
x=5;"x is #{x}" *#"x is 5"*  
65.chr *#"A"*  
"A".ord *#65*  
"0x%x"%65 *#"0x41"*  
"123".to_i *#123*  
 
4. **区间**  
1..5 =>[1,5]  
1...5 =>[1,5)

##控制语句
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

##正则表达式  
1. **数据类型**  
`reg = /http:\/\//` *#能匹配http://*  
`reg = %r(http://)` *#同上，不需要转义*  

2. **匹配**  
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

3. **替换**  
3.1 字符串.sub(regex) 替换第一个匹配  
如：`"I love my home".sub(/home/,"family")` *#返回I love my family*  
3.2 字符串.gsub(regex) 替换所有匹配  
如：`"I love my home".gsub(/\b\w/,"I")` *#返回I Iove Iy Iome*  
