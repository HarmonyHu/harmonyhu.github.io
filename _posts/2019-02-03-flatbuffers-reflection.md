---
layout: post
title: FlatBuffers反射
categories: Linux
tags: flatbuffers google
---

* content
{:toc}
## 一、UnPack与Pack

#### 1. 生成方式

flac生成源码时需要加上`--gen-object-api`，则

1）每个table都会生成对象结构体，（T结尾符），该结构体可以直接进行数据操作；

2）每个table新增`UnPack/UnpackTo/Pack`方法，进行对象结构体与table结构体间的转换。

```c++
struct Monster;
struct MonsterT;
struct MonsterT : public flatbuffers::NativeTable {
  typedef Monster TableType;
  std::unique_ptr<Vec3> pos;
  int16_t mana;
  ...;
};

struct Monster: private flatbuffers::Table {
  typedef MonsterT NativeTableType;
  const Vec3 *pos() const {
    return GetStruct<const Vec3 *>(VT_POS);
  }
  ...;
  MonsterT *UnPack(...) const;
  void UnPackTo(MonsterT *_o, ...) const;
  static Offset<Monster> Pack(FlatBufferBuilder &_fbb, const MonsterT* _o, ...);
};
```



#### 2. 使用方法

```c++
// 反序列化成object结构体
auto moster = GetMoster(flatbuffer);
MonsterT * monsterObj = moster->UnpackTo();
...
delete monsterObj;

// 序列化成table结构体
MonsterT monsterObj;
monsterObj->name = "Bob";
FlatBufferBuilder builder;
Pack(builder, &monsterObj);
```



## 二、 Parser

使用方法参考`flatbuffers::GenerateText`的实现

#### 1. 生成flatbuffers::Parser

```c++
// shema_text是schema的字符串形式
flatbuffers::Parser parser;
parser.Parse(schema_text);
```

#### 2. 根table

```c++
auto table = flatbuffers::GetAnyRoot(buffers); // 反序列化成根table
// table方法描述如下：
const uint8_t *GetVTable() const; // 得到table的数据指针
voffset_t GetOptionalFieldOffset(voffset_t field) const； // 得到filed的voffset
template<typename P> P GetPointer(voffset_t field); //得到filed的数据指针
template<typename P> P GetStruct(voffset_t field)； //得到filed的结构体指针
template<typename T> bool SetField(voffset_t field, T val, T def)； // 设置filed的值
bool CheckField(voffset_t field) const； // 检查filed是否存在
```

#### 3. StructDef

```c++
// 根struct, flatbuffers::StructDef
auto struct_def = parset.root_struct_def_;
cout << struct_def->name; // 根table的名称
auto fileds =  struct_def->fields.vec; // 根table的成员
for (auto filed : fileds) { // 遍历成员
    if (false == table->CheckFiled(filed->value.offset)) { //检查是否存在
        continue;
    }
    cout << filed->name << endl; // 成员名称
}
```



## 三、reflection

#### 1. 生成reflection::Schema

```c++
// shema_text是schema的字符串形式
flatbuffers::Parser parser;
parser.Parse(schema_text);
paser.Serialize();
// shema类型为const reflection::Schema *
auto schema = reflection::GetSchema(parser.builder_.GetBufferPointer());
```

#### 2. 元素说明

* `objects()`

```c++
// 所有objects，类型为const Vector<Offset<Object>> *
auto objects = schema->objects();
for(uint32_t i = 0; i < objects->size(); i++) {
  auto object= objects->Get(i);
  cout << "object:" << object->name()->c_str() << endl;
}
// MySample.Vec3
// MySample.Monster
// MySample.Weapon
```

* `root_table()`

```c++
// 根table，类型为const reflection::Object *
auto root_table = schema->root_table();
// 根table的名称
cout << root_table->name()->c_str(); // MySample.Monster

// 所有fields, 所有的成员
auto fields = root_table->fields();
cout << fields->Length();  // 成员个数
// 类型为const reflection::Field *
auto field = fields->Get(0); //第0个成员
cout << field->name()->c_str(); // 成员名称
cout << field->id();  // id值
cout << (field->type()->base_type() == reflection::UInt);  // 基本类型
fields->Get(filed->type()->index()) == filed; // 成员位置

// 查找成员
auto hp_filed = fileds->LookupByKey("hp");
```

#### 3. 元素反射

```c++
// Now use it to dynamically access a buffer. 获得root table
auto &root = *flatbuffers::GetAnyRoot(flatbuf);
// 得到成员hp的值
auto hp_value = flatbuffers::GetFieldI<uint16_t>(root, hp_field);
TEST_EQ(hp_value, 80);
// 也可以不在乎类型
auto hp_any = flatbuffers::GetAnyFieldI(root, hp_filed);
TEST_EQ(hp_any, 80);
auto hp_string = flatbuffers::GetAnyFieldS(root, hp_field, &schema);
TEST_EQ_STR(hp_string.c_str(), "80");
// 可以修改
flatbuffers::SetField<uint32_t>(&root, hp_filed, 200);
```

