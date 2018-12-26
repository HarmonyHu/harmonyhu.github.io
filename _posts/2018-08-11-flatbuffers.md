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



## 二、schema语法

  ```json
// Example IDL file for our monster's schema.

namespace MyGame.Sample;

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

* 使用`flatc -cpp mygame.fbs`生成头文件，比如`monster_generate.h`



## 三、序列化

```c++
flatbuffers::FlatBufferBuilder builder;
auto weapon_one_name = builder.CreateString("Sword");
short weapon_one_damage = 3;
auto weapon_two_name = builder.CreateString("Axe");
short weapon_two_damage = 5;
// Use the `CreateWeapon` shortcut to create Weapons with all fields set.
auto sword = CreateWeapon(builder, weapon_one_name, weapon_one_damage);
auto axe = CreateWeapon(builder, weapon_two_name, weapon_two_damage);
// Create a FlatBuffer's `vector` from the `std::vector`.
std::vector<flatbuffers::Offset<Weapon>> weapons_vector;
weapons_vector.push_back(sword);
weapons_vector.push_back(axe);
auto weapons = builder.CreateVector(weapons_vector);
//......
//......
auto orc = CreateMonster(builder, ......);
builder.Finish(orc);

//save by builder.GetBufferPointer() and builder.GetSize()
```



## 四、反序列化

```c++
auto monster = GetMonster(buffer_pointer);
// monster->hp() == 80
// monster->name()->str() == "MyMonster"
auto weps = monster->weapons();
for (unsigned int i = 0; i < weps->size(); i++) {
  assert(weps->Get(i)->name()->str() == expected_weapon_names[i]);
  assert(weps->Get(i)->damage() == expected_weapon_damages[i]);
}
```

