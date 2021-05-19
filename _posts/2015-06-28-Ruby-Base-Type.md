---
layout: single
title:  Ruby基本数据类型
categories:
  - 编程
tags:
  - Ruby
---

* content
{:toc}

Ruby数据类型有：字符串、数字、数组、区间、散列、正则表达式。

## 数字

数字     |描述
--------:|:-----
`1_345`  |1345
`1e3`    |1000.0
`1.0e3`  |1000.0
`012`    |10(八进制)
`0x12`   |18(十六进制)
`0b11`   |3(二进制)
`2.to_s` |`"2"`

<!--more-->

## 字符串

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
`str.strip`      |去掉前尾空格
`str.strip!`     |str被修改
`str.chomp`      |str移除尾部换行
`str.chomp!`     |str被修改
`str.empty?`     |是否为空
`str.eql?(other)`|是否相等
`str.encoding`   |编码,比如UTF-8

* 单引号不转义，单引号内的单引号用`\'`表示

* 中文支持，需要开头添加`# -*- coding: UTF-8 -*-`或者`#encoding: utf-8`，且文件编码为utf-8
```ruby
#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
puts "你好" #你好
puts "abc".encoding #UTF-8
puts (/abc/).encoding #US-ASCII
puts (/abc/u).encoding #UTF-8
puts "用于中文测试".match(/[\u4e00-\u9fa5]+/) #用于中文测试
```

## 数组

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
`array.grep /regex/`       |匹配正则，返回数组
`array.each{ |item| block}`|遍历元素内容
`array.each_index{ |index| block }` |按Index遍历

## 区间

-----------------------------|-------------
`months = 1..12`             |闭区间[1,12]
`1...12`                     |开区间[1,12)
`months.each{|index| block}` |按区间内容遍历

## 散列

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
`myhash.has_value?("hu")`         |是否存在给定的值
`myhash.empty?`                   |是否空
`myhash.inspect`                  |散列的字符串形式
`myhash.each{|key,value| block}`  |传递key和value
`myhash.each_key{|key| block}`    |传递key
`myhash.each_value{|value| block}`|传递value
`myhash.sort`                     |按key值从小到大排序，返回副本，不会修改自身
`myhash.sort{|k1,k2| k1 <=> k2}`  |按key值从小到大排序，返回副本，不会修改自身


## 正则表达式

#### 1. 定义
`reg = /http:\/\//` *#能匹配http://*
`reg = %r(http://)` *#同上，不需要转义*
`var = "http://"; reg = /#{var}/`    *#支持变量，且不用转义*
规则参见[正则表达式快速参考](http://harmonyhu.com/2015/06/10/Perl-RegEx-Quick-Reference/)

#### 2. 匹配
* `=~` 如果匹配，返回匹配位置，否则返回nil
如：`">>http://www.baidu.com" =~ reg` *#返回2*
如：`">>www.baidu.com" =~ reg` *#返回nil*

* `!~` 如果匹配，返回false，否则返回true
如：`">>http://www.baidu.com" !~ reg` *#返回false*
如：`">>www.baidu.com" =~ reg` *#返回true*

* `str.match(regex)` 返回匹配的字符串;否则nil
如：`">>http://www.baidu.com".match(reg)` *#返回http://*
如：`">>www.baidu.com".match(reg)` *#返回nil*

* `str.scan(regex)` 返回所有匹配字符串以数组保存
如：`"I love my home".scan(/\w*o\w*/)` *#返回["love","home"]*
如：`"I love my home".scan(/family/)` *#返回[]*

* `str.scan(regex){...}` 块操作
如：`"I love my home".scan(/\w*o\w*/){print $&.upcase}` *#打印LOVEHOME*

#### 3. 替换
* `str.sub(regex,replace)` 替换第一个匹配，\1、\2...表示匹配的子字串
如：`"I love my home".sub(/home/,"family")` *#返回I love my family*

* `str.gsub(regex,replace)` 替换所有匹配
如：`"I love my home".gsub(/\b\w/,"I")` *#返回I Iove Iy Iome*

* sub和gsub都可以使用块操作，块内$&表示匹配字串，$1/$2/..表示匹配子字串
如：`"I love my home".gsub(/\b\w/){$&.upcase}` *#返回I Love My Home*

* sub!和gsub!表示变量本身也会因替换而改变