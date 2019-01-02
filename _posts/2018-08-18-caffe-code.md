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
  // Whether the network will force every layer to carry out backward operation.
  // If set False, then whether to carry out backward is determined
  // automatically according to the net structure and learning rates.
  optional bool force_backward = 5 [default = false];
  // The current "state" of the network, including the phase, level, and stage.
  // Some layers may be included/excluded depending on this state and the states
  // specified in the layers' include and exclude fields.
  optional NetState state = 6;

  // Print debugging information about results while running Net::Forward,
  // Net::Backward, and Net::Update.
  optional bool debug_info = 7 [default = false];

  // The layers that make up the net.  Each of their configurations, including
  // connectivity and behavior, is specified as a LayerParameter.
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

  // The train / test phase for computation.
  optional Phase phase = 10;

  // The amount of weight to assign each top blob in the objective.
  // Each layer assigns a default value, usually of either 0 or 1,
  // to each top blob.
  repeated float loss_weight = 5;

  // Specifies training parameters (multipliers on global learning constants,
  // and the name and other settings used for weight sharing).
  repeated ParamSpec param = 6;

  // The blobs containing the numeric parameters of the layer.
  repeated BlobProto blobs = 7;

  // Specifies whether to backpropagate to each bottom. If unspecified,
  // Caffe will automatically infer whether each input needs backpropagation
  // to compute parameter gradients. If set to true for some inputs,
  // backpropagation to those inputs is forced; if set false for some inputs,
  // backpropagation to those inputs is skipped.
  //
  // The size must be either 0 or equal to the number of bottoms.
  repeated bool propagate_down = 11;

  // Rules controlling whether and when a layer is included in the network,
  // based on the current NetState.  You may specify a non-zero number of rules
  // to include OR exclude, but not both.  If no include or exclude rules are
  // specified, the layer is always included.  If the current NetState meets
  // ANY (i.e., one or more) of the specified rules, the layer is
  // included/excluded.
  repeated NetStateRule include = 8;
  repeated NetStateRule exclude = 9;

  // Parameters for data pre-processing.
  optional TransformationParameter transform_param = 100;

  // Parameters shared by loss layers.
  optional LossParameter loss_param = 101;

  // Layer type-specific parameters.
  //
  // Note: certain layers may have more than one computational engine
  // for their implementation. These layers include an Engine type and
  // engine parameter for selecting the implementation.
  // The default for the engine is set by the ENGINE switch at compile-time.
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