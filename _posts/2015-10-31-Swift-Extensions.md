---
layout: post
title: Swift学习之扩展extension
date: 2015-10-31 00:00
categories: Swift
tags: Swift iOS
---

* content
{:toc}


## 定义

向已有类、结构体、枚举类型、协议类型添加新功能，语法如下：

	extension SomeType {
	  // 加到SomeType的新功能
	}

## 扩展计算型属性

	//给Double添加只读计算属性
	extension Double {
	  var m : Double { return self }
	  var mm: Double { return self / 1_000.0 }
	}
	let oneInch = 25.4.mm
	print("One inch is \(oneInch) meters")
	// 打印输出"One inch is 0.0254 meters"

## 扩展构造器

该构造器等同于便利构造器,可以调用已有构造器(包括默认构造器、逐一构造器)

	struct Size {
	  var width = 0.0, height = 0.0
	}

	extension Rect {
	  init(width: Double, area: Double) {
	    self.init(width:width,height:(area/width))
	  }
	}

## 扩展方法

可以扩展实例方法或者类型方法，如下举例：

	//扩展Int方法，参数为没有参数和返回值的函数
	extension Int {
	  func repetitions(task: () -> ()) {
	    for i in 0..<self {task()}
	  }
	}
	3.repetitions{print("Hello!")}
	// Hello!
	// Hello!
	// Hello!

也可以修改值类型本身，需要加mutating前缀：
	
	extension Int {
	  mutating func square() {
	    self = self * self
	  }
	}
	var someInt = 3
	someInt.square()
	// someInt 现在值是 9

## 扩展下标

	extension Int {
	  subscript(var digitIndex: Int) -> Int {
	    var decimalBase = 1
	    while digitIndex > 0 {
	      decimalBase *= 10
	      --digitIndex
	    }
	    return (self / decimalBase) % 10
	  }
	}
	746381295[0]
	// returns 5
	746381295[1]
	// returns 9
	746381295[9]
	//returns 0

## 扩展嵌套类型

	extension Int {
	  enum Kind {
	    case Negative, Zero, Positive
	  }
	  var kind: Kind {
	    switch self {
	    case 0:
	      return .Zero
	    case let x where x > 0:
	      return .Positive
	    default:
	      return .Negative
	    }
	  }
	}

## 扩展协议

#### 扩展协议类型

	protocol TextRepresentable {
	  func asText() -> String
	}
	
	//给已有类型增加协议，且实现遵从的所有属性方法
	extension Int:TextRepresentable {
	  func asText() -> String {
	    return "\(self)"
	  }
	}

#### 扩展补充协议声明

表明某类、结构体、枚举符合某协议，如下举例：

	struct Hamster {
	  var name: String
	  func asText() -> String {
	    return "A hamster named \(name)"
	  }
	}
	extension Hamster: TextRepresentable {}
	//这样Hamster可以作为TextRepresentable调用

#### 扩展协议本身
可以扩展协议的方法和属性，使所有遵从者都具有该方法和属性，不用都实现一遍。如下举例

	//所有该协议的遵从者都具备了randomBool方法
	extension RandomNumberGenerator {
	  func randomBool() -> Bool {
	    return random() > 0.5
	  }
	}

通过放方法也可以为协议提供默认实现，如果遵从者也实现了，则以遵从者的实现为准。

#### 为协议扩展添加限制条件where
只有满足条件的遵从者才能获得扩展的属性或者方法

	extension CollectionType where Generator.Element : TextRepresentable {
	  func asList() -> String {
	    return "(" + ", ".join(map({$0.asText()})) + ")"
	  }
	}

