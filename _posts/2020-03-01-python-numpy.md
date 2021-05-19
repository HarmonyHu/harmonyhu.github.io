---
layout: single
title: Numpy
categories:
  - python
tags:
  - Numpy
---

* content
{:toc}


## 概述

* Numpy, Numerical Python, 读作Num Pie

* 导入`import numpy as np`



## ndarray

N维数据对象，成员：

* data，内存地址
* shape，各个维度大小的元组
* dtype，元素类型
* size，元素个数
* ndim，维度的数量
* strides，各个维度步进字节大小的元组
* T，ndarray，对象的转置
* flags, 各种属性标志
* 其他

<!--more-->

## 数据类型

```python
bool(True False)
int8,int16,int32,int64,uint8,uint16,uint32,uint64
float16,float32,float64
```



## 创建数组

```python
arr = np.array([[1,2],[3,4]], dtype = float)
empty = np.empty((4,3,28,28), dtype = np.int8) # 未初始化
zeros = np.zeros((4,3,28,28))
ones = np.ones((4,3,28,28))
fives = np.full((4,3,28,28), 5.0) # 初始化为全5.0
x = np.arange(5) # 创建数组[0,1,2,3,4]
y = np.arange(1,5) # 创建数组[1,2,3,4]
z = y #z是y的引用，创建数组用z = np.array(y)

# list或tuple，转数组
a = [1,2,3]
b = np.array(a)
```



## 索引

```python
a = np.arange(20).reshape(5,4)  #0-19，维度为(5,4)
                                #array([[ 0,  1,  2,  3],
                                #       [ 4,  5,  6,  7],
                                #       [ 8,  9, 10, 11],
                                #       [12, 13, 14, 15],
                                #       [16, 17, 18, 19]])
x = a[1,2] # 6
y = a[-1,2] # 18

# start:stop:step
b = a[2:4,] # 8-15, 维度为(2,4)
c = a[::2,] # 选择偶数行，维度为(3,4)
d = a[:,1]  # array([ 1,  5,  9, 13, 17])，等价于 d = a[...,1]

# 整数索引
e = a[[1,1,3],] #选择1,1,3三行，维度为(3,4)
a[[0,1,2],:]=a[[2,1,0],:] # 0,1,2三行互换

# bool索引
f = a[a>10] # array([11, 12, 13, 14, 15, 16, 17, 18, 19])
```



## 操作

```python
g = a.reshape(4,5) #从维度(5,4)变为(4,5),数据内容不变
for e in g.flat:     #元素迭代器
  print(e)
h = g.flatten() #数组一维化，维度为(20)
i = g.ravel()   #数组一维化引用，修改i会使g改变
j = a.transpose((1,0)) #维度从(5,4)变为(4,5),数据内容转置
k = np.ascontiguousarray(j) #使连续，一般需要存储时使用

k = a.reshape(1,4,1,5).squeeze() # 删除维度为1的维度，最终维度为(4,5)
l = a.reshape(1,4,1,5).squeeze(0) # 删除第0维，最终维度为(4,1,5)
m = np.expand_dims(a, 0) # 增加一个维度，维度由(5,4)变为(1,5,4)
n = np.concatenate((a,a),axis=1) #指定维度数组合并，维度变化(5,8)

o,p = np.split(a,2,axis=1) #将第1维均分2等份，o和p维度为(5,2)
q,r = np.split(a,[2],axis=0) #将第0维，按位置分割，q维度为(2,4),r维度为(3,4)

s = a.astype(np.float32) #类型变换
```



## 运算

```python
np.sum(a) # 求和，190
np.sum(a,axis=1) # 指定维度求和，array([ 6, 22, 38, 54, 70])

np.mean(a) # 求均值，9.5
np.var(a)  # 求方差，33.25
np.std(a)  # 求标准差，5.766281297335398

a*b         # 元素运算，同理其他运算
np.dot(a,b) # 内积，点积，矩阵乘积[M,K]*[K,N]
```



## random

| Function                           | Explain                   |
| ---------------------------------- | ------------------------- |
| rand(d0, d1, ..., dn)              | [0,1) 均匀分布            |
| randint(low, high=None, size=None) | [low,high) 离散均匀分布   |
| randn(d0, d1, ..., dn)             | (-inf, +inf) 标准正态分布 |



## 文件

```python
## 保存
np.save("abc.npy", x)
np.savetxt("abc.txt", x)
np.savez("abc.npz", **x) #其中x是散列
bin.tofile("abc.bin") # 按二进制保存

## 读取
bin = np.fromfile("abc.bin", dtype=np.uint8) # 读取二进制，按一维数组存放
txt = np.loadtxt("abc.txt")
hash = np.load("abc.npz")
```

