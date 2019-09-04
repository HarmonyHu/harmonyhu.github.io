---
layout: post
title: tensorflow：Conv2D
categories: 深度学习
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

   ![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/conv2d1.jpg)  

8. Conv2DShape

   计算输出shape的回调函数



## 二、输出的shape

假如卷积各个参数都是默认的情况下，输出数量如下图：

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/conv2d2.jpg)  

图中输入的shape按NHWC来看为[1, 32,32,3]，filter的shape按HWIO来看为[5,5,3,10]，步进为1，得到的输出为[1, 28, 28 10]