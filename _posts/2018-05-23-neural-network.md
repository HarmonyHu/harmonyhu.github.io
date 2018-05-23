---
layout: post
title: 学习笔记:神经网络反向推导
categories: 深度学习
tags: 深度学习 反向推导
---

* content
{:toc}

## 笔记说明

学习文章：[深度学习---反向传播的具体案例](https://zhuanlan.zhihu.com/p/23270674)

简单网络描述如下：

![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/neuron.jpg)  



## 反向传播过程

首先正常传播，计算出总误差；反向传播就是为了计算总误差与待更新值得导数（权值）。而导数其实是反映权值对总误差的影响（变化率）。

总误差公式：  
$$
E_{total} = \frac{1}{2} [(0.01-out_{o1})^2 +(0.99 - out_{o2})^2] (0.01和0.99是预期值)
$$
总误差对w5求导：  
$$
\frac{\Delta E_{total}}{\Delta w5}  = \frac{\Delta E_{total}}{\Delta out_{o1}}  \times \frac{\Delta out_{o1}}{\Delta net_{o1}} \times \frac{\Delta net_{o1}}{\Delta w5}
$$
总误差对out_o1求导：  
$$
\frac{\Delta E_{total}}{\Delta out_{o1}} = 2*\frac{1}{2} *(0.01 - out_{o1}) *(-1) = out_{o1} - 0.01
$$
out_o1对net_o1求导：  
$$
\frac{\Delta out_{o1}}{\Delta net_{o1}} = out_{o1} \times (1 - out_{o1})
$$
net_o1对w5求导：  
$$
\frac{\Delta net_{o1}}{\Delta w5} = out_{h1}
$$
于是可以算出总误差对w5的导数值R，假如学习率为0.5，则w5更新后为  
$$
w5_{new} = w5 - 0.5 \times R
$$
以此类推，更新所有权值，之后重复。

注意总误差对out_h1求导：  
$$
\frac{\Delta E_{total}}{\Delta out_{h1}}  = \frac{\Delta E_{total}}{\Delta net_{o1}}  \times \frac{\Delta net_{o1}}{\Delta out_{h1}} + \frac{\Delta E_{total}}{\Delta net_{o2}}  \times \frac{\Delta net_{o2}}{\Delta out_{h1}}
$$

## 草稿求导过程

```
ΔE/Δout_o1 = (target-out_o1)*(-1) = R1
ΔE/Δout_o2 = (target-out_o2)*(-1) = R2
Δout_o1/Δnet_o1 = out_o1*(1-out_o1) = R3
Δout_o2/Δnet_o2 = out_o2*(1-out_o2) = R4
Δnet_o1/Δw5 = out_h1 = R5
Δnet_o1/Δw6 = out_h2 = R6
Δnet_o2/Δw7 = out_h1 = R7
Δnet_o2/Δw8 = out_h2 = R8
=> ΔE/Δw5 = R1 * R3 * R5
=> ΔE/Δw6 = R1 * R3 * R6
=> ΔE/Δw7 = R2 * R4 * R7
=> ΔE/Δw8 = R2 * R4 * R8

Δnet_o1/Δout_h1 = w5 = R9
Δnet_o2/Δout_h1 = w7 = R10
Δnet_o1/Δout_h2 = w6 = R11
Δnet_o2/Δout_h2 = w8 = R12
=> ΔE/Δout_h1 = R1 * R3 * R9 + R2 * R4 * R10 = R13
=> ΔE/Δout_h2 = R1 * R3 * R11 + R2 * R4 * R12 = R14

Δout_h1/Δnet_h1 = out_h1*(1-out_h1) = R15
Δout_h2/Δnet_h2 = out_h2*(1-out_h2) = R16
Δnet_h1/Δw1 = i1 = R17
Δnet_h1/Δw2 = i2 = R18
Δnet_h2/Δw3 = i1 = R19
Δnet_h2/Δw4 = i2 = R20
=> ΔE/Δw1 = R13 * R15 * R17
=> ΔE/Δw2 = R13 * R15 * R18
=> ΔE/Δw3 = R14 * R16 * R19
=> ΔE/Δw4 = R14 * R16 * R20
```



## RUBY 实现

[Neuron.rb](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/other/Neuron.rb)