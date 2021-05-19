---
layout: single
title: Swift学习之函数与闭包
date: 2015-10-08 00:00
categories:
  - 编程
tags:
---

* content
{:toc}

## 函数的定义
关键字func，以sayHello(_:)函数为例，注意参数和返回值的写法

	func sayHello(personName: String) -> String {
	  let greeting = "Hello, " + personName + "!"
	  return greeting
	}

<!--more-->

参数和返回值都可以是元组

	func minMax(array: [Int]) -> (min: Int, max: Int) {
	  var currentMin = array[0]
	  var currentMax = array[0]
	  for value in array[1..<array.count] {
	    if value < currentMin {
	      currentMin = value
	    } else if value > currentMax {
	      currentMax = value
	    }
	  }
	  return (currentMin, currentMax)
	}
	let bounds = minMax([8, -6, 2, 109, 3, 71])
	print("min is \(bounds.min) and max is \(bounds.max)")
	// prints "min is -6 and max is 109"

## 函数的参数

1.通常第一个参数省略外部参数名，之后的参数使用外部参数名

	func someFunction(firstParameterName: Int, secondParameterName: Int) {
	  // function body goes here
	}
	someFunction(1, secondParameterName: 2)

2.参数也可以指定两个名词，前者为外部，后者为内部

	func sayHello(to person: String, and anotherPerson: String) -> String {
	  return "Hello \(person) and \(anotherPerson)!"
	}
	print(sayHello(to: "Bill", and: "Ted"))

3.用下划线忽略外部参数名

	func someFunction(firstParameterName: Int, _ secondParameterName: Int) {
	  // function body goes here
	}
	someFunction(1, 2)

4.指定默认参数值，带默认值参数尽量放在参数列表最后

	func someFunction(parameterWithDefault: Int = 12) {
	  // function body goes here
	}
	someFunction(6) // parameterWithDefault is 6
	someFunction() // parameterWithDefault is 12

5.可变参数，...表示，函数内部代表该类型的数组

	func arithmeticMean(numbers: Double...) -> Double {
	  var total: Double = 0
	  for number in numbers {
	    total += number
	  }
	  return total / Double(numbers.count)
	}
	arithmeticMean(1, 2, 3, 4, 5)
	// returns 3.0
	arithmeticMean(3, 8.25, 18.75)
	// returns 10.0

6.参数默认是常量参数，函数内部不可改变；可以在参数名前加var表示函数体内可变，变化后函数体外仍然是不变的

	func alignRight(var string: String, totalLength: Int, pad: Character) -> String {
	  let amountToPad = totalLength - string.characters.count
	  if amountToPad < 1 {return string}
	  let padString = String(pad)
	  for _ in 1...amountToPad {
	    string = padString + string
	  }
	  return string
	}
	let originalString = "hello"
	let paddedString = alignRight(originalString, totalLength: 10, pad: "-")
	// paddedString is equal to "-----hello"
	// originalString is still equal to "hello"

7.inout标示表示函数调用结束后参数值被改变，调用时参数加上&前缀，可以理解成c++的引用

	func swapTwoInts(inout a: Int, inout _ b: Int) {
	  let temporaryA = a;a = b;b = temporaryA
	}
	var someInt = 3
	var anotherInt = 107
	swapTwoInts(&someInt, &anotherInt)

## 函数类型

1.当看到->标志的类型，都是函数类型

	//函数类型为()->void
	func printHelloWorld() {
	  print("hello, world")
	}

	//函数类型为(Int,Int)->Int
	func addTwoInts(a: Int, _ b: Int) -> Int {
	  return a + b
	}

2.使用函数类型，接近于C语言的函数指针的意思

	//定义mathFunction的函数变量变量，指向addTwoInts函数
	var mathFunction: (Int, Int) -> Int = addTwoInts
	print("Result: \(mathFunction(2, 3))")
	// prints "Result: 5"
	//还可以赋值成其他同类型的函数类型
	mathFunction = multiplyTwoInts
	print("Result: \(mathFunction(2, 3))")
	//另外也适用类型推导
	let anotherMathFunction = addTwoInts

3.函数类型作为参数

	func printMathResult(mathFunction: (Int, Int) -> Int, _ a: Int, _ b: Int) {
	  print("Result: \(mathFunction(a, b))")
	}
	printMathResult(addTwoInts, 3, 5)

4.函数类型作为返回值

	func stepForward(input: Int) -> Int {
	  return input + 1
	}
	func stepBackward(input: Int) -> Int {
	  return input - 1
	}
	func chooseStepFunction(backwards: Bool) -> (Int) -> Int {
	  return backwards ? stepBackward : stepForward
	}

## 嵌套函数

可以理解成函数内部定义函数，仅函数内部使用。嵌套函数可以捕获外层函数的值，当作为返回值时，它是一个引用。

	func makeIncrementor(forIncrement amount: Int) -> ()->Int {
	  var runningTotal = 0
	  func incrementor() -> Int {
	    runningTotal += amount
	    return runningTotal
	  }
	  return incrementor
	}

	let incrementByTen = makeIncrementor(forIncrement: 10)
	incrementByTen() // 返回的值为10
	incrementByTen() // 返回的值为20
	incrementByTen() // 返回的值为30

	let incrementBySeven = makeIncrementor(forIncrement: 7)
	incrementBySeven() // 返回的值为7
	incrementByTen() // 返回的值为40

## 闭包
1.函数作为参数时可以用闭包代替，可以理解成Ruby语言中的块。闭包表达式如下：

	{ (parameters) -> returnType in
		statements
	}

比如按照函数参数传递如下：

	func backwards(s1: String, s2: String) -> Bool {
	  return s1 > s2
	}
	var reversed = names.sort(backwards)
	// reversed为["Ewa","Daniella","Chris","Barry","Alex"]

但是这样要定义一个函数，比较麻烦，改用闭包写法如下：

	reversed = names.sort({(s1:String,s2:String)->Bool in
	  return s1 > s2
	})

2.由于可以根据上下文推导函数参数的类型，所以可以省去函数类型，简写如下：

	reversed = names.sort( { s1, s2 in return s1 > s2 } )

3.单行表达式，可以隐藏return，进一步简写如下：

	reversed = names.sort( { s1, s2 in s1 > s2 } )

4.参数名称可以使用$0、$1缩写，进一步简写如下：

	reversed = names.sort( { $0 > $1 } )

5.运算符函数可以传入，将>作为函数，简写如下：

	reversed = names.sort(>)

6.当闭包作为最后一个参数时，可以改写如下：

	reversed = names.sort() { $0 > $1 }
	//当没有参数时()可以省略，再进一步简写如下：
	reversed = names.sort { $0 > $1 }

**个人看法：**尽管写法很多，但从简洁和易读两个角度来看，平时用4和6两种写法。