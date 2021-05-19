---
layout: single
title: Swift学习之类与结构体
date: 2015-10-18 00:00
categories:
  - 编程
tags:
---

* content
{:toc}

## 定义

基本可以按照C++理解

	//成员必须有默认值，要么直接赋值，要么构建函数中赋初值；
	//常量成员只能初始化一次,同上
	struct Resolution {
	    var width = 0
	    var height = 0
	}
	class VideoMode {
	    var resolution = Resolution()
	    var interlaced = false
	    var frameRate = 0.0
	    var name: String?
	}
	let someResolution = Resolution()
	let someVideoMode = VideoMode()
	print("The width of someResolution is \(someResolution.width)")
	print("The width of someVideoMode is \(someVideoMode.resolution.width)")

<!--more-->

## 属性

基本按照C++理解，以下列举的都是一些特别的地方

#### 类是引用类型

	//alsoTenEighty与tenEighty是对同一实例的引用
	let tenEighty = VideoMode()
	let alsoTenEighty = tenEighty
	alsoTenEighty.frameRate = 30.0
	//两者的frameRate都成了30.0
	//注意：虽然都是常量，但属性值可以修改。按照C语言中常量指针来理解。

#### 恒等运算===与!==

用于判断两个变量是否指向同一个引用，可以理解成C语言中的指针是否指向同一地址。

#### 延迟属性lazy

	//importer只有再第一次被调用时才初始化创建
	class DataManager {
	    lazy var importer = DataImporter()
	    var data = [String]()
	    // 这是提供数据管理功能
	}
	//这里importer属性还没有被调用
	let manager = DataManager()

#### 计算属性get与set

计算属性没有存储；get需要return；set用newValue表示默认参数；计算属性必须是var；可以只定义get，表示只读计算属性，此时get{}可以去掉；普通存储变量也可以具备计算属性

	struct Point {
	    var x = 0.0, y = 0.0
	}
	struct Size {
	    var width = 0.0, height = 0.0
	}
	struct Rect {
	    var origin = Point()
	    var size = Size()
	    var center: Point {
	        get {
	            let centerX = origin.x + (size.width / 2)
	            let centerY = origin.y + (size.height / 2)
	            return Point(x: centerX, y: centerY)
	        }
	        set{
	            origin.x = newValue.x - (size.width / 2)
	            origin.y = newValue.y - (size.height / 2)
	        }
	    }
	}
	var square = Rect(origin: Point(x: 0.0, y: 0.0),
	size: Size(width: 10.0, height: 10.0))
	let initialSquareCenter = square.center
	square.center = Point(x: 15.0, y: 15.0)
	print("square.origin is now at (\(square.origin.x), \(square.origin.y))")
	// 输出 "square.origin is now at (10.0, 10.0)”


#### 属性观察器willSet与didSet

存储属性（除延时属性），可以添加属性观察器，分别在属性值变化前与后被调用，oldVaule在didSet中为默认参数；普通存储变量也可以定义属性观察器

	class StepCounter {
	    var totalSteps: Int = 0 {
	        willSet(newTotalSteps) {
	            print("About to set totalSteps to \(newTotalSteps)")
	        }
	        didSet {
	            if totalSteps > oldValue {
	                print("Added \(totalSteps - oldValue) steps")
	            }
	        }
	    }
	}

#### 类型属性static
就按照C++中static成员的理解；既能用于普通存储属性，也能用于计算属性；调用就直接用class调用

## 方法

基本按照C++理解，以及按照swift的函数理解。以下列举的都是一些特别的地方

#### 隐藏属性self
等同于C++中的this指针，都是在属性与方法参数同名时很有用

	class Counter {
	    var count: Int = 0
	    func increment() {self.count++}
	}

#### struct变异方法mutating
**结构体**的属性不能在方法中被修改，如果要这样做，要加上mutating

	//注意：结构体是值类型
	struct Point {
	    var x = 0.0, y = 0.0
	    mutating func moveByX(deltaX: Double, y deltaY: Double) {
	        self = Point(x: x + deltaX, y: y + deltaY)
	    }
	}

