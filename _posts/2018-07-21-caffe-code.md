---
layout: post
title: ubuntu下使用caffe
categories: 深度学习
tags: Caffe
---

* content
{:toc}
## 一、代码结构

* Blob : 网络层之间传递数据的媒介，包括data和diff，以及对应的shape，等等
* Layer : 神经网络各层的抽象，包括向前传播 (Forward) 和 反向传播 (Backward)的方法，参数LayerParameter (就是protobuf的子类)，输入的blobs，等等
* Net : 整个网络，由各个Layer组成
* Solver : 网络模型的求解方法，以及模型的各个参数


