---
layout: article
title: 浮点型存储格式
categories: AI
tags: 算法
---

* content
{:toc}


## FP32

float共32bit：1bit符号位，8bit指数位，23bit底数位。如下表示：
`S E8 M23`
浮点与二进制转换公式如下：

$$
Y = (-1)^{s} \times m \times 2^{e}，其中m = 1.M23，e = E8 - 127
$$


以浮点数12.5，举例说明：


$$
\begin{align}
12.5 &=> 1100.1 \\
&=> 1.1001 \times 2^{3} \\
&=> E8 = 3 + 127 = 130 = 1000 0010 \\
&\qquad M23= 1001 0000 0000 0000 000 \\
&=> 0 1000 0010 1001 0000 0000 0000 000
\end{align}
$$



<!--more-->



## FP16与BF16

对应表示如下：

| Format | Bits | Sign | Exponent | Fraction |
| ------ | ---- | ---- | -------- | -------- |
| FP32   | 32   | 1    | 8        | 23       |
| FP16   | 16   | 1    | 5        | 10       |
| BF16   | 16   | 1    | 8        | 7        |