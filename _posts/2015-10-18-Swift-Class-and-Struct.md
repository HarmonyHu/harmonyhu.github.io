---
layout: post
title: Swift学习之类与结构体
date: 2015-10-18 00:00
categories: 技术类 Swift
---

* content
{:toc}


##定义

基本可以按照C++理解

	//成员可以没有默认值，常量成员只能初始化一次
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

##属性

基本按照C++理解，以下列举的都是一些特别的地方  
  
#####结构体有默认构造器  

	let vga = Resolution(width:640, height: 480)

#####类是引用类型  

	//alsoTenEighty与tenEighty是对同一实例的引用
	let tenEighty = VideoMode()
	let alsoTenEighty = tenEighty
	alsoTenEighty.frameRate = 30.0  
	//两者的frameRate都成了30.0
	//注意：虽然都是常量，但属性值可以修改。按照C语言中常量指针来理解。  

#####恒等运算===与!==

用于判断两个变量是否指向同一个引用，可以理解成C语言中的指针是否指向同一地址。

#####延迟属性lazy

	//importer只有再第一次被调用时才初始化创建
	class DataManager {
	    lazy var importer = DataImporter()
	    var data = [String]()
	    // 这是提供数据管理功能
	}
	//这里importer属性还没有被调用
	let manager = DataManager()

#####计算属性get与set  

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


#####属性观察器willSet与didSet  

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

#####类型属性static  
就按照C++中static成员的理解；既能用于普通存储属性，也能用于计算属性；调用就直接用class调用

##方法

基本按照C++理解，以及按照swift的函数理解。以下列举的都是一些特别的地方  

#####隐藏属性self  
等同于C++中的this指针，都是在属性与方法参数同名时很有用  

	class Counter {
	    var count: Int = 0
	    func increment() {self.count++}
	}

#####struct变异方法mutating  
**结构体**的属性不能在方法中被修改，如果要这样做，要加上mutating  

	//注意：结构体是值类型
	struct Point {
	    var x = 0.0, y = 0.0
	    mutating func moveByX(deltaX: Double, y deltaY: Double) {
	        self = Point(x: x + deltaX, y: y + deltaY)
	    }
	}

**枚举**的方法也是一样，在枚举的学习中列举出来

#####类型方法static与class  
和C++中的理解一样，但是结构体与枚举的关键字是static，类关键字是class  

	//注意类的类型方法关键字是class
	class SomeClass {
	    class func someTypeMethod() {//implementation goes here}
	}
	SomeClass.someTypeMethod()