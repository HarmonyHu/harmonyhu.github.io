---
layout: post
title: 学习Transformer
categories: AI
tags: 算法
---

* content
{:toc}
## 模型结构

![](https://harmonyhu.github.io/img/tansformer.png)

<!--more-->

## Embedding

$$
X_{[batch\_size, seq\_len]} => X_{em[batch\_size,seq\_len, em\_dim]}
$$

向量嵌入，其中`batch_size`可理解为句子数量，`seq_length`可理解为单个句子的字数，`embedding dim`为向量长度。

Embedding做的事情就是：将句子中的字转换成向量形式。

每个字对应的向量由`Word2vec`算法而定。



## Self-Attention

$$
Attention(Q,K,V) = softmax(\frac{QK^T}{\sqrt{d_k}})V \\
Q = Linear(X_{em}) = X_{em}W_Q \\
K = Linear(X_{em}) = X_{em}W_K \\
V = Linear(X_{em}) = X_{em}W_V \\
其中 W_Q,W_K,W_V \in R^{em\_dim * em\_dim}
$$

权重的维度为`[em_dim, em_dim]`，经过线性变换后Q,K,V的维度依然是`[batch_size, seq_len, em_dim]`。

#### multi head attention

将`embedding dim`平均拆分成多份：`head size = embedding dim / num of heads`。

这样Q,K,W的维度为`[batch_size, h, seq_len, em_dim/h]`。
$$
QK^T
$$
称注意力矩阵，维度为`[batch_size, h, seq_len, seq_len]`，Q与K对应向量越相似值越大，softmax后越大的值百分比越高。

然后与V点积后维度为`[batch_size, h , seq_len, em_dim/h]`

由于语句有长有短，需要masking操作使超出部分无效。



## 残差与归一化

$$
X_{res} = X_{em}+ Attention(Q,K,V) \\
X_{attention} = LayerNorm(X_{res}) = \alpha \odot \frac{X_{ij}-\mu_i}{\sqrt{\sigma_i^2 + \epsilon}} + \beta
$$

防止梯度消失，加快收敛

## 前馈网络

$$
X_{hidden}= Activate(Linear(Linear(X_{attention})))
$$

线性映射和激活函数



## 循环重复

从`Self-Attention`到`前馈网络`循环操作



## 参考

[Attention Is All You Need](https://arxiv.org/pdf/1706.03762.pdf)

[硬核图解Transformer](https://mp.weixin.qq.com/s/jx-2Ai2YKbwODW6uJaF3hQ)



