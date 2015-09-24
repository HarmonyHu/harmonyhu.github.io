---
layout: post
title: Swift学习之基础类型(未完)
date: 2015-09-20 00:00
categories: 技术类 Swift
---

* content
{:toc}

###整型  

> Int与UInt，其中Int是默认且推荐类型，具体长度根据编译器决定  
> Int8与UInt8，Int16与UInt16，Int32与UInt32，Int64与UInt64  
   
	17 //类型为Int  
	UInt(17) //类型为UInt  
	0b10001 //二进制，类型为Int  
	0o21  //八进制，类型为Int  
	0x11  //十六进制，类型为Int  
	Int8.max //Int8类型属性max，最大值127
	Int8.min //Int8类型属性min，最小值-128


###浮点数  

> 关键字：Double，默认类型； Float  
 
	125.0  //类型为Double  
	Float(125.0)  //类型为Float  
	1.25e2 //1.25x(10^2)，Double  
	1.25e-2 //1.25x(10^-2)，Double


###布尔

> 关键字Bool，值为true和fasle  
> if和while语句只能传入Bool类型  

###字符

>关键字Character,uniCode编码  

	let aChar:Character = "a"
	var bChar:Character = "\u{E9}"  //é
	//疑问1，如果let aChar = "a"，那么aChar是String类型?
	//疑问2，是否可写成let aChar = Character("a")
    
###字符串  

>关键字String，强调字符串是值类型  
>由于uniCode码,没有确切索引位置，需要具体属性方法来索引

	var empty = ""  //空字符串  
	var empty2 = String() //空字符串 
	empty.isEmpty  //属性isEmpty，是否为空字符串  
	var welcome = "hello"  
	welcome += ",world"  //此时welcome为"hello,world" 
	let char1:Character = "!"
	welcome += char1  //此时welcome为"hello,world!" 
	welcome.characters //疑问：暂且认为该属性为字符数组形式 
	welcome.characters.count //字符数量，12
	welcome[welcome.startIndex] //起始索引，"h"
	welcome[welcome.startIndex.successor()] //"e"
	welcome[advance(welcome.startIndex,5)] //","
	welcome[welcom.endIndex] //运行时错误
	welcome[welcome.endIndex.predecessor()] //末尾索引，"d"
	welcome.insert(_:atIndex:)  //指定索引插入字符  
	welcome.splice(_:atIndex:)  //指定索引插入字符串  
	welcome.removeAtIndex(_:)  //指定索引删除字符
	welcome.removeRange(_:)  //指定索引范围删除字符串
	"abc" == "ab"  //字符串比较，返回false
	"abc" != "ab"  //true
	let mul = 3
	let message = "\(mul) times 2.5 is \(Double(mul)*2.5)"
	//"3 times 2.5 is 7.5"

	for char in welcome.characters{...} //遍历各个字符
	

##元组  

	let one = (1,"One") //多值复合，不要求同类型
	println("The code is \(one.0)") //访问元组，1
	println("The message is \(one.1)") //One
	let (oneNum,oneDesc) = one  //元组分解赋值
	let (oneNum,_) = one //用下划线忽略部分元组值
	let one2 = (num:1,desc:"One") //可以给元素命名
	println("\(one2.num) -> \(one2.desc)") //用元素名访问

**注意：**临时结构用元组，复杂结构或使用频繁的结构用结构体或类

##集合类型-Array

关键字Array,简写用[]

	var someInts = [Int]() //Int空数组，var someInts=Array<Int>()  
	someInts.append(3)  //方法append,插入3  
	someInts = [] //空，此时不需要标注类型，可以推断  
	var threeDoubles = [0.0,0,0,0,0]  
	//等价于[Double](count:3,repeatedValue:0.0)
	var sixDoubles = threeDoubles + [2.5,2.5,2.5]
	//[0.0,0.0,0.0,2.5,2.5,2.5]
	var shopList = ["Eggs","Milk"]
	//等价于var shopList:[String] = ["Eggs","Milk"]
	shopList.count //属性count，数组数据项数量
	shopList.isEmpty //属性isEmpty，是否为空
	shopList[0]  //"Eggs"
	shopList[0] = "Six eggs"  //修改
	shopList.insert("Apple",atIndex:0) //在指定位置插入元素
	shopList.removeAtIndex(0) //移除指定位置元素

	for item in shopList{...} //数组元素遍历
	for (index,value) in shopList.enumerate(){...} //含索引遍历

##集合类型-Set

