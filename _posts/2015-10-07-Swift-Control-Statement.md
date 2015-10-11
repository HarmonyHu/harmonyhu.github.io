---
layout: post
title: Swift学习之控制语句
date: 2015-10-07 00:00
categories: 技术类 Swift
---

* content
{:toc}

##for-in循环  
1.for-in循环可以遍历的对象：区间、数组（Array）、字典（Dictionary）、集合（Set）  

	for index in 1...5 {
	  println("\(index) times 5 is \(index * 5)")
	}

2.如果不需要每一项的值，可以用_替代  

	for _ in 1...5{
	  println("hello, five times")
	}

##for循环  
可以按照C语言理解，例子的index仅循环内有效，除非循环外定义。  

	for var index = 0; index < 3; ++index {
	  print("index is \(index)")
	}

##while循环
可以按照C语言理解  

	var index = 0;
	while index < 3 {
	  printf("index is \(index)");index++
	}

##repeat-while循环
可以按照C语言do-while循环理解  

	var index = 0;
	repeat{
	  printf("index is \(index)");index++
	}while index < 3

##if判断语句
可以按照C语言理解，更多判断用if...else if...else  

	var temperatureInFahrenheit = 30
	if temperatureInFahrenheit <= 32 {
	  print("It's very cold. Consider wearing a scarf.")
	}

##switch语句
1.类似C语言，switch...{case value1:...case value2:...default:...} ;不能贯穿，不同于C语言用break防止贯穿  ；case分支必须至少有一条语句，哪怕是break语句； case语句可以包含多个模式，用,隔开,如`case value1,value2:`。举例如下： 

	let anotherCharacter: Character = "a"
	switch anotherCharacter {
	case "a","A":
	  print("The letter A")
	default:
	  print("Not the letter A")
	}

2.case语句可以是区间  

	let approximateCount = 62
	switch approximateCount {
	case 0:
		println("no")
	case 1..<5:
		println("a few")
	case 5..<100:
		println("several")
	default:
		println("many")
	}

3.switch可以判断元组，且可以用_表默认   

	let point = (1, 1)
	switch point {
	case (0, 0):
	  print("(0, 0) is at the origin")
	case (_, 0):
	  print("(\(point.0), 0) is on the x-axis")
	case (0, _):
	  print("(0, \(point.1)) is on the y-axis")
	case (-2...2, -2...2):
	  print("(\(point.0),\(point.1)) is inside the box")
	default:
	  print("(\(point.0),\(point.1)) is outside of the box")
	}

4.可以用let只绑定  

	let anotherPoint = (2, 0)
	switch anotherPoint {
	case (let x, 0):
	  print("on the x-axis with an x value of \(x)")
	case (0, let y):
	  print("on the y-axis with a y value of \(y)")
	case let (x, y):
	  print("somewhere else at (\(x), \(y))")
	}

5.case语句可以接where进行额外判断  

	let yetAnotherPoint = (1, -1)
	switch yetAnotherPoint {
	case let (x, y) where x == y:
		print("(\(x),\(y)) is on x == y")
	case let (x, y) where x == -y:
		print("(\(x),\(y)) is on x == -y")
	case let (x, y):
		print("(\(x),\(y)) is some arbitrary point")
	}
	
##控制转移语句
1.continue和break按照C语言理解  
2.fallthrough用于switch中贯穿  
3.循环或switch前，可以用上标签，方便用continue和break明确继续或终止的循环对象  

	gameLoop: while square != finalSquare {
	  if ++diceRoll == 7 { diceRoll = 1 }
	  switch square + diceRoll {
	  case finalSquare:
	    // 到达最后⼀个⽅块，游戏结束
	    break gameLoop
	  case let newSquare where newSquare > finalSquare:
	    // 超出最后⼀个⽅块，再掷⼀次骰⼦
	    continue gameLoop
	  default:
	    // 本次移动有效
	    square += diceRoll
	    square += board[square]
	  }
	}
	print("Game over!")