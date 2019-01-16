---
layout: post
title: caffe源码阅读
categories: 深度学习
tags: caffe
---

* content
{:toc}
## 一、caffe::Net

#### 1、NetParameter定义

其中DEPRECATED已经去除

```protobuf
message NetParameter {
  optional string name = 1; // consider giving the network a name
  optional bool force_backward = 5 [default = false];
  optional NetState state = 6;
  optional bool debug_info = 7 [default = false];
  repeated LayerParameter layer = 100;  // ID 100 so layers are printed last.
}
```


#### 2、重要成员变量

* `string name_` : 表示网络名称
* `Phase phase_` : 表示TEST或者TRAIN
* `vector<shared_ptr<Layer<Dtype> > > layers_` : 存储每层Layer的结构体指针
* `vector<string> layer_names_` : 存储每层Layer的名称
* `vector<shared_ptr<Blob<Dtype> > > blobs_` : 存放Layer之间的结果数据，即每层的输入输出
* `vector<string> blob_names_` : 存储blob的名称
* `vector<vector<Blob<Dtype>*> > bottom_vecs_` : 存储每层Layer的输入，数据在`blobs_`中
* `vector<vector<Blob<Dtype>*> > top_vecs_` : 存储每层Layer的输出，输在在`blobs_`中
* `vector<shared_ptr<Blob<Dtype> > > params_` : 存储每层Layer的参数

#### 3、主要代码逻辑

###### 构造函数

`explicit Net(const string& param_file, Phase phase, const int level = 0, const vector<string>* stages = NULL)`

* `param_file`指定prototxt文件，phase指定TRAIN或者TEST

* 通过protobuf接口解析prototxt后得到NetParameter，再将NetParameter转化成各个私有成员变量

* 私有成员变量的赋值过程如下：

  ```c++
  // 遍历所有的layer
  for (int layer_id = 0; layer_id < param.layer_size(); ++layer_id) {
    const LayerParameter& layer_param = param.layer(layer_id); // 当前layer引用
    layers_.push_back(LayerRegistry<Dtype>::CreateLayer(layer_param)); // layers_
    layer_names_.push_back(layer_param.name()); // layer_names_
    for(layer_param.bottom) AppendBottom(...); // bottom_vecs_/bottom_id_vecs_
    ......
  }
  ```

###### 关于LayerRegistry

* 其核心为`static CreatorRegistry* g_registry_`，类型是`typedef std::map<string, Creator> CreatorRegistry`，它是Layer的类型名称与Layer的构建方法的对应表。
* 对应表由`AddCreator`生成，并封装在`LayerRegisterer`中，并进一步封装在`REGISTER_LAYER_CLASS`中，生成static的全局类，所以在main之前就会被调用产生对应。
* `REGISTER_LAYER_CLASS`内会生成Creator接口（也就是调用new生成类），并构建对应表。
* `CreateLayer`以protobuf定义的`LayerParameter`为参数，先判断它的type在对应表中是否存在，然后调用这个type对应的Create接口，生成Layer类。

###### CopyTrainedLayersFrom

`void CopyTrainedLayersFrom(const string& trained_filename)`

* `trained_filename`对应caffemodel文件

* 通过protobuf接口解析caffemodel后得到NetParameter

* 将每一层LayerParameter的Blob全部拷贝到`layers_`的blob中，基本代码如下：

  ```c++
  auto & target_blobs = layers_[target_layer_id]->blobs()；
  for (int j = 0; j < target_blobs.size(); ++j) {
    target_blobs[j]->FromProto(source_layer.blobs(j), false);
  }
  ```



## 二、caffe::Layer

#### 1、LayerParameter定义

```protobuf
message LayerParameter {
  optional string name = 1; // the layer name
  optional string type = 2; // the layer type
  repeated string bottom = 3; // the name of each bottom blob
  repeated string top = 4; // the name of each top blob
  optional Phase phase = 10;
  repeated float loss_weight = 5;
  repeated ParamSpec param = 6;
  repeated BlobProto blobs = 7;
  repeated bool propagate_down = 11;
  repeated NetStateRule include = 8;
  repeated NetStateRule exclude = 9;
  optional TransformationParameter transform_param = 100;
  optional LossParameter loss_param = 101;
  optional AccuracyParameter accuracy_param = 102;
  optional AnnotatedDataParameter annotated_data_param = 200;
  optional ArgMaxParameter argmax_param = 103;
  ......
}
```

#### 2、重要成员变量

* `LayerParameter layer_param_` : 记录protobuf中的layer param定义
* `Phase phase_` : TRAIN 或者 TEST
* `vector<shared_ptr<Blob<Dtype> > > blobs_` : 存储每层网络的训练参数。通常`blobs_[0]`存储该层网络的weight，`blobs_[1]`存储该层网络的bias。
* `vector<bool> param_propagate_down_` : 标记是否要对param blob计算diff
* `vector<Dtype> loss_` : 存储该层网络的loss，通常loss layer外都为0



## 三、Layer衍生类

#### 1、caffe::BaseConvolutionLayer

* `int bottom_dim_` : 输入数据的维度
* `int top_dim_` : 输出数据的维度
* `int num_` : batch大小
* `int out_spatial_dim_` : 经过卷积后的维度

#### 2、caffe::PoolingLayer

* `int height_, width_` : 输入的图像的尺寸
* `int pooled_height_, pooled_width_` : 输出图像的尺寸
* `int kernel_h_, kernel_w_` : 采样核的尺寸
* `int channels_` : 卷积核的数目

#### 3、caffe::InnerProductLayer

* 运算为`output=input*weight+bias`
* `int M_` 表示input矩阵的行数目
* `int K_` 表示input矩阵的列数目
* `int N_` 表示output的列数