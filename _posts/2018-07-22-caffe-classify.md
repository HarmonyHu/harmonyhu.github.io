---
layout: post
title: 如何使用训练好的模型
categories: 深度学习
tags: caffe
---

* content
{:toc}
## 一、需要的文件

经过caffe训练后，通常需要使用4种文件：

1. 模型配置文件，比如`lenet.prototxt`，内容类似如下：

   ```protobuf
   name: "LeNet"
   layer {
     name: "data"
     type: "Input"
     top: "data"
     input_param { shape: { dim: 64 dim: 1 dim: 28 dim: 28 } }
   }
   layer {
     name: "conv1"
     type: "Convolution"
     bottom: "data"
     top: "conv1"
   ......
   ```

   注意它与`lenet_train.prototxt`的区别，主要是输入替换，和weight_filler和bias_filler删除等

2. 模型文件，比如`lenet_10000.caffemodel`

3. 均值文件，比如`mean.binaryproto`

4. 标签文件，比如`name.labels`，内容如下：

   ```
   thing
   matter
   object
   atmospheric phenomenon
   body part
   body of water
   head
   hair
   ......
   ```



## 二、接口调用过程

#### 配置模式

```c++
Caffe::set_mode(Caffe::CPU); // 使用CPU
```

#### 初始化Net

```c++
shared_ptr<Net<float> > net_;
net_.reset(new Net<float>("lenet.prototxt", TEST));	// 加载配置文件，设定模式为分类
net_->CopyTrainedLayersFrom("lenet_10000.caffemodel");
```

#### 读取输入层信息

```c++
//// 输入层信息
Blob<float>* input_layer = net_->input_blobs()[0];
int num_channels = input_layer->channels();
int width = input_layer->width();
int height = input_layer->height();
Size input_size = Size(width, height); 
//将input_channels指向模型的输入层相关位置
vector<Mat> input_channels;
float* input_data = input_layer->mutable_cpu_data();
for (int i = 0; i < input_layer->channels(); i++) {
    Mat channel(height, width, CV_32FC1, input_data);
    input_channels.push_back(channel);
    input_data += width * height;
}
```

#### 处理均值文件

```c++
/// 读取均值文件
BlobProto blob_proto;
ReadProtoFromBinaryFileOrDie("mean.binaryproto", &blob_proto); 
Blob<float> mean_blob;
mean_blob.FromProto(blob_proto);
// 转换成均值图像
vector<Mat> channels;
float* data = mean_blob.mutable_cpu_data();
for (int i = 0; i < num_channels; i++)	{
  Mat channel(mean_blob.height(), mean_blob.width(), CV_32FC1, data);
  channels.push_back(channel);
  data += mean_blob.height() * mean_blob.width();
}
Mat mean_temp;
merge(channels, mean_temp); 
Scalar channel_mean = cv::mean(mean_temp);
Mat mean = Mat(input_size, mean_temp.type(), channel_mean);
```

#### 处理输入图像

```c++
// 读入图像
Mat img = imread("test.jpg");
// 改变图像的通道
Mat sample;
if (img.channels() == 3 && num_channels_ == 1)
    cv::cvtColor(img, sample, COLOR_BGR2GRAY);
else if (img.channels() == 4 && num_channels_ == 1)
    cv::cvtColor(img, sample, COLOR_BGRA2GRAY);
else if (img.channels() == 4 && num_channels_ == 3)
    cv::cvtColor(img, sample, COLOR_BGRA2BGR);
else if (img.channels() == 1 && num_channels_ == 3)
    cv::cvtColor(img, sample, COLOR_GRAY2BGR);
else
	sample = img;
// 改变图像的大小
Mat sample_resized;
if (sample.size() != input_size)
    cv::resize(sample, sample_resized, input_size);
else
    sample_resized = sample;
// 转换类型为float
cv::Mat sample_float;
if (num_channels_ == 3)
    sample_resized.convertTo(sample_float, CV_32FC3);
else
    sample_resized.convertTo(sample_float, CV_32FC1);
// 减去均值
cv::Mat sample_normalized;
cv::subtract(sample_float, mean, sample_normalized);
// 存入到input_layer
cv::split(sample_normalized, input_channels);
```

#### 前向推理

```c++
net_->Forward();
```

#### 取出输出数据和结果分析

```c++
Blob<float>* output_layer = net_->output_blobs()[0];
// 将输出层数据保存在vector容器中
const float* begin = output_layer->cpu_data();
const float* end = begin + output_layer->channels();
vector<float> output = vector<float>(begin, end);
// 取出概率最大的前5个
std::vector<int> maxN = Argmax(output, 5)；
// 获取标签
ifstream label_file("name.labels");
vector<string> labels;
string line;
while (getline(labels, line))
	labels.push_back(string(line));
// 打印结果
for (auto &i : maxN) {
    std::cout << labels[i] << ":" << output[i] << std::endl;
}
```

