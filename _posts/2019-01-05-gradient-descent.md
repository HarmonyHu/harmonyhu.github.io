---
layout: post
title: 学习整理：梯度下降(Gradient Descent)
categories: 深度学习
tags: 优化
---



参考链接：[Intro to optimization in deep learning: Gradient Descent](https://blog.paperspace.com/intro-to-optimization-in-deep-learning-gradient-descent/)

## 概念

#### 损失函数模型

只有2个权值的情况下，理想的损失函数模型如下：

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/gradient1.png)

其中B点是损失值最小点，A点是出发点，通过更新权值向B点出发。

A点最快的方向是就是其各个权值维度的切线方向，可以利用导数求出。沿着切线方向移动，得到A点的梯度。反复求取梯度，最后到达最小值，如下图：

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/gradient2.gif)