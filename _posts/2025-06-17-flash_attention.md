---
layout: single
title: FlashAttention学习
categories:
  - AI
tags:
  - 网络模型
---

* content
{:toc}
学习论文：[FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness](https://arxiv.org/pdf/2205.14135)

## 背景介绍

Attention运算公式：$ Attention(Q,K,V) = softmax(\frac{QK^T}{\sqrt{d_k}})V $

将其展开到具体的LLM网络中，对应算子过程如下：

![](https://harmonyhu.github.io/img/flashattention.png)

其中B是Batch；S是sequence，数值比较大，可以是几十K到上百K；D是HeadDim，一般为128.

`Q_head`和`KV_head`相等时为MHA；`Q_head`是`KV_head`的倍数时为GQA.

关键问题：

`[B, Q_head, S, S]`数据量占比，如果按常规流程计算，则从SRAM到DDR之间存在大量数据拷贝，带宽成为瓶颈。

解决方法：

通过切分，使中间计算过程都保持在SRAM。但是由于S很大，必然要切S，导致softmax只能实现局部求解。所以关键点在**Softmax分块计算**。

<!--more-->

## Softmax分块计算

比如求Softmax(S)，按照原始Softmax计算逻辑如下：
$$
x_{max} = max(x_0,...,x_s) \\
x_i = x_i - x_{max} \\
l_i = \sum^{s}_{j=0}e^{x_j} \\
y_i = \frac{e^{x_i}}{l_i}
$$
分块计算逻辑如下(假如分两块)：
$$
\begin{align}
&Step 0 (求块0):&x_{max0} = max(x_0,...,x_{s0}) \\
&&x_{i0} = x_{i0} - x_{max0} \\
&&l_0 = \sum^{s0}_{j=0}e^{x_j} \\
&&y_0 = \frac{e^{x_{i0}}}{l_0} \\
&Step 1 (求块1):&x_{max1} = max(x_{s1},...,x_{s}) \\
&&x_{i1} = x_{i1} - x_{max1} \\
&&l_1 = \sum^{s}_{j=s1}e^{x_j} \\
&&y_1 = \frac{e^{x_{i1}}}{l_1} \\
&Step 2 (修正):&x_{max} = max(x_{max0}, x_{max1}) \\
&&l = e^{x_{max0}-x_{max}}l_0 + e^{x_{max1}-x_{max}}l_1 \\
&&y_0 = \frac{l_0e^{x_{max0} - x_{max}}}{l} y0 \\
&&y_1 = \frac{l_1e^{x_{max1} - x_{max}}}{l} y1
\end{align}
$$
每个块计算完后需要记录下该块的三个值：max、l、和y。最后做修正即可得到最终的softmax。



## FlashAttentionV1

* 外循环：切K的S维度和切V的S维度

* 内循环：切Q的S维度

切分后的图如下：

![](https://harmonyhu.github.io/img/fattentionv1.png)

由于Q是内循环，每次Q循环结束时得到的是`O[B, Q_head, S, D]`；

下一个K的切分得到的O后需要计算softmax的修正系数，然后与上一个O进行修正累加。



## FlashAttentionV2

* V1有个可改进点是：O会被重复读写K的切分次数

* 改进方法：将Q做外循环，KV做内循环

由于KV内循环，每次KV算出来的结果为`O[B, Q_head, Sk, D]`，每次结果叠加到O时需要进行Softmax修正和。

Q外循环，最终得到完整的`O[B, Q_head, S, D]`。



## FlashAttentionV3

V1和V2是算法改进，V3是结合hopper GPU的新特性做的改进（TMA、WGMMA异步)。



## FlashAttentionV4

针对Decode阶段，预定义Softmax的最大值为*ϕ*，减少了修正softmax累加过程，从而是每个切分可以完全并行。

