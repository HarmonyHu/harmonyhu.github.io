---
layout: single
title: 时间复杂度
categories:
  - AI
tags:
  - 算法
---

* content
{:toc}
## 概述

时间复杂度通常用大O符号表示，不考虑低阶项和系数，主要考察算法中元素个数N趋于无穷时的情况。

另外时间复杂度也有最好情况表示Ω，和平均情况表示Θ。大O是最坏情况表示。

<!--more-->



## 常见级别

| 复杂度量级   | 表示          | 举例         |
| ------------ | ------------- | ------------ |
| 常数级别     | 1             | 单词运算     |
| 对数级别     | log N         | 二分查找     |
| 线性级别     | N             | 找出某个元素 |
| 线性对数级别 | N log N       | 归并排序     |
| 平方级别     | N<sup>2</sup> | 双层N循环    |
| 立方级别     | N<sup>3</sup> | 三层N循环    |
| 指数级别     | 2<sup>N</sup> | 穷举查找     |
| 阶乘阶       | N!            |              |

图标表示如下：

![](https://harmonyhu.github.io/img/bigo.png)

## 参考

[Big-O Complexity Chart](https://www.bigocheatsheet.com)