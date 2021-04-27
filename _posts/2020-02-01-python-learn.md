---
layout: post
title: python杂记
categories: python
tags: python
---

* content
{:toc}
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