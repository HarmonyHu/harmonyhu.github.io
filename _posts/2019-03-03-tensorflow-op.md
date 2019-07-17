---
layout: post
title: tensorflow：添加新OP
categories: 深度学习
tags: TensorFlow
---

* content
{:toc}

## 一、注册OP

```c++
REGISTER_OP("Concat")
    .Input("concat_dim: int32")
    .Input("values: N * T")
    .Output("output: T")
    .Attr("N: int >= 2")
    .Attr("T: type")
    .SetShapeFn([](InferenceContext* c) {
      return shape_inference::ConcatShape(c, c->num_inputs() - 1);
    });
```

以Concat为例，它描述维度合并算法，比如[1,2,3]与[4,2,3]在0维度合并，则输出为[5,2,3]。

* `.Input` 与 `.Output` 代表输入输出，形式如`<name> : <io-type-expr>`

  * `<type>`， 基本类型比如float，int32，string等等

  * `<attr-type>`, 属性类型，比如：

    ```c++
    REGISTER_OP("PolymorphicSingleInput")
          .Attr("T: type")
          .Input("in: T);
    REGISTER_OP("RestrictedPolymorphicSingleInput")
          .Attr("T: {int32, int64}")
          .Input("in: T);
    REGISTER_OP("ArbitraryTensorSequenceExample")
          .Attr("T: list(type)")
          .Input("in: T")
          .Output("out: T");
    REGISTER_OP("RestrictedTensorSequenceExample")
          .Attr("T: list({int32, int64})")
          .Input("in: T")
          .Output("out: T");
    ```

  * `<number> * <type>`，一组相同类型的tensor

* `.Attr` 描述属性，形式如`<name>: <attr-type-expr>`，比如上面的N与T，可以在Kernel构造函数中这样获得：

  ```c++
  OP_REQUIRES_OK(context, context->GetAttr("N", &N_));
  OP_REQUIRES_OK(context, context->GetAttr("T", &T_));
  ```

  属性类型：

  * `string`,  `int`,  `float`,  `bool`
  * `type`  ： DataType中的非引用类型
  * `shape`  ： TensorShapeProto
  * `tensor` ：TensorProto)
  * `list(<type>)` ：以上类型的列表

  约束条件：

  * `{<type1>, <type2>}`，必须是type1或type2中的一种类型

  * `{'<string1>', '<string2>'}`，必须是字符串，且是string1或者string2中的一个

  * `numbertype`，数字类型

  * `realnumbertype`, 不支持复杂类型的`numbertype`

  * `quantizedtype`, 只支持量化数值类型

  * `int >= 2`，必须是int类型，取值大于等于2

  * `list(<type>) >= 2`， 列表长度必须大于等于2，比如：

    ```c++
    REGISTER_OP("TypeListExample")
          .Attr("a: list({int32, float}) >= 3");
    ```

  * `= <default>`，设置默认值，比如：

    ```c++
    REGISTER_OP("AttrDefaultExampleForAllTypes")
       .Attr("s: string = 'foo'")
       .Attr("i: int = 0")
       .Attr("f: float = 1.0")
       .Attr("b: bool = true")
       .Attr("ty: type = DT_INT32")
       .Attr("sh: shape = { dim { size: 1 } dim { size: 2 } }")
       .Attr("te: tensor = { dtype: DT_INT32 int_val: 5 }")
       .Attr("l_empty: list(int) = []")
       .Attr("l_int: list(int) = [2, 3, 5, 7]");
    ```

  多态：

  * 比如输入和输出必须是同类型，且是float或者int32，如下：

    ```c++
    REGISTER_OP("ZeroOut")
        .Attr("T: {float, int32} = DT_INT32")
        .Input("to_zero: T")
        .Output("zeroed: T");
    ```

  * 输出类型自动推断，如下：

    ```c++
    REGISTER_OP("StringToNumber")
         .Input("string_tensor: string")
         .Output("output: out_type")
         .Attr("out_type: {float, int32}");
    ```

    

* `.SetShapeFn` 用来配置shape的回调函数，也就是输出的shape与输入之间的算法关系。比如ConcatShape函数如下：

  ```c++
  Status ConcatShape(InferenceContext* c, int num_inputs_to_concat) {
    return ConcatShapeHelper(c, 1 /* start_value_index */,
                             1 + num_inputs_to_concat /* end_value_index */,
                             0 /* dim_index */);
  }
  ```

  

## 二、实现Kernel

```c++
// for cpu
#define REGISTER_CONCAT(type)                            \
  REGISTER_KERNEL_BUILDER(Name("Concat")                 \
                              .Device(DEVICE_CPU)        \
                              .TypeConstraint<type>("T") \
                              .HostMemory("concat_dim"), \
                               ConcatOp<CPUDevice, type>)
REGISTER_CONCAT(quint8);
REGISTER_CONCAT(qint8);
REGISTER_CONCAT(quint16);
REGISTER_CONCAT(qint16);
REGISTER_CONCAT(qint32);

// for GPU CUDA
#define REGISTER_GPU(type)                               \
  REGISTER_KERNEL_BUILDER(Name("Concat")                 \
                              .Device(DEVICE_GPU)        \
                              .TypeConstraint<type>("T") \
                              .HostMemory("concat_dim"), \
                              ConcatOp<GPUDevice, type>)
REGISTER_GPU(bfloat16);
```

