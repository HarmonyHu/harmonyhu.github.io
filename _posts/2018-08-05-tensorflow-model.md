---
layout: article
title: tensorflow的模型设计
categories: AI
tags: TensorFlow
---

* content
{:toc}

## 一、简单模型设计

如下模型（ 参见：[神经网络反向推导](http://harmonyhu.com/2018/05/23/neural-network/) )

![](https://harmonyhu.github.io/img/neuron.jpg)

<!--more-->

#### 定义输入和输出

```python
import tensorflow as tf

input_data  = tf.placeholder(tf.float32,[1,2])
target_data = tf.placeholder(tf.float32,[1,2])
input_sample = [[0.05, 0.10]]
target_sample = [[0.01, 0.99]]
```

#### 构建运算模型

```python
weight1 = tf.Variable([[0.15, 0.25],[0.2, 0.3]])
bias1 = tf.Variable(0.35)
weight2 = tf.Variable([[0.4, 0.5],[0.45,0.55]])
bias2 = tf.Variable(0.6)
net_h = tf.matmul(input_data, weight1) + bias1
out_h = tf.sigmoid(net_h)
net_o = tf.matmul(out_h, weight2) + bias2
output_data = tf.sigmoid(net_o)
```

#### 构建损失模型和优化模型

```python
# 对应上图中的总误差公式
loss = tf.reduce_sum(tf.divide(tf.square(target_data - output_data),2))
optimizer = tf.train.GradientDescentOptimizer(0.001)
train = optimizer.minimize(loss)
```

#### 创建会话和训练

```python
# 创建会话，初始化变量
init_op = tf.global_variables_initializer()
sess = tf.Session()
sess.run(init_op)
# 训练
for i in range(1000):
    sess.run(train, {input_data: input_sample, target_data: target_sample})
```

#### 打印结果和关闭会话

```python
print('W1: %s\n B1: %s\n W2: %s\n B2: %s\n loss: %s\n' % (
     sess.run(weight1), sess.run(bias1),
     sess.run(weight2), sess.run(bias2),
     sess.run(loss, {input_data: input_sample, target_data: target_sample})))
sess.close()
```

打印结果如下：

```shell
W1: [[0.14963605 0.24957643]
 [0.19927175 0.29915288]]
B1: 0.33424386
W2: [[0.3163322  0.52373576]
 [0.3658201  0.57388127]]
B2: 0.4986292
loss: 0.27261934
```

## 二、TensorBoard可视化

#### tf.summary

```python
# 跟踪标量信息
tf.summary.scalar(tags, values, collections=None, name=None)

# 将所有信息保存到磁盘
tf.summary.merge_all()

# 将训练数据保存到文件中
writer = tf.summary.FileWritter(path,sess.graph)

# 按训练步数保存数据
writer.add_summary(train_summary,step)
```

#### 如何支持TensorBoard

1. 修改部分代码如下：

   ```python
   # 跟踪loss信息
   tf.summary.scalar("loss", loss)
   # 定义writer
   merged = tf.summary.merge_all()
   writer = tf.summary.FileWriter('/tmp/mytensor', sess.graph)
   # 训练过程中按步进记录数据
   for i in range(1000):
       summary, train_ = sess.run([merged, train], {input_data: input_sample, target_data: target_sample})
       writer.add_summary(summary, i)
   ```

2. 另起一个终端，执行tensorboard，如下：

   ```shell
   $ tensorboard --logdir /tmp/tensorflow
   ```

3. 浏览器中打开<http://localhost:6006>，就可以看到模型数据了，如下图：

   ![](https://harmonyhu.github.io/img/tensorboard.jpg)

   ![](https://harmonyhu.github.io/img/tensorboard2.jpg)