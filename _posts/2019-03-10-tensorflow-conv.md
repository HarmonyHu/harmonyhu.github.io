---
layout: article
title: tensorflow：Conv2D
categories: AI
tags: TensorFlow
---

* content
{:toc}
参考[tf.nn.conv2d](https://www.tensorflow.org/api_docs/python/tf/nn/conv2d)

## 一、OP定义

```c++
REGISTER_OP("Conv2D")
    .Input("input: T")
    .Input("filter: T")
    .Output("output: T")
    .Attr("T: {half, bfloat16, float, double}")
    .Attr("strides: list(int)")
    .Attr("use_cudnn_on_gpu: bool = true")
    .Attr(GetPaddingAttrString())
    .Attr(GetConvnetDataFormatAttrString())
    .Attr("dilations: list(int) = [1, 1, 1, 1]")
    .SetShapeFn(shape_inference::Conv2DShape);
```

<!--more-->

1. input

   输入，类型是其中一个：half、bfloat16、float、double，4维张量，维度顺序由data_format指定，默认是NHWC。

2. filter

   输入，类型与input相同，4位张量，维度顺序由filter_format指定，默认为HWIO，即[filter_height, filter_width, in_channels, out_channels]。

3. output

   输出，类型与input相同。输出的维度后文介绍。

4. strides

   步进，int列表，1维数据长度为4，表示filter在input上的每个维度的步进，维度顺序与input一致。

5. padding

   SAME则补0使输入输出图像大小相同，VALID则允许不相同

6. data_format

   NCHW或者NHWC，默认是NHWC

7. dilations

   默认是[1,1,1,1]，对filter膨胀，如下图：

   ![](https://harmonyhu.github.io/img/conv2d1.jpg)

8. Conv2DShape

   计算输出shape的回调函数



## 二、输出的shape

假如卷积各个参数都是默认的情况下，输出数量如下图：

![](https://harmonyhu.github.io/img/conv2d2.jpg)

图中按NHWC格式，输入为[1, 32, 32, 3]，filter按HWIO为[5, 5, 3, 10]，输出为[1, 28, 28, 10]

## 三、其他概念

1. 群卷积

   参考[A Tutorial on Filter Groups](https://blog.yani.io/filter-group-tutorial/)

   假如卷积核有N个，群数量为g。群卷积的操作为，将卷积核分为g份，每份N/g个。然后每份与输入做卷积，最后合并。如下对比图：

   ![](https://harmonyhu.github.io/img/conv2d3.jpg)

   ![](https://harmonyhu.github.io/img/conv2d4.jpg)



2. 快速卷积(Winograd)

   winograd算法最早是1980年Terry Winograd提出，Winograd快速卷积算法，出自CVPR 2016的paper：[Fast Algorithms for Convolutional Neural Networks](https://arxiv.org/abs/1509.09308)。此处学习来自：[卷积神经网络中的Winograd快速卷积算法](https://www.cnblogs.com/shine-lee/p/10906535.html)

   **一维卷积举例**

   输入是1维数据[d0, d1, d2, d3]，卷积核是[g0, g1, g2]，通常卷积计算如下：
   $$
   F(2, 3) = \left[ \begin{array}{lll}{d_{0}} & {d_{1}} & {d_{2}} \\ {d_{1}} & {d_{2}} & {d_{3}}\end{array}\right] \left[ \begin{array}{l}{g_{0}} \\ {g_{1}} \\ {g_{2}}\end{array}\right]=\left[ \begin{array}{c}{r_0} \\ {r_1}\end{array}\right]
   $$

   $$
   \begin{array}{l}{r_{0}=\left(d_{0} \cdot g_{0}\right)+\left(d_{1} \cdot g_{1}\right)+\left(d_{2} \cdot g_{2}\right)} \\ {r_{1}=\left(d_{1} \cdot g_{0}\right)+\left(d_{2} \cdot g_{1}\right)+\left(d_{3} \cdot g_{2}\right)}\end{array}
   $$

   需要6次乘法和4次加法。

   采用Winograd算法，算法如下：
   $$
   F(2,3)=\left[ \begin{array}{lll}{d_{0}} & {d_{1}} & {d_{2}} \\ {d_{1}} & {d_{2}} & {d_{3}}\end{array}\right] \left[ \begin{array}{l}{g_{0}} \\ {g_{1}} \\ {g_{2}}\end{array}\right]=\left[ \begin{array}{c}{m_{1}+m_{2}+m_{3}} \\ {m_{2}-m_{3}-m_{4}}\end{array}\right]
   $$

   $$
   \begin{array}{ll}{m_{1}=\left(d_{0}-d_{2}\right) g_{0}} & {m_{2}=\left(d_{1}+d_{2}\right) \frac{g_{0}+g_{1}+g_{2}}{2}} \\ {m_{4}=\left(d_{1}-d_{3}\right) g_{2}} & {m_{3}=\left(d_{2}-d_{1}\right) \frac{g_{0}-g_{1}+g_{2}}{2}}\end{array}
   $$

   其中g本身的运算可以提前算好，一共运算次数为8个加减法和4个乘法。

   Winograd展开后与原始卷积结果相同。但是通常乘法运算时间比较长，所以winograd算法是通过增加加减法减少乘法来实现加速。

   **二维卷积举例**

   输入是二维数据，维度为[4, 4]，卷积核为[3, 3]，进行Winograd转换如下：

   ![](https://harmonyhu.github.io/img/conv2d5.jpg)

   将卷积核的元素拉成一列，将输入信号每个滑动窗口中的元素拉成一行。注意图中红线划分成的分块矩阵，**每个子矩阵中重复元素的位置与一维时相同，同时重复的子矩阵也和一维时相同**，如下所示：

   ![](https://harmonyhu.github.io/img/conv2d6.jpg)

   每个子矩阵再用Winograd算法转换，如下：

   ![](https://harmonyhu.github.io/img/conv2d7.jpg)



