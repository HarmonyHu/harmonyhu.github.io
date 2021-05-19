---
layout: single
title: Swift学习之类的构造和析构
date: 2015-10-25 00:00
categories:
  - 编程
tags:
---

* content
{:toc}

## 构造函数init
class、struct、enum都可以有构造函数

----------

#### 基本可以按照C++理解
init可以有多个参数，或无参数；

	init() {
	    // 在此处执⾏构造过程
	}


举例如下：

	struct Fahrenheit {
	    var temperature: Double
	    init() {
	        temperature = 32.0
	    }
	}
	var f = Fahrenheit()

----------

<!--more-->

#### 默认构造器
**基类或结构体**所有存储属性已有默认值且没有定义构造器，则有默认构造器

	//以上写法等同，不实现init()，则会默认存在该构造器
	struct Fahrenheit {
	    var temperature = 32.0
	}
	var f = Fahrenheit()

----------

#### 结构体逐一成员构造器
**结构体**如果自定义了构造器，则没有该逐一成员构造器

	let g = Fahrenheit(temperature:10.0)

----------

#### 结构体构造器内部可以互相调用

	init(){
	    self.init(...)
	}

----------

#### 类指定构造器与便利构造器convenience

类的普通构造器成为指定构造器；convenience关键字表便利构造器。
1.指定构造器只能调用**父类**的指定构造器，便利构造器只能调用**本类**的构造器
2.如不是基类，指定构造器 **必须初始化完** 本类新引入的存储属性，且之后 **必须调用** 父类的指定构造器
3.便利构造器 **必须调用** 同类其他构造器，并以调用指定构造器结束

----------

#### 类构造器继承规则
1.子类默认不继承父类构造器，如果子类要实现与父类相同的构造器，则需要override重载构造器
2.如果子类没有定义任何指定构造器，则它将继承所有父类指定构造器
3.如果子类实现了所有父类的指定构造器（包括继承的指定构造器），则父类便利构造器将自动继承到子类


	//*************基类Food**************
	//如下init调用init(name:),需要声明convenience
	class Food {
	    var name: String
	    init(name: String) {
	        self.name = name
	    }
	    convenience init() {
	        self.init(name: "[Unnamed]")
	    }
	}

	let namedMeat = Food(name: "Bacon")
	// namedMeat 的名字是 "Bacon"
	let mysteryMeat = Food()
	// mysteryMeat 的名字是 [Unnamed]

	//**********子类RecipeIngredient*************
	//子类可以调用父类的指定构造器,但不能调用父类便利构造器
	//注意：由于RecipeIngredient实现了父类指定构造器init(name: String,所以父类便利构造器init()被自动继承
	class RecipeIngredient: Food {
	    var quantity: Int
	    init(name: String, quantity: Int) {
	        self.quantity = quantity
	        super.init(name: name)
	    }
	    override convenience init(name: String) {
	        self.init(name: name, quantity: 1)
	    }
	}
	let oneMysteryItem = RecipeIngredient()
	let oneBacon = RecipeIngredient(name: "Bacon")
	let sixEggs = RecipeIngredient(name: "Eggs", quantity: 6)

	//***********ShoppingListItem*************
	//注意：该类没有任何指定构造器，所以继承所有父类构造器
	class ShoppingListItem: RecipeIngredient {
	    var purchased = false
	    var description: String {
	        var output = "\(quantity) x \(name.lowercaseString)"
	        output += purchased ? " ✔" : " ✘"
	        return output
	    }
	}

----------

#### 必要构造器required
修饰符required表明所有子类必须实现该构造器，且都要加上required

	class SomeClass {
	    required init() {...}
	}

	class SomeSubclass: SomeClass {
	    required init() {...}
	}

----------

#### 闭包或全局函数设置属性默认值
注意：闭包初始化属性时，实例其他部分还没有初始化

	class SomeClass {
	    let someProperty: SomeType = {
	        // 在这个闭包中给 someProperty 创建⼀个默认值
	        // someValue 必须和 SomeType 类型相同
	        return someValue
	        }()
	}

----------

#### 参数外部名称与内部名称

没有默认外部名称，如果不写外部名称，这该名称即坐外部名称也做内部名称。用_可以定义不带外部名称的参数。

	struct Celsius {
	    var temperatureInCelsius: Double = 0.0
	    init(fromFahrenheit fahrenheit: Double) {
	        temperatureInCelsius = (fahrenheit-32.0)/1.8
	    }
	    init(fromKelvin kelvin: Double) {
	        temperatureInCelsius = kelvin - 273.15
	    }
	    init(_ celsius: Double){
	        temperatureInCelsius = celsius
	    }
	}
	let bodyTemperature = Celsius(37.0)
	//bodyTemperature.temperatureInCelsius 为 37.0

----------

#### 可失败构造器init?
类、结构体、枚举，构造函数失败时return nil

