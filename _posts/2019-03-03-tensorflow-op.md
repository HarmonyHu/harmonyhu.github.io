---
layout: post
title: tensorflow：添加新OP和新设备
categories: 深度学习
tags: TensorFlow
---

* content
{:toc}
* REGISTER_OP，注册一个OP，其实也是声明一个OP
* REGISTER_KERNEL_BUILDER，注册一个Kernel，其实就是对OP的实现
* REGISTER_LOCAL_DEVICE_FACTORY，添加设备工厂

<!--more-->

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

#### 输入输出

`.Input` 与 `.Output` 代表输入输出，形式如`<name> : <io-type-expr>`

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

#### 属性

`.Attr` 描述属性，形式如`<name>: <attr-type-expr>`，比如上面的N与T，可以在Kernel构造函数中这样获得：

```c++
OP_REQUIRES_OK(context, context->GetAttr("N", &N_));
OP_REQUIRES_OK(context, context->GetAttr("T", &T_));
```

属性类型：

* `string`,  `int`,  `float`,  `bool`
* `type`  ： DataType中的非引用类型
* `shape`  ： TensorShapeProto
* `tensor` ：TensorProto
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


#### Shape回调函数

`.SetShapeFn` 用来配置shape的回调函数，也就是输出的shape与输入之间的算法关系。比如ConcatShape函数如下：

```c++
Status ConcatShape(InferenceContext* c, int num_inputs_to_concat) {
  return ConcatShapeHelper(c, 1 /* start_value_index */,
                           1 + num_inputs_to_concat /* end_value_index */,
                           0 /* dim_index */);
}
```



## 二、注册Kernel

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
#define REGISTER_GPU(type)                           \
  REGISTER_KERNEL_BUILDER(Name("Concat")             \
                          .Device(DEVICE_GPU)        \
                          .TypeConstraint<type>("T") \
                          .HostMemory("concat_dim"), \
                          ConcatOp<GPUDevice, type>)
REGISTER_GPU(bfloat16);
```

以上注册了各种类型的基于CPU的kernel，以及基于CUDE的float16的kernel。

* `Name("Concat")`，对应OP的名称

* `.Device(DEVICE_GPU)`，对应执行OP的设备

* `.TypeContraint<bfloat16>("T")`，对应OP的数据类型

* `.HostMemory("concat_dim")`，将`concat_dim`标记为系统内存输入

* `ConcatOp<GPUDevice， bfloat16>`，是一个类，继承OpKernel，定义类似如下：

  ```c++
  template <typename Device, typename T, AxisArgumentName AxisArgName>
  class ConcatBaseOp : public OpKernel {
   public:
    typedef std::vector<std::unique_ptr<typename TTypes<T, 2>::ConstMatrix>>
        ConstMatrixVector;
  
    explicit ConcatBaseOp(OpKernelConstruction* c) : OpKernel(c) {}
  
    void Compute(OpKernelContext* c) override {
      const Tensor* concat_dim_tensor;
      const char* axis_attribute_name = "concat_dim";
      OP_REQUIRES_OK(c, c->input(axis_attribute_name, &concat_dim_tensor));
      ...
    }
  };
  template <typename Device, typename T>
  using ConcatOp = ConcatBaseOp<Device, T, NAME_IS_CONCAT_DIM>;
  ```

  这个类需要实现构造函数，和Compute方法

  

## 三、注册新设备

#### 定义设备名称

```c++
namespace tensorflow {
const char* const DEVICE_GPU = "GPU";
}
```

#### 创建设备类，继承LocalDevice

```c++
class BaseGPUDevice : public LocalDevice {
 public:
  BaseGPUDevice(const SessionOptions& options, const string& name,
                Bytes memory_limit, const DeviceLocality& locality,
                TfGpuId tf_gpu_id, const string& physical_device_desc,
                Allocator* gpu_allocator, Allocator* cpu_allocator,
                bool sync_every_op, int32 max_streams);
  ~BaseGPUDevice() override;
  void Compute(OpKernel* op_kernel, OpKernelContext* context) override;
  Status Sync() override;
  void ComputeAsync(AsyncOpKernel* op_kernel, OpKernelContext* context,
                    AsyncOpKernel::DoneCallback done) override;
  Status FillContextMap(const Graph* graph,
                        DeviceContextMap* device_context_map) override;
  ......
 private:
  std::vector<GPUDeviceContext*> device_contexts_;
};

