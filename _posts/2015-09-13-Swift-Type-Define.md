---
layout: post
title: Swift学习之变量与常量的定义
date: 2015-09-13 00:00
categories: Swift
tags: Swift iOS
---

* content
{:toc}

## 变量常量定义  

	var today:Int = 5  
	let week:Int = 7  

1.var是变量关键字，today是变量名，Int是变量类型，5是初始值。  
2.let是常量关键字，所以week初始化后不能修改  
3.左值或者右值可以推导时类型可以省略，该句等价于`var today = 5`和`let week = 7`  
4.如果一条语句结尾换行则不用带上分号  
5.必须赋初值  


## 可选类型定义  
	
	var today:Int? = 5  //显式可选类型  
	var tomorrow:Int! = 6  //隐式可选类型

1.可选类型除了按类型赋值外，还可以为nil；如果定义时不赋初值，就为nil  
2.显示可选调用时要加!来强制解析，如果可选类型为nil，那么强制解析报错,如打印today和tomorrow如下:  

	println("\(today!)")  //如果today为nil，则报错  
	println("\(tomorrow)")  

3.可选类型使用场景如下：  
	
	let charNum = "123"  
	let number = charNum.toInt()  

这样number就被推导成`Int?`，上面的例子number为123,如果charNum为 `"12abc"`，则number为nil。

4.可选绑定，即在if和while中对可选类型赋给常量或变量，如下：  
	
	if let number = charNum.toInt(){
	  println("\(charNum) = \(number)")
	}else{
	  println("\(charNum) couldn't be converted!")
	}

**个人看法：**按理if和while只能接Bool类型，可选类型赋值时会返回Bool类型，成功赋值为True，赋值nil时为False。  

5.**关于可选类型存在意义的个人看法：**Swift创造可选类型，用?表示，可以不赋初值，其余类型都要赋初值；但是可选类型解析用!麻烦，所以折中又创造隐式可选类型，可以不赋初值，但使用时必须是有值的，否则就不要用隐式。  



