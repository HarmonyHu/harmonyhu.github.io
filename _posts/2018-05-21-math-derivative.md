---
layout: post
title: 微积分基础
categories: 深度学习
tags: 深度学习 数学
---

* content
{:toc}
# 导数

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

# 积分

## 积分定义

#### 原函数

$$
F'(x) = f(x), 称F(x)是f(x)在区间I上的原函数
$$

#### 不定积分公式

$$
\int{f(x)}dx = F(x) + C, (C为常数)
$$

#### 牛顿-莱布尼茨公式

$$
\int _a ^b f(x) dx = F(b) - F(a)
$$

## 积分性质

$$
\int _a ^b kf(x) dx = k \int _a ^b f(x) dx, k为常数
$$

$$
\int _a ^b[f(x)\pm g(x)]dx = \int _a ^b f(x) dx \pm \int _a ^b g(x) dx
$$

$$
\int _a ^b f(x) dx = \int _a ^c f(x) dx + \int _c ^b f(x) dx
$$

$$
\int  f(u(x)) du(x) = F(u(x)) + C
$$



## 基本积分公式

$$
\int  x^adx = \frac{1}{a+1} x^{a+1} + C, (C是常数，a\ne -1)
$$

$$
\int a^x dx = \frac{a^x}{\ln a} + C
$$

$$
\int e^x dx = e^x + C
$$

$$
\int \frac{1}{x} dx = \ln |x| + C
$$

## 几何意义

求
$$
y=x^\frac{1}{2}
$$
与
$$
y=x^2
$$
所围图形的面积。

解：
$$
A = \int_0^1(x^\frac{1}{2} - x^2) dx = [\frac{2}{3}x^\frac{3}{2}-\frac{x^3}{3}]_0^1 = \frac{1}{3}
$$
