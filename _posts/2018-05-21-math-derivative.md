---
layout: post
title: 导数基本法则
categories: 深度学习
tags: 深度学习 导数
---

* content
{:toc}
## 导数定义

$$
f'(x) = \lim_{\Delta{x}->0}\frac{f(x+\Delta{x})- f(x)}{\Delta{x}} = \lim_{x->x_0}\frac{f(x)-f(x_0)}{x-x_0}
$$

$$
f'(x)也常表示为：\frac{\alpha y}{\alpha x} 或者 \frac{\Delta y}{\Delta x} 或者 \frac{d y}{d x}
$$

意义：

1. 可以代表曲线`y=f(x)`在某点的切线斜率

2. 可以反映y在x的某点上的变化率

3. 可以表示运动曲线`s=f(t)`在t的某点上的速率

    

    


## 导数求导法则

#### 基本运算（加减乘除）

$$
[u(x) \pm v(x) ]' = u'(x) \pm v'(x)
$$

$$
[u(x) \times v(x)]' = u'(x) \times v(x) + u(x) \times v'(x)
$$

$$
[\frac{u(x)}{v(x)} ]' = \frac{u'(x)v(x) - u(x)v'(x)}{v^2(x)}
$$

#### 链式法则（复合函数）

$$
若y = f(u) 且u = g(x)，则\frac{d y}{d x} = f'(u) \times g'(x) 或\frac{d y}{d u} \times \frac{d u}{d x} 
$$

## 初等函数的导数

$$
(C)' = 0
$$

$$
(x^n)' = nx^{n-1}
$$

$$
(e^x)' = e^x
$$

$$
(\sin x)' = \cos x
$$

$$
(\cos x)' = - \sin x
$$

$$
(a^x)' = a^x \ln a
$$

$$
(\log{_a}x)' = \frac{1}{x \ln a} => (\ln{x})' = \frac{1}{x}
$$

$$
f(x) = \frac{1}{1+e^{-x}} => f'(x) = f(x) \times (1-f(x))
$$

