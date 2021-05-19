---
layout: single
title: python
categories:
  - python
tags:
  - python
---

* content
{:toc}
## 执行方式

* 直接执行，`python test.py`
* 交互执行，`ipython`

## 注释

``` python
#!/usr/bin/python3
# 单行注释
print("hello,world")
'''
多行注释
用\实现多行语句，[]{}()中不需要\
'''
a = 1 + 2 + \
    3 + 4
b = ['a','b',
    'c','d']
```

<!--more-->



## 基本数据类型

#### 数字

* int，如1，20
* bool，True和False
* float，如1.0，3.0e-2
* complex，如1+2j
* 运算包括`+-*/%`，另外`//`表向下取整除，`**`幂运算

#### 字符串""

* 单引号和双引号完全相同
* 三引号可以表示多行字符串
* 用\转义，用r是转义不发生
* 可以用+进行连接，用*重复
* 索引`[start:end:step]`，从左0开始，从右-1开始
* `in`和`not in`，是否包含，如`'a' in 'abc'`
* 格式化`%`，如`"0x%x"%254`，`"%d=0x%x"%(254,254)`
* `f`可插入变量或表达式，如`f"a = {a}"`
* 字符串不可修改

#### 列表[]

* 用`[]`或者`list()`创建列表，内容可以是不同类型

* 索引`[start:end:step]`

* 可以更新

  ``` python
  l = ['abc','efg']
  l[1] = '5'  # 修改
  l.append(4) # 尾部添加
  del l[0]    # 删
  ```

* 运算

  ``` python
  len(l) #长度
  l + l  #拼接
  [l,l]  #嵌套
  l * 3  #重复
  l.clear() #清空
  ```

#### 元组()

* 用`()`或者`tuple`创建元组，内容可以是不同类型
* 不可修改，其余与列表均相同
* `tuple()`和`list()`可以互相转换

#### 字典{key:value}

* 用`{}`或者`dict`创建字典，如`a = {'a':'abc','b':'bd'}`
* key可以是字符串或数字，value可以是任意类型
* 可以修改

#### 集合{}

* 用`{}`或者`set`创建，空集合必须用`set()`
* 无序不重复序列
* 添加元素，`s.add(x)`；移出元素，`s.remove(x)`
* 用`in`和`not in`判断是否存在某个元素



## 控制语句

#### if

``` python
## 方式一
if condition_1:
    statement_block_1
elif condition_2:
    statement_block_2
else:
    statement_block_3
## 方式二
state_1 if condition else state_2
```

#### while

``` python
while conditon:
    state
```

#### for

``` python
## 方式一
for <variable> in <sequence>:
    <statements>
else:
    <statements>
## 方式二
for i in range(5):
    print(i)
```

#### 循环控制

* break 中断循环
* continue 下一循环
* pass 空语句



## 函数和类

``` python
## 函数
def 函数名（参数列表）:
    函数体
## 类
class MyClass:
    """一个简单的类实例"""
    i = 12345
    def f(self):
        return 'hello world'

# 实例化类
x = MyClass()
```

## 常用模块

#### os

``` python
import os
os.getcwd()      # 返回当前的工作目录
os.chdir('/server/accesslogs')   # 修改当前的工作目录
os.system('mkdir today')   # 执行系统命令 mkdir
help(os) #查看更多信息
```

#### sys

```python
import sys
sys.argv #参数列表，包含本身
```

#### re

``` python
import re
re.match(pattern, string, flags=0) #判断是否匹配，返回True或False
re.search(pattern, string, flags=0) #返回第一个匹配项
re.sub(pattern, repl, string, count=0, flags=0) #替换
pattern = re.compile(pattern) # 生成pattern对象
```



#### cv2

```python
import cv2
import numpy as np

image = cv2.imread('xxx.jpeg', flags) #读入图片，默认BGR格式，HWC
# cv2.IMREAD_COLOER: 读入三通道，忽略alpha通道
# cv2.IMREAD_GRAYSCALE: 读入灰度图片
# cv2.IMREAD_UNCHANGED: 读入完整图片，包含alpha通道
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
# cv2.COLOR_BGR2RGB: 通道转换
# cv2.COLOR_GRAY2RGB: 灰度转换成彩色
image.shape #(h,w,c)
image = cv2.resize(image, (256,256)) #改变尺寸
```
