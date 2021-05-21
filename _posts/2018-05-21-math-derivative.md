---
layout: single
title: 微积分基础
categories:
  - AI
tags:
  - 数学
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


<!--more-->

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

## 求导试题

求函数导数: $ f(x) = \frac{1}{1+e^{-x}} $

解：

$$
(1+e^{-x})^{-1} = (-1)\times  (1+e^{-x})^{-2} \times  (1+e^{-x})'  = (-1)\times  (1+e^{-x})^{-2} \times e^{-x} \times (-1) = \frac{1}{e^x+e^{-x}+2}
$$



# 积分

## 积分定义

**原函数：** $ F'(x) = f(x), 称F(x)是f(x)在区间I上的原函数 $

**不定积分公式：** $ \int{f(x)}dx = F(x) + C, (C为常数) $

**牛顿-莱布尼茨公式：** $ \int _a ^b f(x) dx = F(b) - F(a) $



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

求 $ y=x^\frac{1}{2} $ 与 $ y=x^2 $所围图形的面积

解：

$$
A = \int_0^1(x^\frac{1}{2} - x^2) dx = [\frac{2}{3}x^\frac{3}{2}-\frac{x^3}{3}]_0^1 = \frac{1}{3}
$$

## 积分求解方法

#### 基本性质

$$
\int kf(x) dx = k \int f(x) dx, k为常数
$$

$$
\int [f(x)\pm g(x)]dx = \int  f(x) dx \pm \int g(x) dx
$$

$$
\int _a ^b f(x) dx = \int _a ^c f(x) dx + \int _c ^b f(x) dx
$$

#### 第一换元法

**公式：** $ \int f(x)dx = \int g(u(x))u'(x)dx = \int g(u(x)) du(x) = G(u(x)) + C $

**求解试题**

**题1：** $ f(x) = \int  (ax+b)dx $

解：

$$
f(x) = \int  (ax+b)dx = \int  (ax+b) \times \frac{1}{a} d(ax+b) \\
令u = ax+b，\\
则f(x) = \frac{1}{a}\int udu = \frac{1}{2a}u^2 + C= \frac{(ax+b)^2}{2a}= \frac{a}{2}x^2 + x + C
$$

**题2：** $ f(x) = \int  (3x-2)^5dx $

解：

$$
f(x) = \frac{1}{3}\int (3x-2)^5d(3x-2) +C= \frac{1}{3}\times\frac{1}{6}(3x-2)^6 +C
$$

**题3：** $ f(x) = \int xe^{-x^2}dx $

解：

$$
\because xdx=\frac{1}{2}dx^2, \\
\therefore f(x) = -\frac{1}{2}\int e^{-x^2}d(-x^2) = -\frac{1}{2}e^{-x^2} + C
$$


#### 第二换元法

**公式：** 设x=u(t), 可导且u'(t)不为0，则：$ \int f(x)dx = \int f(u(t))u'(t)dt = F(t) + C = F(u^{-1}(x)) + C $

**求解试题**

$$
f(x) = \int \frac{1}{x(x-1)^{\frac{1}{2}}}dx
$$

解：

$$
令x=t^2+1，则\\ f(x) = \int \frac{1}{(t^2+1)t}d(t^2+1) = \int \frac{2}{t^2+1}dt = 2 \arctan t +C = 2 \arctan(x-1)^\frac{1}{2} + C
$$

#### 分步求分法

**公式：**

$$
由[u(x)v(x)]' = u'(x)v(x) + u(x)v'(x)，得u(x)v'(x) = [u(x)v(x)]'- v(x)u'(x), \\
两边积分得\int u(x)v'(x)dx = u(x)v(x) - \int v(x)u'(x)dx
$$

**求解试题**

$$
f(x) = \int(x^2+1)e^{-x}dx
$$

解：

$$
f(x) = - \int (x^2+1)de^{-x} \\
=  - (x^2+1)e^{-x} + \int e^{-x}d(x^2+1) \\
=  - (x^2+1)e^{-x} + 2\int e^{-x}xdx \\
= - (x^2+1)e^{-x} + 2\int xd(-e^{-x}) \\
= - (x^2+1)e^{-x} - 2xe^{-x} + 2\int e^{-x}dx \\
= - (x^2+1)e^{-x} - 2xe^{-x} -2 e^{-x} +C \\
=(-x^2-2x-3)e^{-x}+C
$$