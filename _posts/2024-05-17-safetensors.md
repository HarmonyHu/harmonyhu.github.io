---
layout: single
title: Safetensors文件格式
categories:
  - AI
tags:
  - 网络模型
---

* content
{:toc}
  

## 基本介绍

* 本文出处：[Safetensors](https://huggingface.co/docs/safetensors/index)
* 一种tensors的存储格式，读写速度快，常用于huggingface上权重的存储
* 安装方法：`pip3 install safetensors`



<!--more-->

## 使用方法

加载tensors:

``` python
# ======= 方式一 =================
from safetensors import safe_open

tensors = {}
with safe_open("model.safetensors", framework="pt", device=0) as f:
    for k in f.keys():
        tensors[k] = f.get_tensor(k)

# ======= 方式二 =================
from safetensors.torch import load_file
tensors = load_file("model.safetensors", device="cuda:0") # torch tensor

# ======= 方式三 =================
from safetensors.numpy import load_file
tensors = load_file("model.safetensors") # numpy tensor
```

加载部分tensor，常用于多设备:

``` python
from safetensors import safe_open

tensors = {}
with safe_open("model.safetensors", framework="pt", device=0) as f:
    tensor_slice = f.get_slice("embedding")
    vocab_size, hidden_dim = tensor_slice.get_shape()
    tensor = tensor_slice[:, :hidden_dim]
```

保存tensors:

``` python
# ======= 方式一 =================
import torch
from safetensors.torch import save_file

tensors = {
    "embedding": torch.zeros((2, 2)),
    "attention": torch.zeros((2, 3))
}
save_file(tensors, "model.safetensors") # torch tensor

# ======= 方式二 =================
from safetensors.numpy import save_file
import numpy as np

tensors = {"embedding": np.zeros((512, 1024)), "attention": np.zeros((256, 256))}
save_file(tensors, "model.safetensors")
```



## 数据存储

![](https://harmonyhu.github.io/img/safetensors-format.svg)
