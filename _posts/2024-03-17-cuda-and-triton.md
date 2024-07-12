---
layout: single
title: CUDA与Triton
categories:
  - AI
tags:
  - 编程
---

* content
{:toc}
## 并行计算术语

| 名词 | 全称                                | 注解                                                         |
| ---- | ----------------------------------- | ------------------------------------------------------------ |
| SI   | Single Instruction                  | 指单一指令，一个时钟执行单一指令。即便多个处理单元，也执行一样的指令。 |
| SD   | Single Data                         | 指单一数据，一个时钟一条数据。即便多个处理单元，也使用相同的数据。 |
| MI   | Multiple Instruction                | 指多指令，不同处理单元处理不同的指令。                       |
| MD   | Multiple Data                       | 指多数据，不同的处理单元处理不同的数据。                     |
| SISD | Single Instruction, Single Data     | 串行计算，传统单核芯片属于该类                               |
| SIMD | Single Instruction, Multiple Data   | 单指令多数据流，典型的可以支持向量计算，对不同的数据使用相同的指令。一般现代CPU都会支持SIMD指令。 |
| MISD | Multiple Instruction, Single Data   | 多指令单数据流，几乎不存在这样的架构                         |
| MIMD | Multiple Instruction, Multiple Data | 多指令多数据流。多核处理器都是属于这个范畴                   |
| SIMT | Single Instruction Multiple Threads | 单指令多线程，每个线程处理相同的指令和不同的数据。可以认为是SIMD的升级版，个人理解它们的区别在于：SIMD的数据必须是向量形式的数据，SIMT的数据则没有形式的要求。所以SIMT可以更加灵活。现代GPU一般都是SIMT。 |
| SPMD | Simple Program, Multiple Data       | 单程序多数据，一种编程概念，用于数据并行的应用。一般MIMD或者SIMT，可以支持SPMD |

<!--more-->



## CUDA

#### 概述

1) cuda编程与c语言编程大体相同，区别在于SIMT，在GPU上的程序被多个线程执行。如何划分线程，需要理解grid概念。

* Grids: 网格，最上层的概念，一个网格包含多个Blocks。一个Host端函数定义一个Grid。
* Blocks: 块，一个块由多个Threads组成，块内thread可以通过共享数据和同步执行。
* Threads: 线程，最小执行单位，每个线程执行相同的操作在不同的数据上。

2. 为什么需要Blocks概念，而不是全部用Threads ? 当线程间存在共享或者同步的需求时，可以更好的发挥性能。
3. 一个Grid可以定义1D/2D/3D维度的Blocks，一个Blocks也可以定义1D/2D/3D维度的threads。在没有共享或同步的需要时，建议都用1D定义。
4. cuda程序文件后缀为`.cu`，用nvcc编译，该文件可以定义device端接口和host端接口。host接口可以被`.cpp`文件调用。

#### 编程示范

cuda编程主要有两个修饰符，一个是`__device__`，另一个`__global__`，前者用于定义一个device调用的device接口，后者用于定义一个host端调用的device接口。

本文用一个浮点型到整型的转换举例。

以下定义一个`__device__`接口（它支持模版）：

``` c++
template <typename T>
__device__ T device_float_to_int(float data, bool rounding_up) {
  data = rounding_up ? floor(data+0.5f) : trucf(data);
  if (std::is_same<T, int8_t)::value) {
    data = fmaxf(-128.0f, fminf(127.0f, data));
  }
  return static_cast<T>(data);
}
```

定义一个`__global__`接口（它也支持模板）：

```c++
template <typename T>
__global__ void global_float_to_int(float * input, T * output, int num, bool rounding_up) {
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < num) {
		output[idx] = device_float_to_int<T>(input[idx], rounding_up);
	}
}
```

定义一个host端接口：

``` c++
void float_to_int8(void * input, void *output, int num, bool rounding_up) {
  int num_threads = 256;
  int num_blocks = (num + 255)/256;
  global_float_to_int<<<num_blocks, num_threads>>>((float*)input, (int8_t*)output, num, rouding_up);
}
```

编写`CMakeLists.txt`，如下：

``` cmake
cmake_minimum_required(VERSION 3.18)
project(sample LANGUAGES CXX CUDA)

enable_language(CUDA)

set(CMAKE_CUDA_ARCHITECTURES 60;61;70;75;80;86)

set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -fPIC")

add_library(sample STATIC sample.cu)

target_include_directories(sample PUBLIC
  ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

set_target_properties(sample PROPERTIES
                      LINKER_LANGUAGE CUDA)
```



## Triton

#### 概述

1. 这里Triton指OpenAI的Triton项目，[源码](https://github.com/triton-lang/triton)，[官网](https://triton-lang.org/main/index.html)

2. Trion可以简单的理解为Python版本的Cuda，它的目标是实现Torch到AI芯片的对接，目前主要支持Nvidia芯片。从它编程语言来看，它是SPMD编程，如果要支持其他芯片，最好也是SIMT架构的芯片。
3. Trion去掉了threads这一层，只保留blocks。每个接口处理多个thread，这样编程更简洁。另外个人认为，并且对于向量化的数据计算性能应该容易优化，因为可以load和store连续的数据，带宽利用更高。



#### 编程示范

用Triton重写上述例子，如下：

``` python
#!/usr/bin/env python3

import torch
import triton
import triton.language as tl


@triton.jit
def float_to_int32_kernel(input, output, num, rounding_up, BLOCK_SIZE: tl.constexpr):
    idx = tl.program_id(0) * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = idx < num
    data = tl.load(input + idx, mask=mask)
    if rounding_up:
        data = tl.floor(data + 0.5)
    converted_data = tl.cast(data, tl.int32)
    tl.store(output + idx, converted_data, mask=mask)


def float_to_int(input: torch.Tensor, output: torch.Tensor, rounding_up: bool):
    assert (input.dtype == torch.float32)
    assert (input.numel() == output.numel())
    num = input.numel()
    BLOCK_SIZE = 256
    grid = (triton.cdiv(num, 256),)
    if output.dtype == torch.int32:
        float_to_int32_kernel[grid](
            input, output, num, rounding_up, BLOCK_SIZE)
    else:
        raise RuntimeError("Not Implemented")


input = torch.randn(20, dtype=torch.float32, device="cuda")
output = torch.empty(20, dtype=torch.int32, device="cuda")
float_to_int(input, output, True)
print(input)
print(output)
```

可以看出Triton基本与Cuda是非常相似的，基于Python用起来是非常方便的，但是Triton也有些不便之处：

* Triton无法支持模版化编程，Cuda是可以的。
* Triton主要对接Torch，支持的数据类型也受限于Torch，比如Torch不支持uint16/uint32。但Cuda没有这个限制。
