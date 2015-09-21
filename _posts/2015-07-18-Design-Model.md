---
layout: post
title: 23种设计模式回顾整理(未完)
date: 2015-07-18 00:00
categories: 技术类 设计模式
excerpt: 23种设计模式回顾整理
---

* content
{:toc}

##基本原则  

* 开闭原则：对扩展开发，对修改关闭。将变化部分抽象。  
* 里氏代换原则：类可行则子类也可行。继承复用。  
* 合成复用原则：少用继承，多用合成。  
* 依赖倒转原则：高层模块不依赖低层模块，细节依赖抽象。  

##23种设计模式  

####创建型

* 抽象工厂： Abstract Factory 创建产品系列  
* 建造者： Builder 封装对象组建过程  
* 工厂方法： Factory Method 将创建工作延迟到子类  
* 原型： Prototype 封装对原型的拷贝  
* 单例： Singleton 封装对象产生的个数  

####结构性  

* 适配器： Adapter 转换接口  
* 桥接： Bridge 分离接口与实现  
* 组合： Composite 将单体与复合体同等对待  
* 装饰： Decorator 用扩展取代继承  
* 外观： Facade 封装子系统  
* 享元： Flyweight 封装对象的获取  
* 代理： Proxy 封装对象访问过程  

####行为型  

* 责任链： Chain Of Responsibility 对象有上下链接关系  
* 命令： Commond 封装行为对象  
* 解释器： Interpreter  
* 中介者： Mediator 封装对象的交互  
* 备忘录： Memento 封装对象信息  
* 观察着： Observer 封装对象通知  
* 状态： State 封装与状态相关行为  
* 策略： Strategy 封装算法  
* 模板方法： Template Method 封装算法中可变部分  
* 访问者： Visitor 封装对象操作变化  
* 迭代器： Iterator 封装对象内部集合的使用  

(未整理完，待续）