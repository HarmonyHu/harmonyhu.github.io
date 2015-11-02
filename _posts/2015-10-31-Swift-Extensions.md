---
layout: post
title: Swift学习之扩展extension
date: 2015-10-31 00:00
categories: 技术类 Swift
---

* content
{:toc}


##定义

向已有类、结构体、枚举类型、协议类型添加新功能，语法如下：

	extension SomeType {
	  // 加到SomeType的新功能
	}

##扩展计算型属性

	//给Double添加只读计算属性
	extension Double {
	  var m : Double { return self }
	  var mm: Double { return self / 1_000.0 }
	}
	let oneInch = 25.4.mm
	print("One inch is \(oneInch) meters")
	// 打印输出"One inch is 0.0254 meters"

##扩展构造器

该构造器等同于便利构造器,可以调用已有构造器(包括默认构造器、逐一构造器)

	struct Size {
	  var width = 0.0, height = 0.0
	}

	extension Rect {
	  init(width: Double, area: Double) {
	    self.init(width:width,height:(area/width))
	  }
	}

##扩展方法

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

##扩展下标

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

##扩展嵌套类型

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