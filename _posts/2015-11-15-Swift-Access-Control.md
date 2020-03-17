---
layout: post
title: Swift学习之访问控制
date: 2015-11-15 00:00
categories: 编程
tags: Swift 编程
---

* content
{:toc}

## 语法

	public class SomePublicClass {}
	internal class SomeInternalClass {}
	private class SomePrivateClass {}
	public var somePublicVariable = 0
	internal let someInternalConstant = 0
	private func somePrivateFunction() {}
	
	public class SomePublicClass { // 显式的 public 类
	  public var somePublicProperty = 0 // 显式的 public 类成员
	  var someInternalProperty = 0 // 隐式的 internal 类成员
	  private func somePrivateMethod() {} // 显式的 private 类成员
	}
	class SomeInternalClass { // 隐式的 internal 类
	  var someInternalProperty = 0 // 隐式的 internal 类成员
	  private func somePrivateMethod() {} // 显式的 private 类成员
	}
	private class SomePrivateClass { // 显式的 private 类
	  var somePrivateProperty = 0 // 隐式的 private 类成员
	  func somePrivateMethod() {} // 隐式的 private 类成员
	}

<!--more-->

#### 要点1：只针对模块和源文件  
模块： Framework或者Application，用import引入，类似C++中lib  
源文件：代码文件，类似C++中.cpp文件  

#### 要点2：三个级别  
public: 可以被内部源文件或者被其他模块调用，级别最高  
internal: 可以被内部源文件调用，不能被其他模块调用，**默认级别**    
private: 只能被所在源文件调用，级别最低

#### 要点3：统一性原则  
例1：变量类型是private或internal，则变量类型不能是public  
例2：函数参数是private或internal，则函数本身不能是public  
**个人看法：**总体来说就是不能通过高级别的实体访问到低级别的实体；反之是可以的。而实际开发过程中不用太在意这个原则，比如例1，如果程序员定义了一个private的类型，不大可能会将该类型的变量开放给其他模块或其他源文件调用，本身逻辑上就是行不通的。  

#### 要点4：单元测试的访问级别  
外部只能调用模块的public接口，这样单元测试模块就无法访问其他接口，这时接口需要使用@testable注解，测试模块用该方式编译

#### 要点5：private(set)或internal(set)
可以定义属性的set级别低于get级别，也就是外部可以读不能写，内部才能读写。包括计算属性和存储属性。如下：

	//定义TrackedString的源文件
	struct TrackedString {
	  private(set) var numberOfEdits = 0
	  var value: String = "" {
	    didSet {
	      numberOfEdits++
	    }
	  }
	}
	
	//另一个源文件调用
	var stringToEdit = TrackedString()
	stringToEdit.value = "This string will be tracked."
	print("The number is \(stringToEdit.numberOfEdits)")

## 类型单独说明

访问级别可以控制变量、函数、类型、成员、嵌套类型等等；private类的成员都是private，public和internal成员默认是internal，且可以定义为更低级别。

#### 元组类型 
以元组中最低级别为控制级别  

#### 函数类型
默认为internal，以参数级别、返回级别中最低级别为参照，不能高于该级别。如下例就必须显示声明函数为private，不能为默认internal。

	private func someFunction() -> (SomeInternalClass, SomePrivateClass) {
	  // function implementation goes here
	}

#### 枚举类型
枚举成员与枚举级别一致，不需要声明级别；枚举类型的级别不能高于原始值或关联值的级别。

#### 子类继承
子类级别不得高于父类级别；子类可以重写父类访问级别，如下例：

	public class A {
	  private func someMethod() {}
	}
	internal class B: A {
	  override internal func someMethod() {
	    super.someMethod()
	  }
	}

#### 协议
1.  协议的成员与协议级别一致，比如协议是public，则它的函数成员也是public，这一点与其他类型不同  
2.  协议继承也不得高于父类协议  
3.  遵从协议的类的访问级别，取两者中最低级别，类的成员也必须不高于该级别  

#### 扩展
扩展保持与被扩展者一致的级别（**注：暂时没看懂**）

#### 泛型
泛型类型或泛型函数的访问级别，取决于函数、泛型类型中最低级别

#### 类型别名
别名类型不得高于原类型的访问级别