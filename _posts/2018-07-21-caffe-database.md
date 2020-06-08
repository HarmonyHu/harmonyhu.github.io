---
layout: post
title: caffe如何解析数据库
categories: AI
tags: caffe
---

* content
{:toc}

## 一、convert_imageset

使用caffe中的convert_imageset工具可以将原始图片转换成LevelDB或者Lmdb格式。转换方法如下：

```shell
$ convert_imageset [FLAGS] ROOTFOLDER/ LISTFILE DB_NAME
```

<!--more-->

* `ROOTFLOLDER`: 为图像集的根目录，必须带`/`结尾

* `LISTFILE`: 文本文件，记录图像路径（该路径是ROOTFOLDER的相对路径）和标注，举例如下：

   ```
   train/321.jpg 0
   train/352.jpg 1
   train/337.jpg 2
   train/345.jpg 3
   train/339.jpg 4
   ```
* `DB_NAME`: 生成的数据库的名称，可以是相对路径

* `[FLAGS]`为可选参数，如下：
  * `gray`：bool类型，默认为false，如果设置为true，则代表将图像当做灰度图像来处理，否则当做彩色图像来处理
  * `shuffle`：bool类型，默认为false，如果设置为true，则代表将图像集中的图像的顺序随机打乱
  * `backend`：string类型，可取的值的集合为{"lmdb", "leveldb"}，默认为"lmdb"，代表采用何种形式来存储转换后的数据
  * `resize_width`：int32的类型，默认值为0，如果为非0值，则代表图像的宽度将被resize成resize_width
  * `resize_height`：int32的类型，默认值为0，如果为非0值，则代表图像的高度将被resize成resize_height
  * `check_size`：bool类型，默认值为false，如果该值为true，则在处理数据的时候将检查每一条数据的大小是否相同
  * `encoded`：bool类型，默认值为false，如果为true，代表将存储编码后的图像，具体采用的编码方式由参数encode_type指定
  * `encode_type`：string类型，默认值为""，用于指定用何种编码方式存储编码后的图像，取值为编码方式的后缀（如png、jpg等等)

举例：

```shell
$ ./build/tools/convert_imageset \
--shuffle \
--resize_height=256 \
--resize_width=256 \
/home/xxx/caffe/data/mynet/ \
examples/mynet/train.txt \
examples/mynet/mynet_train_lmdb
```

## 二、Datum

#### 1、定义

在`caffe.proto`中的定义如下：

```protobuf
message Datum {
  optional int32 channels = 1;
  optional int32 height = 2;
  optional int32 width = 3;
  // the actual image data, in bytes
  optional bytes data = 4;
  optional int32 label = 5;
  // Optionally, the datum could also hold float data.
  repeated float float_data = 6;
  // If true data contains an encoded image that need to be decoded
  optional bool encoded = 7 [default = false];
}
```

其中channels/height/width分别对应C/H/W；保存的数据可以是byte类型（data)，或者是float类型（float_data)；label对应标签号，通常从0开始；encoded表示数据是否被译码（如jpg/png等等），如果有则需要解码后使用，默认是false，表示纯粹的3维数据。

#### 2、初始化

一张图片的过程如下（经过精简，默认存入未译码数据）：

```c++
bool ReadImageToDatum(const string& filename, ...) {
  cv::Mat cv_img = ReadImageToCVMat(filename, height, width, is_color);
  datum->set_channels(cv_img.channels());
  datum->set_height(cv_img.rows);
  datum->set_width(cv_img.cols);
  datum->clear_data();
  datum->clear_float_data();
  datum->set_encoded(false);
  int datum_channels = datum->channels();
  int datum_height = datum->height();
  int datum_width = datum->width();
  int datum_size = datum_channels * datum_height * datum_width;
  std::string buffer(datum_size, ' ');
  for (int h = 0; h < datum_height; ++h) {
    const uchar* ptr = cv_img.ptr<uchar>(h);
    int img_index = 0;
    for (int w = 0; w < datum_width; ++w) {
      for (int c = 0; c < datum_channels; ++c) {
        int datum_index = (c * datum_height + h) * datum_width + w;
        buffer[datum_index] = static_cast<char>(ptr[img_index++]);
      }
    }
  }
  datum->set_data(buffer);
  datum->set_label(label);
  return true;
}
```



## 三、数据库的生成

数据库存入的是Datum序列化后的数据，以及索引。精简后的代码如下：

```c++
int main(...) {
  scoped_ptr<db::DB> db(db::GetDB(FLAGS_backend)); // lmdb 或者 leveldb
  db->Open(argv[3], db::NEW); // 创建数据库
  scoped_ptr<db::Transaction> txn(db->NewTransaction());

  std::ifstream infile(argv[2]); // 打开LISTFILE文件
  while (std::getline(infile, line)) { // 读取文件中的图片路径和标签
    pos = line.find_last_of(' ');
    label = atoi(line.substr(pos + 1).c_str());
    lines.push_back(std::make_pair(line.substr(0, pos), label));
  }
  for (int line_id = 0; line_id < lines.size(); ++line_id) { // 每个图片处理
    ReadImageToDatum(root_folder + lines[line_id].first, ...); // 将1张图片转换成Datum
    string key_str = "0000XXXX_" + lines[line_id].first; //索引，XXXX表示line_id
    datum.SerializeToString(&out)；  //Datum序列化
    txn->Put(key_str, out);  //存入数据库
  }
  txn->Commit(); // 数据库写入磁盘
  return 0;
}
```

## 四、数据库的解析

解析数据库在DataLayer中实现。精简后的代码如下：

```c++
// 只读方式打开数据库
db_.reset(db::GetDB(param.data_param().backend()));
db_->Open(param.data_param().source(), db::READ);
cursor_.reset(db_->NewCursor());
// 按batch数量load Datum
Datum datum;
for (int item_id = 0; item_id < batch_size; ++item_id) {
  datum.ParseFromString(cursor_->value()); // 反序列化成Datum
  // 按偏移存入Datum转换后的数据，到Blob<Dtype>中
  int offset = batch->data_.offset(item_id);
  Dtype* top_data = batch->data_.mutable_cpu_data();
  this->transformed_data_.set_cpu_data(top_data + offset);
  this->data_transformer_->Transform(datum, &(this->transformed_data_));
  // 下一个
  cursor_->Next();
  offset_++;
}
```

其中TransForm代码，精简如下：

```c++
const string& data = datum.data();
const int datum_channels = datum.channels();
const int datum_height = datum.height();
const int datum_width = datum.width();
Dtype datum_element;
int top_index, data_index;
for (int c = 0; c < datum_channels; ++c) {
  for (int h = 0; h < height; ++h) {
    for (int w = 0; w < width; ++w) {
      data_index = (c * datum_height + h_off + h) * datum_width + w_off + w;
      top_index = (c * height + h) * width + w;
      if (has_uint8) { // 根据类型读取数据
            datum_element = datum.data[data_index];
      } else {
            datum_element = datum.float_data(data_index);
      }
      if (has_mean_file) { // 如果有mean文件，要减去mean数据
        transformed_data[top_index] =
            (datum_element - mean[data_index]) * scale;
      } else { //对数据进行scale处理
        transformed_data[top_index] = datum_element * scale;
      }
}}}
```

