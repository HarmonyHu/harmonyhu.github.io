---
layout: single
title: Swift学习之基础类型
date: 2015-09-20 00:00
categories:
  - 编程
tags:
---

* content
{:toc}

### 整型-Int
Int与UInt，其中Int是默认且推荐类型，具体长度根据编译器决定
Int8与UInt8，Int16与UInt16，Int32与UInt32，Int64与UInt64

	17 //类型为Int
	UInt(17) //类型为UInt
	0b10001 //二进制，类型为Int
	0o21  //八进制，类型为Int
	0x11  //十六进制，类型为Int
	Int8.max //Int8类型属性max，最大值127
	Int8.min //Int8类型属性min，最小值-128

----------

<!--more-->

### 浮点数-Double

	125.0  //类型为Double
	Float(125.0)  //类型为Float
	1.25e2 //1.25x(10^2)，Double
	1.25e-2 //1.25x(10^-2)，Double

----------

### 布尔-Bool

**注意：**值为true和fasle，在if和while语句判断中只能传入Bool类型

----------

### 字符-Character

	let aChar:Character = "a"
	var bChar:Character = "\u{E9}"  //é
	//疑问1，如果let aChar = "a"，那么aChar是String类型?
	//疑问2，是否可写成let aChar = Character("a")

----------

### 字符串-String

**注意：**字符串是值类型，由于uniCode码,没有确切索引位置，需要具体属性方法来索引

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

----------

### 元组

1.多值复合，不要求同类型，用.0、.1访问元素

	let one = (1,"One")
	println("The code is \(one.0)") //访问元组，1
	println("The message is \(one.1)") //One

2.元组可以分解赋值，并且可以省略部分元组值

	let (oneNum,oneDesc) = one  //元组分解赋值
	let (oneNum,_) = one //用下划线忽略部分元组值

3.可以给元组元素命名，用名称访问

	let one2 = (num:1,desc:"One") //可以给元素命名
	println("\(one2.num) -> \(one2.desc)") //用元素名访问

**注意：**临时结构用元组，复杂结构或使用频繁的结构用结构体或类

----------

### 集合类型-Array

Array<T>，可以简写用[T]，T为具体类型，可理解成数组

	var someInts = [Int]() //Int空数组，=Array<Int>()
	someInts.append(3)  //方法append,插入3
	someInts = [] //空，此时不需要标注类型，可以推断
	var threeDoubles = [0.0,0.0,0.0]
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

----------

### 集合类型-Set

Set<T>，没有等价简写，无序不重复集合

	var letters = Set<Character>() //空Set
	letters.insert("a") //插入元素
	letters = [] //类型确定后，可以赋值空Set
	var letters:Set = ["a","b","c"]
	//复杂写法，var letters:Set<Character> = ["a","b","c"]
	letters.count //元素数量
	letters.isEmpty //是否为空
	letters.remove("b") //删除"b"，还有"a","c"
	letters.contains("b") //判断是否存在某元素，false
	letters.sort()  //按顺序排列

	for char in letters{...} //遍历

Set基本操作
![](https://harmonyhu.github.io/img/SetOperate.jpg)

----------

### 集合类型-Dictionary

Dictionary<key,Value>，可以理解成散列

	var namesOfInts = [Int:String]() //空字典
	nameOfInts[16] = "Sixteen" //插入或修改键值对
	nameOfInts = [:] //赋值成空字典
	var airports = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
	//完整写法var airports: [String: String] = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
	airports.count //数据项
	airports.isEmpty //判断是否空
	airports.updateValue(_:forkey:) //新增或修改，返回可选原值
	airports["DUB"] //返回可选值，如果不存在则为nil
	airports["DUB"]=nil //去掉"DUB"项
	airports.removeValueForKey(_:) //去掉某项，返回可选原值

	for (airportCode, airportName) in airports {//遍历
	  print("\(airportCode): \(airportName)")
	}

	airports.keys //keys数组
	airports.varlues //值数组