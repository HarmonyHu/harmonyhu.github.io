---
layout: post
title: 序列化之FlatBuffers
categories: Linux
tags: flatbuffers google
---

* content
{:toc}
## 一、基本说明

* 源码：[FlatBuffers](https://github.com/google/flatbuffers)
* 指南：[FlatBuffers Programmer's Guide](https://google.github.io/flatbuffers/)
* 结构定义文件为`.fbs`，注释使用`//`，可以使用`include "my.fbs"`嵌套包含文件
* 可以理解为轻量级的protobuf，不会依赖library，但是编码会复杂一些
* FlatBuffers的特点是先构造成员，再构造父结点；与protobuf相反



## 二、schema语法

  ```c++
// Example IDL file for our monster's schema.

namespace MySample;

enum Color:byte { Red = 0, Green, Blue = 2 }

union Equipment { Weapon } // Optionally add more tables.

struct Vec3 {
  x:float;
  y:float;
  z:float;
}

table Monster {
  pos:Vec3;
  mana:short = 150;
  hp:short = 100;
  name:string;
  friendly:bool = false (deprecated);
  inventory:[ubyte];
  color:Color = Blue;
  weapons:[Weapon];
  equipped:Equipment;
}

table Weapon {
  name:string;
  damage:short;
}

root_type Monster;
  ```

#### 语法说明

**标量类型**

- 8 bit: `byte` (`int8`), `ubyte` (`uint8`), `bool`
- 16 bit: `short` (`int16`), `ushort` (`uint16`)
- 32 bit: `int` (`int32`), `uint` (`uint32`), `float` (`float32`)
- 64 bit: `long` (`int64`), `ulong` (`uint64`), `double` (`float64`)

**非标量类型**

* Vector类型，使用`[type]`定义；不支持嵌套，比如`[[type]]`，但可以再定义table内含vector
* string，注意只能是UTF-8或 7-bit ASCII
* 支持struct、enum、union等类型

**默认值**

* 只有标量可以使用默认值
* 使用`=`赋予默认值

**root table**

* 使用`root_type`定义root table

**file_identifier**

* 使用`file_identifier "MYFI";`定义标识，必须是4个字符
* `flatc`加入`-b`参数后自动身材标识
* 使用类似`MonsterBufferHasIdentifier`接口，检查是否存在标识

**file_extension**

* `flatc`默认生成文件的后缀为`.bin`，使用`file_extension "ext";`定义后缀

#### 属性字段

* `id:n` 用于定义id，从0开始，为了兼容性，建议每个字段用id
* `deprecated` 表示停止使用字段，老data仍然存在该字段，但不会生成访问的代码
* `required` 必须填充的字段，默认是optional字段

#### 生成代码

* 使用`flatc --cpp monster.fbs`生成头文件，比如`monster_generate.h`
* 如果需要生成带可修改功能，则使用参数`----gen-mutable`



## 三、序列化

原则：必须先构建成员，再构建父结点

#### 构建 string

```c++
flatbuffers::FlatBufferBuilder fbb;
//注意：sword的类型为flatbuffers::Offset<flatbuffers::String>
auto sword = fbb.CreateString("Sword");
```

#### 构建 table
flatc会为定义的table生成create方法和build方法，注意table的类和方法都是命令空间MySample下。
**方式一、使用create方法如下：**

```c++
// 注意Weapon和CreateWeapon都是在命令空间MySample下
flatbuffers::Offset<Weapon> CreateWeapon(
    flatbuffers::FlatBufferBuilder &_fbb,
    flatbuffers::Offset<flatbuffers::String> name = 0,
    int16_t damage = 0);

// 调用方法如下：
auto wp1 = MySample::CreateWeapon(fbb, sword, 10);
```

**方式二、使用build方法如下：**

```c++
// 注意使用该方法时在`wp_builder.Finish()`之前不能调用任何`fbb.Create`方法
WeaponBuilder wp_builder(fbb);
wp_builder.add_name(sword);
wp_builder.add_damage(10);
auto wp1 = wp_builder.Finish();
```

#### 构建 vector

所有用`[]`定义的类型，都需要这种方法构建：

```c++
flatbuffers::FlatBufferBuilder fbb;
std::vector<flatbuffers::Offset<Weapon>> weapon_vector;
weapon_vector.push_back(wp1);
names.push_back(...);
//注意： weapons_offse的类型为flatbuffers::Offset<flatbuffers::Vector<flatbuffers::Offset<Weapon>>>
auto weapons_offset = fbb.CreateVector(weapon_vector);
```

#### 构建完成

```c++
auto orc = CreateMonster(builder, ......);
builder.Finish(orc);
//构建后的buffer信息： builder.GetBufferPointer() + builder.GetSize()
//释放buffer: builder.ReleaseBufferPointer();
```



## 四、反序列化

```c++
//其中buffer是序列化后的buffer
auto monster = GetMonster(buffer);
// monster->hp() == 80
// monster->name()->str() == "MyMonster"
auto weps = monster->weapons();
for (unsigned int i = 0; i < weps->size(); i++) {
  assert(weps->Get(i)->name()->str() == expected_weapon_names[i]);
  assert(weps->Get(i)->damage() == expected_weapon_damages[i]);
}

//GetBufferStartFromRootPointer(monster) == buffer_pointer
```



## 五、序列化转JSON

以上所有功能只需要包含`flatbuffers/include`头文件。但是到了转JSON的功能，就需要包含`flatbuffers/src`下的`code_generators.cpp`、`idl_gen_text.cpp`、`idl_parser.cpp`、`util.cpp`等4个源文件。编码时，头文件需要另外包含`flatbuffers/idl.h`和`flatbuffers/util.h`。

#### 加载schema文件

**方式一、用脚本将fbs文件生成buffer**

```bash
#!/bin/bash

MONSTER_HEADER="schema_monster.h"
MONSTER_FBS="monster.fbs"

function generate_text()
{
cat<<EOF >"$MONSTER_HEADER"
#include <string>
const std::string schema_text = "\\
EOF
cat $MONSTER_FBS | while read line; do
    echo "$line\\n\\">> $MONSTER_HEADER
done
echo "\";" >> $MONSTER_HEADER
}

generate_text
```

这样就生成了`schema_text`

**方式二、加载fbs文件到buffer中**

```
std::string schema_text;
ASSERT(true == flatbuffers::LoadFile("monster_test.fbs",false, &schema_text));
```

#### 生成json

```c++
std::string json_text;
flatbuffers::Parser parser;
ASSERT(true == parser.Parse(schema_text.c_str()));
// buffer对应的是序列号的buffer,json形式保存在json_text中
ASSERT(true == flatbuffers::GenerateText(parser, buffer, &json_text);

// GenerateTextFile直接存到文件中
// bool GenerateTextFile(const Parser &parser, const std::string &path, const std::string &file_name)
```

