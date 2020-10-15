---
layout: post
title: 常见算子操作
categories: AI
tags: 算法
---

* content
{:toc}
## 元素操作

#### Relu

$$
f(x) = 
\begin{cases}
x,\quad &x \ge 0 \\
0,\quad &x \lt 0
\end{cases}
$$

#### LeakyRelu

$$
f(x) = 
\begin{cases}
x,\quad &x \ge 0 \\
x \times negative\_slope,\quad &x \lt 0
\end{cases}
$$



#### PRelu

$$
f(x) = 
\begin{cases}
x,\quad &x \ge 0 \\
x \times slope\_data[c],\quad &x \lt 0
\end{cases}
$$

#### Scale

$$
f(x) = scale[c] \times x + bias[c]
$$

#### Power

$$
f(x) = (scale \times x + shift)^{power}
$$

#### BatchNorm

$$
mean = \frac{1}{m} \sum_{i=1}^{m}{x_i} \quad 求均值 \\
variance = \frac{1}{m} \sum_{i=1}^{m}{(x_i - mean)^2} \quad 求方差 \\
u_i = \frac{x_i - mean}{\sqrt{variance + eps}} \quad 归一化, eps用于防止除0 \\
y_i = \gamma \times u_i + \beta \Rightarrow BN_{\gamma,\beta}(x_i) \quad \gamma,\beta训练生成
$$

归一化，将网络层的输入转化到均值为 0方差为1的标准正态分布上，使梯度变化增大，加快训练收敛速度。

caffe中batchnorm，没有第四步，推理运算过程如下：
$$
mean = blobs_0,\quad variance = blobs_1,\quad scale = blobs_2[0] \\
y_i = \frac{x_i - \frac{mean_c}{scale}}{\sqrt{\frac{variance_c}{scale} + eps}}\\
$$


## 矩阵操作

#### Pooling

$$
\begin{bmatrix}
1 & 2 & 3 & 4\\
5 & 6 & 7 & 8 
\end{bmatrix}
\Rightarrow
\begin{cases}
\begin{bmatrix}
6 & 8
\end{bmatrix},\quad & max \\
\begin{bmatrix}
3.5 & 5.5
\end{bmatrix},\quad & average
\end{cases}
$$

从大feature map转为小feature map，防止过拟合，减少参数

#### Upsample

$$
\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 1 & 2 & 2 \\
1 & 1 & 2 & 2 \\
3 & 3 & 4 & 4 \\
3 & 3 & 4 & 4 \\
\end{bmatrix}
$$

上采样，用于扩大feature map，通常有这几种：

* 如图中所示，各个元素翻倍
* unpooling max，只有在pooling max位置填值，其余补0
* deconv，input填0后做卷积操作

#### Tile

$$
\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 2 & 1 & 2 \\
3 & 4 & 3 & 4 \\
1 & 2 & 1 & 2 \\
3 & 4 & 3 & 4 \\
\end{bmatrix}
$$

维度翻倍，上图是将(h,w)转换为(2h,2w)

#### Permute (Transpose)

$$
\begin{bmatrix}
1 & 2 & 3 & 4\\
5 & 6 & 7 & 8 
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 5 \\
2 & 6 \\
3 & 7 \\
4 & 8
\end{bmatrix}
$$

维度转换，比如图片三维HWC转换为CHW，可以用numpy如下操作：

```python
x = np.transpose(x, (2,0,1))
```

#### Concat

$$
\begin{bmatrix}
1 & 2
\end{bmatrix},
\begin{bmatrix}
3 & 4
\end{bmatrix},
\begin{bmatrix}
5 & 6
\end{bmatrix}
\Rightarrow
\begin{bmatrix}
1 & 2 \\
3 & 4 \\
5 & 6 \\
\end{bmatrix}
$$

