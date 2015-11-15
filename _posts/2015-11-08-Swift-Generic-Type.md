---
layout: post
title: Swift学习之泛型
date: 2015-11-08 00:00
categories: 技术类 Swift
---

* content
{:toc}


##定义`<T>`

通过`<T>`表示通用类型，避免重复代码，可以按照C++泛型来理解。其中可以是T，或任何大写开头的命名。

##泛型函数

语法参考下例：

	func swapTwoValues<T>(inout a: T, inout _ b: T) {
	  let temporaryA = a
	  a = b
	  b = temporaryA
	}

	var someInt = 3
	var anotherInt = 107
	swapTwoValues(&someInt, &anotherInt)
	
	var someString = "hello"
	var anotherString = "world"
	swapTwoValues(&someString, &anotherString)

##泛型类型

语法如下例子：

	struct Stack<T> {
	  var items = [T]()
	  mutating func push(item: T) {
	    items.append(item)
	  }
	  mutating func pop() -> T {
	    return items.removeLast()
	  }
	}

	var stackOfStrings = Stack<String>()
	stackOfStrings.push("uno")

可以扩展泛型类型，仍然用T表示：

	extension Stack {
	  var topItem: T? {
	    return items.isEmpty?nil:items[items.count-1]
	  }
	}


##泛型约束

对泛型的类型进行一定的约束条件  

####类型遵循协议或继承类

语法：`<T: SomeClass, U: SomeProtocol>`  
使泛型遵循某协议或者继承某类，比如函数泛型：  

	func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U) {
	  // 这⾥是函数主体
	}

举例如下：

	//T必须遵从Equatable，即可以用==
	func findIndex<T: Equatable>(array: [T], _ valueToFind: T) -> Int? {
	  for (index, value) in array.enumerate() {
	    if value == valueToFind {
	      return index
	    }
	  }
	  return nil
	}

####where语句添加约束条件

	func allItemsMatch<
	C1: Container, C2: Container
	where C1.ItemType == C2.ItemType, C1.ItemType: Equatable>
	(someContainer: C1, anotherContainer: C2) -> Bool {
	  // 检查两个Container的元素个数是否相同
	  if someContainer.count != anotherContainer.count {
	    return false
	  }
	  // 检查两个Container相应位置的元素彼此是否相等
	  for i in 0..<someContainer.count {
	    if someContainer[i] != anotherContainer[i] {
	      return false
	    }
	  }
	  return true
	}


##协议定义关联类型typealias

用typealias在协议中定义一个关联类型，等同于泛型，如下例子：

	//协议中定义ItemType泛型
	protocol Container {
	  typealias ItemType
	  mutating func append(item: ItemType)
	  var count: Int { get }
	  subscript(i: Int) -> ItemType { get }
	}

	//Stack遵循协议Container
	struct Stack<T>: Container {
	  // original Stack<T> implementation
	  var items = [T]()
	  mutating func push(item: T) {
	    items.append(item)
	  }
	  mutating func pop() -> T {
	    return items.removeLast()
	  }
	  // conformance to the Container protocol
	  mutating func append(item: T) {
	    self.push(item)
	  }
	  var count: Int {
	    return items.count
	  }
	  subscript(i: Int) -> T {
	    return items[i]
	  }
	}

也可以通过扩展指定某类型遵循协议：

	//这样Array就可以当做Container使用
	extension Array: Container {}

