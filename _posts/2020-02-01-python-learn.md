---
layout: post
title: python杂记
categories: python
tags: python 编程
---

* content
{:toc}
## numpy

```python
## 导入
import numpy as np

## 数组
arr = np.array([[1,2],[3,4]], dtype = float) # 创建数组，元素指定，shape为(2,2)
empty = np.empty((4,3,28,28), dtype = int) # 创建数组，shape为(4,3,28,28)
zeros = np.zeros((4,3,28,28)) # 创建数组，初始化为全0
ones = np.ones((4,3,28,28)) # 创建数组，初始化为全1
fives = np.full((4,3,28,28), 5.0) # 创建数组，初始化为全5.0
x = np.arange(5) # 创建数组[0,1,2,3,4]

ones_2 = np.reshape((2,6,28,28)) # reshape
ones.size #元素个数
ones.dtype #元素类型
ones.shape
ones.flatten() #一维化

a = x[1:3] #从索引1开始，到3为止，不包括索引3. = [1,2]
a = x[1:]  # = [1,2,3,4]

np.transpose(ones, (0,2,3,1)) #维度转置, shape=(4,28,28,3)
np.expand_dims(x, axis = 0) #维度扩充，shape=(1, 5)

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

<!--more-->

## cv2

#### 导入

```python
import cv2
import numpy as np
```

#### imread

```python
image = cv2.imread('xxx.jpeg', flags) #读入图片，默认BGR格式，HWC
```

<!--more-->

* cv2.IMREAD_COLOER: 读入三通道，忽略alpha通道
* cv2.IMREAD_GRAYSCALE: 读入灰度图片
* cv2.IMREAD_UNCHANGED: 读入完整图片，包含alpha通道

#### cvtColor

```python
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
```

* cv2.COLOR_BGR2RGB: 通道转换
* cv2.COLOR_GRAY2RGB: 灰度转换成彩色

* image.shape: 读出(h,w,c)
* image = cv2.resize(image, (256,256)): 改变尺寸
* image = np.transpose(image, (2,0,1)): 转换成CHW
* x = np.expand_dims(image, axis=0): 扩展一个维度



## 其他

* ipython：进入python交互模式