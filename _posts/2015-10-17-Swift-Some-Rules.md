---
layout: post
title: Swift学习之细小规则整理
date: 2015-10-17 00:00
categories: 技术类 Swift
---

* content
{:toc}


##大小写

类型的定义用UpperCamelCase，其余全用lowerCamelCase。  
类型定义包括：

-  基础类型如Int/String/Set等等  
-  enum定义的枚举类型，**包括其成员**（?为何成员也看做是类型）  
	`enum CompassPoint {case North,South,East,West}`

-  struct和class定义的结构体和类  
	`class SomeClass {}`  
	`struct SomeStructure {}`

其余包括：变量、常量、结构体或类的成员 等等

##引用类型与值类型

类、函数是引用类型，其余如String/Array/枚举/结构体 等等都是值类型
