---
layout: post
title: tensorflow入门
categories: 深度学习
tags: TensorFlow
---

* content
{:toc}

## 一、图 graph

tensorflow是基于graph的并行计算架构。graph是静态的，构建gragh并不会运行。需要启动一个session，运行graph。比如`a=(b+c)*(c+2)` 的graph如下：（其中b+c 和 c+2是并行的）

![TensorFlow tutorial - simple computational graph](http://adventuresinmachinelearning.com/wp-content/uploads/2017/03/Simple-graph-example-260x300.png)



## 二、张量 Tensor

#### tf.zero

```python
tf.zeros(shape, dtype=tf.float32, name=None)
# shape代表维度形状; dtype代码类型，默认是float32;  name指定任意字符串
tf.zeros([2]) # [0. 0.]
tf.zeros([2,4]) # [[0. 0. 0. 0.] [0. 0. 0. 0.]]
```

#### tf.constant 常量

```python
tf.constant(value, dtype=None, shape=None, name='Const')
# value 张量数值，dtype默认int32
tf.constant(1) # 0阶张量，标量
tf.constant([1, 2]) # 1阶张量，一维数组
tf.constant([[1, 2],[3, 4]]) # 2阶张量，二维数组
tf.constant([['Apple', 'Orange'], ['Potato', 'Tomato']], dtype=tf.string) # 2阶，字符串
```

#### tf.range 序列

```python
range(start, limit, delta=1, dtype=None, name='range')
tf.range(10, 15) # [10 11 12 13 14]
tf.range(3, 1, -0.5) # [3. 2.5 2 1.5]
```

#### tf.random_normal 随机数

```python
tf.random_normal(shape, mean=0.0, stddev=1.0, dtype=tf.float32, seed=None, name=None)
# 正太分布的数值中取指定个数的值
# shape是维度形状，mean是正态分布的均值，stddev是正态分布的标准差
tf.random_normal([2, 3], stddev=1)
#[[-0.81131822  1.48459876  0.06532937]
# [-2.4427042   0.0992484   0.59122431]]
```

## 三、运算

#### 运行规则

* 相同大小 Tensor 之间的任何算术运算都会将运算应用到元素级
* 不同大小 Tensor(要求dimension 0 必须相同) 之间的运算叫做广播(broadcasting)
* Tensor 与 Scalar(0维 tensor) 间的算术运算会将那个标量值传播到各个元素
* TensorFlow 在进行数学运算时，一定要求各个 Tensor 数据类型一致

#### 基本数学运算

```python

# 算术操作符：+ - * / % 
tf.add(x, y, name=None)        # 加法(支持 broadcasting)
tf.subtract(x, y, name=None)   # 减法
tf.multiply(x, y, name=None)   # 乘法
tf.divide(x, y, name=None)     # 浮点除法, 返回浮点数(python3 除法)
tf.mod(x, y, name=None)        # 取余

# 幂指对数操作符：^ ^2 ^0.5 e^ ln 
tf.pow(x, y, name=None)        # 幂次方
tf.square(x, name=None)        # 平方
tf.sqrt(x, name=None)          # 开根号，必须传入浮点数或复数
tf.exp(x, name=None)           # 计算 e 的次方
tf.log(x, name=None)           # 以 e 为底，必须传入浮点数或复数

# 取符号、负、倒数、绝对值、近似、两数中较大/小的
tf.negative(x, name=None)      # 取负(y = -x).
tf.sign(x, name=None)          # 返回 x 的符号
tf.reciprocal(x, name=None)    # 取倒数
tf.abs(x, name=None)           # 求绝对值
tf.round(x, name=None)         # 四舍五入
tf.ceil(x, name=None)          # 向上取整
tf.floor(x, name=None)         # 向下取整
tf.rint(x, name=None)          # 取最接近的整数 
tf.maximum(x, y, name=None)    # 返回两tensor中的最大值 (x > y ? x : y)
tf.minimum(x, y, name=None)    # 返回两tensor中的最小值 (x < y ? x : y)

# 三角函数和反三角函数
tf.cos(x, name=None)    
tf.sin(x, name=None)    
tf.tan(x, name=None)    
tf.acos(x, name=None)
tf.asin(x, name=None)
tf.atan(x, name=None)   

# 其它
tf.div(x, y, name=None)  # python 2.7 除法, x/y-->int or x/float(y)-->float
tf.truediv(x, y, name=None) # python 3 除法, x/y-->float
tf.floordiv(x, y, name=None)  # python 3 除法, x//y-->int
tf.realdiv(x, y, name=None)
tf.truncatediv(x, y, name=None)
tf.floor_div(x, y, name=None)
tf.truncatemod(x, y, name=None)
tf.floormod(x, y, name=None)
tf.cross(x, y, name=None)
tf.squared_difference(x, y, name=None)
```

#### 矩阵函数

```python
# 矩阵乘法(tensors of rank >= 2)
tf.matmul(a, b, transpose_a=False, transpose_b=False,    adjoint_a=False, adjoint_b=False, a_is_sparse=False, b_is_sparse=False, name=None)

# 转置，可以通过指定 perm=[1, 0] 来进行轴变换
tf.transpose(a, perm=None, name='transpose')

# 在张量 a 的最后两个维度上进行转置
tf.matrix_transpose(a, name='matrix_transpose')
# Matrix with two batch dimensions, x.shape is [1, 2, 3, 4]
# tf.matrix_transpose(x) is shape [1, 2, 4, 3]

# 求矩阵的迹
tf.trace(x, name=None)

# 计算方阵行列式的值
tf.matrix_determinant(input, name=None)

# 求解可逆方阵的逆，input 必须为浮点型或复数
tf.matrix_inverse(input, adjoint=None, name=None)

# 奇异值分解
tf.svd(tensor, full_matrices=False, compute_uv=True, name=None)

# QR 分解
tf.qr(input, full_matrices=None, name=None)

# 求张量的范数(默认2)
tf.norm(tensor, ord='euclidean', axis=None, keep_dims=False, name=None)

# 构建一个单位矩阵, 或者 batch 个矩阵，batch_shape 以 list 的形式传入
tf.eye(num_rows, num_columns=None, batch_shape=None, dtype=tf.float32, name=None)
# Construct one identity matrix.
tf.eye(2) ==> [[1., 0.],[0., 1.]]
 
# Construct a batch of 3 identity matricies, each 2 x 2.
# batch_identity[i, :, :] is a 2 x 2 identity matrix, i = 0, 1, 2.
batch_identity = tf.eye(2, batch_shape=[3])
 
# Construct one 2 x 3 "identity" matrix
tf.eye(2, num_columns=3) ==> [[ 1.,  0.,  0.], [ 0.,  1.,  0.]]

# 构建一个对角矩阵，rank = 2*rank(diagonal)
tf.diag(diagonal, name=None)
# 'diagonal' is [1, 2, 3, 4]
tf.diag(diagonal) ==> [[1, 0, 0, 0]
                       [0, 2, 0, 0]
                       [0, 0, 3, 0]
                       [0, 0, 0, 4]]
```



## 四、变量 Variable

#### tf.Variable 定义

```python
tf.Variable(initial_value, trainable=True, collections=None, validate_shape=True, name=None)
# initial_value 初始值；trainable为true时加入到GraphKeys,会被使用Optimizer；
# collections 变量类型，默认为GraphKeys.GLOBAL_VARIABLE
# validate_shape 类型和维度检查
# name 指定变量名称，如果没有则系统生成

# 举例：Create two variables.
weights = tf.Variable(tf.random_normal([784, 200], stddev=0.35),name="weights")
biases = tf.Variable(tf.zeros([200]), name="biases")
# 举例：当一个变量依赖另一个变量
weights2 = tf.Variable(weights.initialized_value() * 0.2, name="w2")
```

#### 初始化

变量的初始化需要在模型中执行，单个变量初始化如下：

```python
# 在session中启动graph.
with tf.Session() as sess:
    # variable初始化.
    sess.run(weights.initializer)
    # ...现在可以运行使用'weights'的op...
```

可以使用`tf.global_variables_initializer()`操作完成所有变量初始化，如下：

```python
# Add an op to initialize the variables.
init_op = tf.global_variables_initializer()

# Later, when launching the model
with tf.Session() as sess:
  # Run the init operation.
  sess.run(init_op)
  # Use the model
  ...
```

#### 保存与恢复

用`tf.train.Saver()`创建`Saver`来保存所有的变量，如下：

```python
# Add ops to save and restore all the variables.
saver = tf.train.Saver()

# Later, launch the model, initialize the variables, do some work, save the
# variables to disk.
with tf.Session() as sess:
  sess.run(init_op)
  # Do some work with the model.
  ..
  # Save the variables to disk.
  save_path = saver.save(sess, "/tmp/model.ckpt")
  print "Model saved in file: ", save_path
```

同样使用Saver恢复变量，当要从文件恢复变量时不需要对它们初始化，如下：

```python
# Add ops to save and restore all the variables.
saver = tf.train.Saver()

# Later, launch the model, use the saver to restore variables from disk, and
# do some work with the model.
with tf.Session() as sess:
  # Restore variables from disk.
  saver.restore(sess, "/tmp/model.ckpt")
  print "Model restored."
  # Do some work with the model
  ...
```

## 五、会话 Session

用于执行graph。有两种方式，方式一如下：

```python
import tensorflow as tf

matrix1 = tf.constant([[3, 3]])
matrix2 = tf.constant([[2],[2]])
product = tf.matmul(matrix1, matrix2)  # matrix multiply np.dot(m1, m2)

# method 1
sess = tf.Session()
result = sess.run(product)
print(result)
sess.close()

# method 2
with tf.Session() as sess:
    result2 = sess.run(product)
    print(result2)
```

## 六、占位 placeholder

在构建graph时没有传入数据，等建立session后，在session中通过`feed_dict()`函数传入数据。

```python
tf.placeholder(dtype,shape=None,name=None)
# dtype：数据类型。常用的是tf.float32,tf.float64等数值类型
# shape：数据形状。默认是None，就是一维值，也可以是多维（比如[2,3], [None, 3]表示列是3，行不定）
# name：名称

# 举例如下：
import tensorflow as tf
import numpy as np
 
x = tf.placeholder(tf.float32, shape=(1024, 1024))
y = tf.matmul(x, x)
 
with tf.Session() as sess:
    #print(sess.run(y))  # ERROR:此处x还没有赋值
    rand_array = np.random.rand(1024, 1024)
    print(sess.run(y, feed_dict={x: rand_array})) 
```

## 七、简单代码范例

用TensorFlow计算`a = (b+c) * (c+2)`，参考学习：[python-tensorflow-tutorial](http://adventuresinmachinelearning.com/python-tensorflow-tutorial/)

#### 定义数据

```python
import tensorflow as tf

# first, create a TensorFlow constant
const = tf.constant(2.0, name="const")
    
# create TensorFlow variables
b = tf.placeholder(tf.float32, name='b')
c = tf.placeholder(tf.float32, name='c')
```

#### 构建操作

```python
# 创建operation
d = tf.add(b, c, name='d')
e = tf.add(c, const, name='e')
a = tf.multiply(d, e, name='a')
```

#### 创建会话

```python
# session
with tf.Session() as sess:
    a_out = sess.run(a, feed_dict={b:[2, 3, 4], c:1})
    print("Variable a is {}".format(a_out))
# 打印结果如下：
# Variable a is [ 9. 12. 15.]
```

