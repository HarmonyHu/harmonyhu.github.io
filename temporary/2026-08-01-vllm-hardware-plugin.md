---
layout: single
title: vLLM硬件插件机制整理（NPU适配方向）
categories:
  - AI
tags:
  - AI
  - tools
---



* content
{:toc}

<!--more-->

学习目标：了解如何在不修改vLLM代码的前提下，通过Hardware Plugin机制将vLLM适配到自研NPU上。

## 一、核心机制：vLLM插件系统

vLLM基于Python的`entry_points`机制发现和加载插件，无需fork vLLM代码。由于vLLM是多进程架构（TP/DP场景下每个Worker是独立进程），**每个进程启动时都会独立加载插件**，所以插件的注册函数必须是无副作用、可重复执行的。

与硬件适配相关的两类插件：

* `vllm.platform_plugins`：注册自定义硬件平台。插件函数先检测当前环境，硬件存在时返回Platform类的全限定名，不存在时返回`None`。
* `vllm.general_plugins`：注册自定义算子（用硬件专用kernel覆盖vLLM默认实现）和自定义模型。

插件包`setup.py`的典型写法（参考Intel Gaudi插件）：

``` python
entry_points={
    "vllm.platform_plugins": ["npu = vllm_npu:register"],
    "vllm.general_plugins": ["npu_ops = vllm_npu:register_ops"],
}
```

这套机制由三个RFC演进而来：

1. Plugin System RFC：引入基于`entry_points`的插件架构
2. Device-Agnostic RFC：把硬件相关代码收敛到`vllm/platforms/`子模块，消除散落的`if cuda: else:`判断
3. Hardware Pluggable RFC：Platform本身也变成插件，硬件后端可以完全out-of-tree注册

官方背书的最佳实践是华为的vllm-ascend，参见官方博客 [Introducing vLLM Hardware Plugin](https://vllm.ai/blog/2025-05-12-hardware-plugin)。

## 二、需要实现的组件栈

按vllm-ascend的分层，从底到上：

### Platform

入口组件，工作量最小。参考`vllm/platforms/interface.py`（抽象基类，定义了需要实现的全部接口）和`vllm/platforms/cuda.py`（最完整的参考实现）。职责包括：

* 设备探测与枚举
* 显存管理（查询剩余显存、设置device等）
* 声明默认的attention backend、量化方式、executor类型
* 检查并更新vLLM配置（`check_and_update_config`）

### Executor / Worker / ModelRunner

与vLLM进程架构中的层级一致。大部分逻辑可继承GPU的默认实现，只重写设备相关部分：

* `Worker`：绑定NPU设备、初始化通信、做profile run（测出可用KV cache大小）
* `ModelRunner`：准备输入tensor、执行前向、采样

### AttentionBackend

最关键的算力点。PagedAttention的prefill/decode kernel需要在NPU上有实现，三条路线（按工作量递增）：

1. 先用fallback（torch参考实现）：慢，但用于对齐正确性
2. 调用NPU算子库中已有的attention算子
3. 自研融合kernel：性能最优

### 通信层

TP/DP所需的AllReduce/All-to-All需要NPU的集合通信库（Ascend对应HCCL），需要一个Communicator适配层对上提供NCCL兼容的接口。

### Custom Ops

通过`general_plugins`把RotaryEmbedding、RMSNorm、SwiGLU等算子替换为NPU融合算子。vLLM的自定义算子体系（`CustomOp`基类）天然支持这种覆盖：`CustomOp.forward_native()`是纯torch实现，`forward_npu()`这类方法由平台插件按设备名分发。

### 图捕获

CUDA Graph的等价物（Ascend是aclgraph），用于消除decode阶段的kernel launch开销，是decode性能的关键。可以放到后期再做。

## 三、前提条件（在vLLM之外）

* **PyTorch能跑在NPU上**：PyTorch的`PrivateUse1`机制允许out-of-tree设备后端（torch_npu即基于此实现）。vLLM插件假设`torch.Tensor`已能在目标设备上分配和计算。
* 可用的集合通信库。
* 基础算子库（matmul、layernorm等）。

## 四、动手顺序建议

1. Platform跑通单卡eager推理（先保证正确性，attention用fallback实现）
2. Attention backend切换为NPU kernel（性能主体）
3. 通信层适配，支持TP多卡
4. Custom ops逐个替换为融合算子
5. 图捕获、量化等高级特性

## 五、学习材料

* [Plugin System 官方文档](https://docs.vllm.ai/en/latest/design/plugin_system/)
* [Introducing vLLM Hardware Plugin（官方博客，Ascend实践）](https://vllm.ai/blog/2025-05-12-hardware-plugin)
* 源码：`vllm/platforms/interface.py`、`vllm/platforms/cuda.py`
* 参考实现：[vllm-ascend](https://github.com/vllm-project/vllm-ascend)（与NPU场景最接近）、[vLLM Gaudi插件](https://docs.vllm.ai/projects/gaudi/en/stable/dev_guide/plugin_system.html)（另一种思路的参照）