**枚举**的方法也是一样，在枚举的学习中列举出来

#### 类型方法static与class
和C++中的理解一样，但是结构体与枚举的关键字是static，类关键字是class

	//注意类的类型方法关键字是class
	class SomeClass {
	    class func someTypeMethod() {...}
	}
	SomeClass.someTypeMethod()

## 下标脚本subscript
访问数组、集合、列表、字典等等类型，用下表脚本来索引元素，可以理解成重载[]的方法。入参数量可以任意，类型也没有限制。以下是1个入参，Int类型的下标语法格式：

	//set中用newValue作为入参
	subscript(index: Int) -> Int {
	    get {// 返回与入参匹配的Int类型的值}
	    set {// 执行赋值操作}
	}

	//只读索引如下
	subscript(index: Int) -> Int {
	    // 返回与⼊参匹配的Int类型的值
	}

	struct TimesTable {
	    let multiplier: Int
	    subscript(index: Int) -> Int {
	        return multiplier * index
	    }
	}
	let threeTimesTable = TimesTable(multiplier: 3)
	print("3的6倍是\(threeTimesTable[6])")
	//输出"3的6倍是18"


## 类继承

只有类可以继承，其他（枚举、结构体）不能继承；子类继承父类的属性、方法、下标脚本；基本可以按照C++中继承概念理解，

	class SomeClass: SomeSuperclass {
	// 类的定义
	}

#### 重写override

可以重写方法、计算属性/观察器属性、下标脚本，关键字override；子类访问父类用super。

**1.重写方法**

	class Train: Vehicle {
	  override func makeNoise() {
	    print("Choo Choo")
	  }
	}

**2.重写计算属性getter/setter**

	class Car: Vehicle {
	  var gear = 1
	  override var description: String {
	    return super.description + " in gear \(gear)"
	  }
	}

**3.重写观察器属性didSet/willSet**

	class AutomaticCar: Car {
	  override var currentSpeed: Double {
	    didSet {
	      gear = Int(currentSpeed / 10.0) + 1
	    }
	  }
	}

**4.重写下标脚本subscript**

#### 防止重写final

在方法、属性、下标脚本前加上final，则不能重写；在class前加final，则该类不能继承。例如： final var , final func , final class func , 以及 final
subscript


## 可空链式调用?

	class Person {
	  var residence: Residence?
	}
	class Residence {
	  var numberOfRooms = 1
	}
	let john = Person()
	let roomCount = john.residence!.numberOfRooms

如上调用，当john.residence为nil时，用!强制展开会有运行时错误；可空链式调用作用就产生了，用?代替!表示可空链展开

**1.可空链调用属性**

	if let roomCount = john.residence?.numberOfRooms {
	  print("John's residence has \(roomCount) room(s).")
	}

虽然numberOfRooms为Int，但经过可空链后，得到的类型为Int?

对可空链最后赋值语法可行，但最终还是nil，如下：

	//赋值无效
	john.residence?.numberOfRooms = 2

**2.可空链调用方法**

上例反映的是可空链调用属性。下例中printNumberOfRooms返回Void，在可空链中就返回Void?

	if john.residence?.printNumberOfRooms() != nil {
	  print("It was possible to print the number of rooms.")
	}
	// prints "It was not possible to print the number of rooms."

**3.可空链调用下标**

	//访问可空链下标
	if let firstRoomName = john.residence?[0].name {
	  print("The first room name is \(firstRoomName).")
	}
	//赋值无效
	john.residence?[0] = Room(name: "Bathroom")

**4.可空链访问可空类型的下标**

	var testScores = ["Dave": [86, 82, 84], "Bev": [79, 94, 81]]
	testScores["Dave"]?[0] = 91
	//以下赋值无效
	testScores["Brian"]?[0] = 72

**5.多重可空链**

	if let johnsStreet = john.residence?.address?.street {
	  print("John's street name is \(johnsStreet).")
	}

	if let buildingIdentifier = john.residence?.address?.buildingIdentifier() {
	  print("John's building identifier is \(buildingIdentifier).")
	}