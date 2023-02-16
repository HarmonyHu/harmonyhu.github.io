---
layout: single
title: FasterRCNN
categories:
  - AI
tags:
  - 网络模型
---

* content
{:toc}
## 概述



**源码：** [Torch Faster RCNN](https://pytorch.org/vision/stable/_modules/torchvision/models/detection/faster_rcnn.html#fasterrcnn_resnet50_fpn)

**论文地址：**[Faster R-CNN](https://arxiv.org/pdf/1506.01497.pdf)

<!--more-->



## 基础过程

![](https://harmonyhu.github.io/img/faster_rcnn.png)

### Anchor

每个feature map对应9个锚点，对应每个点取128x128、256x256、512x512三种尺寸，按1:1、1:2、2:1三种比例设定框，也就是9个框。

### Backbone

一般用vgg16或者resnet50等CNN网络做backbone。这里假定用vgg16，13个conv +  4个pooling。其中Conv不会改变feature map尺寸，只有pool会是尺寸缩小到1/2。

假定输入为`[1, 3, 640, 640]`，那么输出尺寸是`[1, 512, 40, 40]`

### RPN

Region Proposal Network, 寻找预选框网络，分为2部分：

* 1x1卷积提取9x2维的每个像素点进行score预测。卷积Kernel为[18, 512, 1, 1]，得到[1, 18, 40, 40]。然后按[1, 2, 9x40, 40]，对2做softmax做判断。
* 1x1卷积提取9x4的平移和缩放参数，对9个anchor做调整

然后根据2组信息做proposal。proposal过程如下：

1）根据score排序，根据得到前N的anchor；

2）将anchor的尺寸进行还原配置

3）使用NM得到最终的预选框

### ROIPooling

将指定区域pooling成指定尺寸。对[1, 512, 40, 40]做roi pooling，pooling成7x7，最终得到[N, 512, 7, 7]。如下图：

![](https://harmonyhu.github.io/img/roipooling.png)









