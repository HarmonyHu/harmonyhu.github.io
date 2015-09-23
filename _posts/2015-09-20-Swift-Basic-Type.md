---
layout: post
title: Swift学习之基础类型(未完)
date: 2015-09-20 00:00
categories: 技术类 Swift
---

* content
{:toc}

##整型  

- Int与UInt，其中Int是默认且推荐类型，具体长度根据编译器决定  
- Int8与UInt8，Int16与UInt16，Int32与UInt32，Int64与UInt64  
  
----------  
	17 //类型为Int  
	UInt(17) //类型为UInt  
	0b10001 //二进制，类型为Int  
	0o21  //八进制，类型为Int  
	0x11  //十六进制，类型为Int  


##浮点数  

- Double，默认类型
- Float  

----------  
	125.0  //类型为Double  
	Float(125.0)  //类型为Float  
	1.25e2 //1.25x(10^2)，Double  
	1.25e-2 //1.25x(10^-2)，Double


##布尔

- 关键字Bool
- 值为true和fasle
- if和while语句只能传入Bool类型

##字符

- 关键字Character  
>

	let aChar:Character = "a"
	var bChar:Character = "b"
	//疑问1，如果let aChar = "a"，那么aChar是String类型?
	//疑问2，是否可写成let aChar = Character("a")
    

##元组  

