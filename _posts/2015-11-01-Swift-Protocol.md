---
layout: post
title: Swift学习之协议protocol
date: 2015-11-01 00:00
categories: Swift
tags: Swift iOS
---

* content
{:toc}


## 定义

定义类、结构体、枚举类型必须实现的属性或方法，语法如下：

	protocol SomeProtocol {
	  // 协议内容
	}
	
	//遵从多种协议
	struct SomeStructure: FirstProtocol, AnotherProtocol {
	  // 结构体内容
	}

	//类可以继承父类且遵从多种协议
	class SomeClass: SomeSuperClass, FirstProtocol{
	// 类的内容
	}

## 协议属性

1.协议对属性只定义其只读或可读可写，以及是否实例属性或类属性(static)  
2.属性只读，则遵从者可以为可读可写或只读；属性可读可写，则遵从者必须可读可写  
3.遵从者实现属性时既可以是存储属性，也可以是计算属性

语法如下，

	//get表示可读，set表示可写,static表示类属性  
	protocol SomeProtocol {
	  var mustBeSettable : Int { get set }
	  static var doesNotNeedToBeSettable: Int { get }
	}

举例如下：

	protocol FullyNamed {
	  var fullName: String { get }
	}

	struct Person: FullyNamed{
	  var fullName: String
	}
	let john = Person(fullName: "John Appleseed")
	//john.fullName 为 "John Appleseed"

## 协议方法

可以定义实例方法或类方法(static),也可以定义mutating方法(枚举或结构体)


	protocol SomeProtocol {
	  func someTypeMethod()
	  static func anotherTypeMethod()
	  mutating func otherTypeMethod()
	}

举例如下：

	protocol RandGenerator {
	  func random() -> Double
	}
	class LinearCongruentialGenerator: RandGenerator {
	  var lastRandom = 42.0
	  func random() -> Double {
	    lastRandom = ((lastRandom * 12.0 + 7.0) % 21.0)
	    return lastRandom/21.0
	  }
	}

## 协议构造器

	protocol SomeProtocol {
	  init(someParameter: Int)
	}
	//类遵从者构造器必须加required，枚举和结构体不用
	//如果类是final class，也不用加required
	class SomeClass: SomeProtocol {
	  required init(someParameter: Int) {
	  }
	}

协议可以添加可失败构造器，则遵从者构造器都可以；  
如果不是可失败构造器，则遵从者必须是非可失败构造器或者init!

## 协议作为类型

协议可以作为类型，遵从者都可以作为该类型被调用。如下举例：

	class Dice {
	  let sides: Int
	  let generator: RandGenerator
	  init(sides: Int, generator: RandGenerator) {
	    self.sides = sides
	    self.generator = generator
	  }
	  func roll() -> Int {
	    return Int(generator.random() * Double(sides)) + 1
	  }
	}

表明一个遵从多个protocol的protocol类型：
`protocol<SomeProtocol,AnotherProtocol>`
	
	//举例
	protocol Named {
	  var name: String { get }
	}
	protocol Aged {
	  var age: Int { get }
	}
	func wishHappyBirthday(celebrator: protocol<Named, Aged>) {
	  print(" \(celebrator.name) - \(celebrator.age)!")
	}
	struct Person: Named, Aged {
	  var name: String
	  var age: Int
	}
	let birthdayPerson = Person(name: "Malcolm", age: 21)
	wishHappyBirthday(birthdayPerson)

## 集合中协议类型成员

1.集合中每个成员都遵从某协议。用法等同于继承同一父类的各种子类的集合。  
2.is用于协议一致性检查，as?返回可选，as用于强制转型。用法等同于类的类型转换。

## 协议可以继承

可以继承一个或多个协议：

	protocol InheritingProtocol: SomeProtocol, AnotherProtocol {
	  // 协议定义
	}

class关键字，表明遵从者必须是类，不能是结构体或枚举：

	protocol SomeClassOnlyProtocol: class, SomeInheritedProtocol {
	}
	
## 协议可选成员optional

表明遵从者可以不用实现该成员，调用时需要使用可选链调用。语法如下例子：

	@objc protocol CounterDataSource {
	  optional func incrementForCount(count: Int) -> Int
	  optional var fixedIncrement: Int { get }
	}

