---
layout: single
title: Swift学习之枚举
date: 2015-10-11 00:00
categories:
  - 编程
tags:
  - Swift
---

* content
{:toc}

## 定义与调用

枚举概念类似C语言，语法不同，而且可以不用定义类型（C语言为int型），举例如下：

	enum CompassPoint {
	  case North
	  case South
	  case East
	  case West
	}

<!--more-->

也可以定义成一行，用,隔开：

	enum CompassPoint {
	  case North,South,East,West
	}

调用方法如下：

	var directionToHead = CompassPoint.West
	//后面赋值时CompassPoint可以省略
	directionToHead = .East

	//可以放在switch中进行匹配
	switch directionToHead {
	case .East:
	  print("Direction East")
	default:
	  print("Not East Direction")
	}
	//输出"Direction East"

## 原始值(Raw Values)

1.枚举类型也可以指定原始类型，如下例子：

	//原始值类型为Character
	enum ASCIIControlCharacter: Character {
	  case Tab = "\t"
	  case LineFeed = "\n"
	  case CarriageReturn = "\r"
	}

	let tabChar = ASCIIControlCharacter.Tab.rawValue
	//此时tabChar="\t"

2.当原始值类型是整型或者String时，存在隐式赋值；
整型第一个原始值默认为0，后续值默认依次增1；

	enum CompassPoint:Int{
	  case North=1,South,East,West
	}
	let sunsetDirection = CompassPoint.West.rawValue
	// sunsetDirection 值为 4

String默认原始值为对应成员的名称：

	enum CompassPointS: String {
	  case North, South, East, West
	}
	let sunsetDirection = CompassPointS.West.rawValue
	// sunsetDirection 值为 "West"

3.原始值初始化枚举变量，该变量为可选值，如下例中的`CompassPoint(rawValue: 2)`：

	if let somePoint = CompassPoint(rawValue: 2) {
	  switch somePlanet {
	  case .East:
	    print("Direction East")
	  default:
	    print("Not Direction East")
	  }
	} else {
	  print("There isn't a correct direction")
	}
	// 输出 "Not Direction East"

## 相关值(Associated Values)

可以理解成枚举类型有额外的属性，如下举例

	//商品有数字码和字串码，数字码UPCA附加4个数值，字串码QRCode附加1个字串
	enum Barcode {
	  case UPCA(Int, Int, Int, Int)
	  case QRCode(String)
	}

	//注意赋值顺序，UPCA和QRCode只存其一
	var productBarcode = Barcode.UPCA(8, 85909, 51226, 3)
	productBarcode = .QRCode("ABCDEFGHIJKLMNOP")
	switch productBarcode {
	case .UPCA(let numberSystem, let manufacturer, let product, let check):
	  print("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
	case .QRCode(let productCode):
	  print("QR code: \(productCode).")
	}
	// 输出 "QR code: ABCDEFGHIJKLMNOP."

当所有相关值提取成变量或常量，可以整体提取，上例第一个case可以简写如下：

	case let .UPCA(numberSystem, manufacturer, product, check)

## 递归枚举(Recursive Enumerations)

可以理解成相关值得扩展，相关值类型不确定，根据实际传入值而定，这样就可以方便扩展，如下：

	//Addition和Multiplication中的两个相关值不是类型
	enum ArithmeticExpression {
	  case Number(Int)
	  indirect case Addition(ArithmeticExpression, ArithmeticExpression)
	  indirect case Multiplication(ArithmeticExpression, ArithmeticExpression)
	}

	//由于不确定类型，下面left和right可以是任意支持+和*运算的类型
	func evaluate(expression: ArithmeticExpression) -> Int {
	  switch expression {
	  case .Number(let value):
	    return value
	  case .Addition(let left, let right):
	    return evaluate(left) + evaluate(right)
	  case .Multiplication(let left, let right):
	    return evaluate(left) * evaluate(right)
	  }
	}

	// 计算 (5 + 4) * 2
	let five = ArithmeticExpression.Number(5)
	let four = ArithmeticExpression.Number(4)
	let sum = ArithmeticExpression.Addition(five, four)
	let product = ArithmeticExpression.Multiplication(sum, ArithmeticExpression.Number(2))
	print(evaluate(product))
	// 输出 "18"

**个人看法：**递归枚举有点泛型的味道，但是极难理解和使用，不建议写这样的语句编程。

## 定义方法

具体方法与结构体中的方法概念相同，以下举例：

	enum TriStateSwitch {
	  case Off, Low, High
	  mutating func next() {
	    switch self {
	    case Off:
	      self = Low
	    case Low:
	      self = High
	    case High:
	      self = Off
	    }
	  }
	}
	var ovenLight = TriStateSwitch.Low
	ovenLight.next()
	// ovenLight 现在等于 .High
	ovenLight.next()
	// ovenLight 现在等于 .Off