class GPUDevice : public BaseGPUDevice {
 public:
  GPUDevice(const SessionOptions& options, const string& name,
            Bytes memory_limit, const DeviceLocality& locality,
            TfGpuId tf_gpu_id, const string& physical_device_desc,
            Allocator* gpu_allocator, Allocator* cpu_allocator);

  Allocator* GetAllocator(AllocatorAttributes attr) override;
};
```

#### 创建设备工厂类，继承DeviceFactory

```c++
class BaseGPUDeviceFactory : public DeviceFactory {
 public:
  Status CreateDevices(const SessionOptions& options, const string& name_prefix,
                       std::vector<std::unique_ptr<Device>>* devices) override;
};

class GPUDeviceFactory : public BaseGPUDeviceFactory {
 private:
  std::unique_ptr<BaseGPUDevice> CreateGPUDevice(
      const SessionOptions& options, const string& name, Bytes memory_limit,
      const DeviceLocality& locality, TfGpuId tf_gpu_id,
      const string& physical_device_desc, Allocator* gpu_allocator,
      Allocator* cpu_allocator) override {
    return absl::make_unique<GPUDevice>(options, name, memory_limit, locality,
                                        tf_gpu_id, physical_device_desc,
                                        gpu_allocator, cpu_allocator);
  }
};

REGISTER_LOCAL_DEVICE_FACTORY("GPU", GPUDeviceFactory, 210);
```

#### 创建上下文，继承DeviceContext

```c++
class GPUDeviceContext : public DeviceContext {
 public:
  // Does not take ownership of streams.
  GPUDeviceContext(int stream_id, se::Stream* stream,
                   se::Stream* host_to_device_stream,
                   se::Stream* device_to_host_stream,
                   gtl::InlinedVector<se::Stream*, 4> device_to_device_stream);
  ~GPUDeviceContext() override {}
  void CopyCPUTensorToDevice(const Tensor* cpu_tensor, Device* device,
                             Tensor* device_tensor,
                             StatusCallback done) const override;

  void CopyDeviceTensorToCPU(const Tensor* device_tensor, StringPiece edge_name,
                             Device* device, Tensor* cpu_tensor,
                             StatusCallback done) override;

  void CopyTensorInSameDevice(const Tensor* input_tensor, Device* device,
                              Tensor* output_tensor,
                              StatusCallback done) const override;
  ......
};
```

该context可以在OpKernelContext中得到，如下：

```c++
void BaseGPUDevice::ComputeHelper(OpKernel* op_kernel,
                                  OpKernelContext* context) {
  GPUDeviceContext* gpu_device_context = device_contexts_[0];
  if (context->op_device_context() != nullptr) {
    gpu_device_context =
        static_cast<GPUDeviceContext*>(context->op_device_context());
  }
  ......
}
```

通常在LocalDevice::FillContextMap中填入，如下：

```c++
Status BaseGPUDevice::FillContextMap(const Graph* graph,
                                     DeviceContextMap* device_context_map) {
  ......
  for (Node* n : graph->nodes()) {
    auto mapped_stream = node_to_stream_id[n->id()];
    CHECK_LE(mapped_stream, num_streams);
    auto ctx = device_contexts_[mapped_stream];
    VLOG(3) << "Assigned stream " << node_to_stream_id[n->id()]
            << " ==> stream[" << ctx->stream_id() << "] for node id " << n->id()
            << " " << n->type_string() << " " << n->name();
    ctx->Ref();
    (*device_context_map)[n->id()] = ctx;
  }
  ......
}
```

