---
layout: single
title: 各NN框架的MLIR
categories:
  - AI
tags:
  - Mlir
---

* content
{:toc}
## ONNX MLIR

* 官网介绍：<http://onnx.ai/onnx-mlir>
* 论文：[Compiling ONNX Neural Network Models Using MLIR](https://arxiv.org/pdf/2008.08272.pdf)
* github地址：[onnx mlir](https://github.com/onnx/onnx-mlir)
* docker下载：`docker pull onnxmlirczar/onnx-mlir:amd64`

转换工具

```shell
## EmitONNXBasic 会生成.mlir文件(含文本形式的weight)和.tmp文件(不含weight)
docker/onnx-mlir.py --EmitONNXBasic xxx.onnx
```

参数EmitONNXBasic：

```json
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"}  {
  func @main_graph(%arg0: tensor<?x3x224x224xf32>) -> tensor<?x1000xf32> attributes {input_names = ["input"], output_names = ["output"]} {
    %cst = constant unit
    %0 = "onnx.Constant"() : () -> tensor<64x3x7x7xf32>
    %1 = "onnx.Conv"(%arg0, %0, %cst) {dilations = [1, 1], group = 1 : si64, kernel_shape = [7, 7], pads = [3, 3, 3, 3], strides = [2, 2]} : (tensor<?x3x224x224xf32>, tensor<64x3x7x7xf32>, none) -> tensor<*xf32>
    %2 = "onnx.Constant"() : () -> tensor<64xf32>
    %3 = "onnx.Constant"() : () -> tensor<64xf32>
    %4 = "onnx.Constant"() : () -> tensor<64xf32>
    %5 = "onnx.Constant"() : () -> tensor<64xf32>
    %6 = "onnx.BatchNormalizationInferenceMode"(%1, %2, %3, %4, %5) {epsilon = 9.99999974E-6 : f32, momentum = 0.899999976 : f32} : (tensor<*xf32>, tensor<64xf32>, tensor<64xf32>, tensor<64xf32>, tensor<64xf32>) -> tensor<*xf32>
    %7 = "onnx.Relu"(%6) : (tensor<*xf32>) -> tensor<*xf32>
    %8 = "onnx.MaxPoolSingleOut"(%7) {kernel_shape = [3, 3], pads = [1, 1, 1, 1], strides = [2, 2]} : (tensor<*xf32>) -> tensor<*xf32>
......
```

参数EmitONNXIR：

```json
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"}  {
  func @main_graph(%arg0: tensor<?x3x224x224xf32>) -> tensor<?x1000xf32> attributes {input_names = ["input"], output_names = ["output"]} {
    %0 = "onnx.Constant"() : () -> tensor<64x3x7x7xf32>
    %1 = "onnx.Constant"() : () -> tensor<64xf32>
    %2 = "onnx.Conv"(%arg0, %0, %1) {auto_pad = "NOTSET", dilations = [1, 1], group = 1 : si64, kernel_shape = [7, 7], pads = [3, 3, 3, 3], strides = [2, 2]} : (tensor<?x3x224x224xf32>, tensor<64x3x7x7xf32>, tensor<64xf32>) -> tensor<?x64x112x112xf32>
    %3 = "onnx.Relu"(%2) : (tensor<?x64x112x112xf32>) -> tensor<?x64x112x112xf32>
    %4 = "onnx.MaxPoolSingleOut"(%3) {kernel_shape = [3, 3], pads = [1, 1, 1, 1], strides = [2, 2]} : (tensor<?x64x112x112xf32>) -> tensor<?x64x56x56xf32>
    %5 = "onnx.Constant"() : () -> tensor<64x64x3x3xf32>
    %6 = "onnx.Constant"() : () -> tensor<64xf32>
    %7 = "onnx.Conv"(%4, %5, %6) {auto_pad = "NOTSET", dilations = [1, 1], group = 1 : si64, kernel_shape = [3, 3], pads = [1, 1, 1, 1], strides = [1, 1]} : (tensor<?x64x56x56xf32>, tensor<64x64x3x3xf32>, tensor<64xf32>) -> tensor<?x64x56x56xf32>
    %8 = "onnx.Relu"(%7) : (tensor<?x64x56x56xf32>) -> tensor<?x64x56x56xf32>
......
```

参数EmitMLIR：

```json
#map0 = affine_map<(d0, d1) -> (d0 * 64 + d1)>
#map1 = affine_map<(d0) -> (d0 * -2 + 3, 0)>
#map2 = affine_map<(d0) -> (d0 * -2 + 227, 7)>
#map3 = affine_map<(d0, d1) -> (d0 + d1 * 3)>
#map4 = affine_map<(d0, d1) -> (d0 + d1 * 2 - 3)>
#map5 = affine_map<(d0) -> (0, d0 * 2 - 1)>
#map6 = affine_map<(d0) -> (112, d0 * -2 + 113, d0 * 2 + 2, 3)>
#map7 = affine_map<(d0) -> (-d0 + 1, 0)>
#map8 = affine_map<(d0) -> (-d0 + 57, 3)>
#map9 = affine_map<(d0, d1) -> (d0 + d1 * 64)>
......
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"}  {
  func @main_graph(%arg0: memref<?x3x224x224xf32>) -> memref<?x1000xf32> attributes {input_names = ["input"], output_names = ["output"]} {
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0xFF800000 : f32
    %c1 = arith.constant 1 : index
    %cst_0 = arith.constant 0.000000e+00 : f32
    %c2 = arith.constant 2 : index
    %c3 = arith.constant 3 : index
    %0 = "krnl.global"() {name = "constant_0", shape = [64, 3, 7, 7]} : () -> memref<64x3x7x7xf32>
    %1 = "krnl.global"() {name = "constant_1", shape = [64]} : () -> memref<64xf32>
    %2 = memref.dim %arg0, %c0 : memref<?x3x224x224xf32>
    %3 = memref.alloc(%2) {alignment = 16 : i64} : memref<?x64x112x112xf32>
    affine.for %arg1 = 0 to %2 {
      affine.for %arg2 = 0 to 1 {
        affine.for %arg3 = 0 to 64 {
          %116 = affine.apply #map0(%arg2, %arg3)
          affine.for %arg4 = 0 to 112 {
            affine.for %arg5 = 0 to 112 {
              %117 = memref.alloca() : memref<f32>
              affine.store %cst_0, %117[] : memref<f32>
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = max #map1(%arg4) to min #map2(%arg4) {
                  affine.for %arg8 = max #map1(%arg5) to min #map2(%arg5) {
                    %121 = affine.apply #map3(%arg6, %arg2)
                    %122 = affine.apply #map4(%arg7, %arg4)
                    %123 = affine.apply #map4(%arg8, %arg5)
                    %124 = affine.load %arg0[%arg1, %121, %122, %123] : memref<?x3x224x224xf32>
                    %125 = affine.load %0[%116, %arg6, %arg7, %arg8] : memref<64x3x7x7xf32>
                    %126 = affine.load %117[] : memref<f32>
                    %127 = arith.mulf %124, %125 : f32
                    %128 = arith.addf %126, %127 : f32
                    affine.store %128, %117[] : memref<f32>
......
```



## TFLite Mlir

* 官网：[TF mlir](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/compiler/mlir)

#### quantization.mlir

``` json
// RUN: flatbuffer_translate -mlir-to-tflite-flatbuffer %s -o - | flatbuffer_to_string - | FileCheck %s

func @main(%arg0: tensor<1x224x224x3xf32>) -> tensor<1x401408xf32> {
// CHECK: {
// CHECK-NEXT:  version: 3,
// CHECK-NEXT:  operator_codes: [ {
// CHECK-NEXT:    deprecated_builtin_code: 114,
// CHECK-NEXT:    version: 1,
// CHECK-NEXT:    builtin_code: QUANTIZE
// CHECK-NEXT:  }, {
// CHECK-NEXT:    deprecated_builtin_code: 3,
// CHECK-NEXT:    version: 1,
// CHECK-NEXT:    builtin_code: CONV_2D
// CHECK-NEXT:  }, {
// CHECK-NEXT:    deprecated_builtin_code: 22,
// CHECK-NEXT:    version: 1,
// CHECK-NEXT:    builtin_code: RESHAPE
// CHECK-NEXT:  }, {
// CHECK-NEXT:    deprecated_builtin_code: 25,
// CHECK-NEXT:    version: 1,
// CHECK-NEXT:    builtin_code: SOFTMAX
// CHECK-NEXT:  }, {
// CHECK-NEXT:    deprecated_builtin_code: 6,
// CHECK-NEXT:    version: 1,
// CHECK-NEXT:    builtin_code: DEQUANTIZE
// CHECK-NEXT:  } ],
// CHECK-NEXT:  subgraphs: [ {
// CHECK-NEXT:    tensors: [ {
// CHECK-NEXT:      shape: [ 1, 224, 224, 3 ],
// CHECK-NEXT:      buffer: 1,
// CHECK-NEXT:      name: "arg0",
// CHECK-NEXT:      quantization: {
// CHECK-EMPTY:
// CHECK-NEXT:      }
// CHECK-NEXT:    }, {
// CHECK-NEXT:      shape: [ 2 ],
// CHECK-NEXT:      type: INT32,
// CHECK-NEXT:      buffer: 2,
// CHECK-NEXT:      name: "Const",
// CHECK-NEXT:      quantization: {
// CHECK-EMPTY:
// CHECK-NEXT:      }
// CHECK-NEXT:    }, {
// CHECK-NEXT:      shape: [ 1, 224, 224, 3 ],
// CHECK-NEXT:      type: UINT8,
// CHECK-NEXT:      buffer: 3,
// CHECK-NEXT:      name: "tfl.quantize",
// CHECK-NEXT:      quantization: {
// CHECK-NEXT:        scale: [ 0.007812 ],
// CHECK-NEXT:        zero_point: [ 128 ]
// CHECK-NEXT:      }
// CHECK-NEXT:    }, {
// CHECK-NEXT:      shape: [ 32, 3, 3, 3 ],
// CHECK-NEXT:      type: UINT8,
// CHECK-NEXT:      buffer: 4,
// CHECK-NEXT:      name: "tfl.pseudo_qconst",
// CHECK-NEXT:      quantization: {
// CHECK-NEXT:        scale: [ 0.021827 ],
// CHECK-NEXT:        zero_point: [ 151 ]
// CHECK-NEXT:      }
// CHECK-NEXT:    }, {
// CHECK-NEXT:      shape: [ 32 ],
// CHECK-NEXT:      type: INT32,
// CHECK-NEXT:      buffer: 5,
// CHECK-NEXT:      name: "tfl.pseudo_qconst1",
// CHECK-NEXT:      quantization: {
// CHECK-NEXT:        scale: [ 0.000171 ],
// CHECK-NEXT:        zero_point: [ 0 ]
// CHECK-NEXT:      }
// CHECK-NEXT:    }, {
// CHECK-NEXT:      shape: [ 1, 112, 112, 32 ],
// CHECK-NEXT:      type: UINT8,
// CHECK-NEXT:      buffer: 6,
// CHECK-NEXT:      name: "tfl.conv_2d",
// CHECK-NEXT:      quantization: {
// CHECK-NEXT:        scale: [ 0.023528 ],
// CHECK-NEXT:        zero_point: [ 0 ]
// CHECK-NEXT:      }
// CHECK-NEXT:    }

  %0 = "tfl.pseudo_const" () {value = dense<[1, 401408]> : tensor<2xi32>} : () -> tensor<2xi32> loc("Const")
  %1 = "tfl.quantize"(%arg0) {qtype = tensor<1x224x224x3x!quant.uniform<u8:f32, 7.812500e-03:128>>} : (tensor<1x224x224x3xf32>) -> tensor<1x224x224x3x!quant.uniform<u8:f32, 7.812500e-03:128>>
  %2 = "tfl.pseudo_qconst"() {qtype = tensor<32x3x3x3x!quant.uniform<u8<1:255>:f32, 0.021826678373682216:151>>, value = dense<-76> : tensor<32x3x3x3xi8>} : () -> tensor<32x3x3x3x!quant.uniform<u8<1:255>:f32, 0.021826678373682216:151>>
  %3 = "tfl.pseudo_qconst"() {qtype = tensor<32x!quant.uniform<i32:f32, 1.7052092479439231E-4>>, value = dense<0> : tensor<32xi32>} : () -> tensor<32x!quant.uniform<i32:f32, 1.7052092479439231E-4>>
  %4 = "tfl.conv_2d"(%1, %2, %3) {dilation_h_factor = 1 : i32, dilation_w_factor = 1 : i32, fused_activation_function = "NONE", padding = "SAME", stride_h = 2 : i32, stride_w = 2 : i32} : (tensor<1x224x224x3x!quant.uniform<u8:f32, 7.812500e-03:128>>, tensor<32x3x3x3x!quant.uniform<u8<1:255>:f32, 0.021826678373682216:151>>, tensor<32x!quant.uniform<i32:f32, 1.7052092479439231E-4>>) -> tensor<1x112x112x32x!quant.uniform<u8:f32, 0.023528476789885875>>
  %5 = "tfl.reshape"(%4, %0) : (tensor<1x112x112x32x!quant.uniform<u8:f32, 0.023528476789885875>>, tensor<2xi32>) -> tensor<1x401408x!quant.uniform<u8:f32, 0.023528476789885875>>
  %6 = "tfl.softmax"(%5) {beta = 1.000000e+00 : f32} : (tensor<1x401408x!quant.uniform<u8:f32, 0.023528476789885875>>) -> tensor<1x401408x!quant.uniform<u8:f32, 3.906250e-03>>
  %7 = "tfl.dequantize"(%6) : (tensor<1x401408x!quant.uniform<u8:f32, 3.906250e-03>>) -> tensor<1x401408xf32>
  return %7 : tensor<1x401408xf32>
}

```

#### dynamic_shape.mlir

``` json
func @main(%arg0: tensor<?x19x19x3xf32>) -> tensor<?x9x9x4xf32> {
  %cst = arith.constant dense<1.0> : tensor<4xf32>
  %cst_3 = arith.constant dense<2.0> : tensor<4x3x3x3xf32>
  %0 = "tfl.conv_2d"(%arg0, %cst_3, %cst) {dilation_h_factor = 1 : i32, dilation_w_factor = 1 : i32, fused_activation_function = "RELU6", padding = "VALID", stride_h = 2 : i32, stride_w = 2 : i32} : (tensor<?x19x19x3xf32>, tensor<4x3x3x3xf32>, tensor<4xf32>) -> tensor<?x9x9x4xf32>
  return %0 : tensor<?x9x9x4xf32>
}
```