**1.结构体与枚举可失败构造器**

	struct Animal {
	    let species: String
	    init?(species: String) {
	        if species.isEmpty { return nil }
	        self.species = species
	    }
	}

	enum TemperatureUnit {
	    case Kelvin, Celsius, Fahrenheit
	    init?(symbol: Character) {
	        switch symbol {
	        case "K":
	            self = .Kelvin
	        case "C":
	            self = .Celsius
	        case "F":
	            self = .Fahrenheit
	        default:
	            return nil
	        }
	    }
	}

**2.带原始值的枚举类型自带init?(rawValue:)**

	enum TemperatureUnit: Character {
	    case Kelvin = "K", Celsius = "C", Fahrenheit = "F"
	}
	let fahrenheitUnit = TemperatureUnit(rawValue: "F")
	if fahrenheitUnit != nil {
	    print("This is a defined temperature unit, so initialization succeeded.")
	}

**3.类可失败构造器**

规则1： 必须在存储属性全部初始化后才能触发
规则2： 子类可以重载父类可失败构造器，成为可失败构造器或不是；子类也可以重载父类非可失败构造器成可失败构造器

	//注意：下例中name如果是String?或者String!则不能反映原则1，因为它有默认值nil
	class Product {
	    let name: String
	    init?(name: String) {
	        self.name = name
	        if name.isEmpty { return nil }
	    }
	}

----------

## 析构函数deinit

只有类有析构函数，基本可以按照C++理解，用于释放资源；每个类最多只能有一个析构函数

----------

#### 定义

	deinit {
	  //析构过程
	}

----------

#### 触发因素

**个人理解**： C++中析构在类被释放、或者程序退出时触发；swift没有类申请和释放的概念，个人猜测只有两种情况触发：
1.可选类型的类被赋值为nil时（当然要考虑引用计数器归零）
2.退出程序块或者整个程序时触发

	var playerOne: Player? = Player(coins: 100)
	playerOne = nil //此时触发

----------

#### 自动引用计数器ARC

	var reference1: Person?
	var reference2: Person?
	var reference3: Person?
	reference1 = Person(name: "John Appleseed")
	reference2 = reference1  //被引用2次
	reference3 = reference1  //被引用3次

	reference1 = nil  //引用还剩2次
	reference2 = nil  //引用还剩1次
	reference3 = nil  //此时deinit才会触发

----------

#### 类实例循环强引用冲突

两实例成员互相引用对方实例，引用计数器就无法归0，导致冲突

	class A {
	  var b: B?
	  deinit{}
	}
	class B {
	  var a: A?
	  deinit {}
	}

	var a: A? = A()
	var b: B? = B()

	//如下便构成循环强引用
	a!.b = b
	b!.a = a

	//如下实现析构便无法触发
	//a无法deinit，因为b!.a引用了a
	a = nil
	//b无法deinit，因为a的实例上一步没有销毁，存在对b的引用
	b = nil

----------

#### 弱引用weak
弱引用表明该引用可能没有值，因此类型必须是可选变量；可以理解成弱引用不计入ARC

	class A {
	  var b: B?
	  deinit{}
	}
	class B {
	  weak var a: A?
	  deinit {}
	}

	var a: A? = A()
	var b: B? = B()

	//如下便构成循环强引用
	a!.b = b
	b!.a = a

	a = nil  //a实例被销毁，疑问：此时b!.a=nil?
	b = nil  //b实例被销毁

----------

#### 无主引用unowned
无主引用，表明是永远有值的引用，因此必须是非可选类型；也可以理解成不计入ARC

	class A {
	  var b: B?
	  deinit{}
	}
	class B {
	  unowned var a: A
	  init(a:A){self.a = a}
	  deinit {}
	}
	var a:A? = A()
	a.b = B(a)

	a=nil //此时A实例被销毁、B实例也被销毁

**个人疑问**：假如a=nil之前`var b:B? = a.b!`,那么a=nil时B实现会被销毁吗？个人猜测不会，但是此时b.a的引用已经销毁了，就存在矛盾了。该如何理解？

----------

#### 闭包引用冲突

由于闭包也是引用类型，当类实现闭包时，self的调用，也存在冲突

	class A {
	  lazy var myClosure: Void -> Void = {self}
	  deinit{}
	}

解决办法是定义捕获列表

	//有明确入参类型
	lazy var someClosure: (Int, String) -> String = {
	  [unowned self, weak delegate = self.delegate!] (index: Int, stringToProcess: String) -> String
	  // closure body goes here
	}

	//无明确入参类型
	lazy var someClosure: Void -> String = {
	  [unowned self, weak delegate = self.delegate!] in
	// closure body goes here
	}

上例可以写成

	class A {
	  lazy var myClosure: Void -> Void = {
	    [unowned self] in
		self
		}
	  deinit{}
	}