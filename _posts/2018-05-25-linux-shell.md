---
layout: post
title: Bash shell脚本
categories: 编程
tags: 编程 Shell
---

* content
{:toc}
## 通用说明

* 注释用#

* 标头用#!表明解释器

  ```bash
  #!/bin/bash
  echo "Hello world"
  ```

* 用;号可以将多行语句写一行，可以不用空格

  ```bash
  a=10;b=20;c=30
  ```

* 内部命令用``，或者$()

  ```bash
  `expr 1 + 1` #数学运算
  $(expr 1 + 1) #同上
  ```

  



## 变量

#### 常规说明

```bash
# 1. 定义变量
count=10 #数字
name="kitty" #字符串
# 2. 变量可被重新定义
count=9
# 3. 变量使用,花括号用于分离
echo $count
echo "$count"
echo ${count}
echo "${count}"
echo "${count}cat" # 这里用于分离
$count=10 #错误！！不可以这样使用
# 4. 删除变量
unset count
```

* 等号两边不能有空格

#### 字符串

```bash
# 单引号，不会转义
str='hello,world'
# 双引号，可以转义
str2="str:\$str" #不会转成hello,world
# 获取字串长度
echo ${#str} #11
# 提取字串
echo ${str:1:4} #ello
```

#### 数组

```bash
# 定义数组
array=(1 2 3 'abc')
array2[0]=1 # 也可以这样定义
array2[5]='abc' # 下标可以不连续
# 使用数组
echo ${array[3]} # abc
echo ${array2[@]} # 所有元素，1 abc
# 数组长度
echo ${#array2[@]} # 元素个数，2
echo ${#array2[5]} # 单个元素长度，3
```

## 运算

#### 算数运算

```bash
# 支持+-*/%
a=10
b=20
c=`expr $a + $b` # `expr`表达式，注意空格隔开
d=$[a*b/2+4-3] # []方式，不需要空格
let e=a+b # 30
let e++ # 31
# 比较，返回true或false，注意用[],且空格
[ $a == $b ]
[ $a != $b ]
[ $a -eq $b ] #支持eq/ne/gt/lt/ge/le
```

#### 字符串运算

```bash
a="abc"
b="cde"
[ $a = $b ] #判断是否相等
[ $a != $b ] #判断是否不相等
[ -z $a ] #判断是否长度为0
[ -n $a ] #判断长度是否不为0
[ $a ] #判断长度是否不为0
```

#### 逻辑运算

```bash
# 取反，注意空格
a=""
[ -z $a ] # true
[ ! -z $a ] # false
# 与或，&& 和 ||，需要[[]]
b=100
[[ $b -lt 101 && $b -gt 99 ]] #true
```

#### 文件测试

```bash
[ -d $file ] #判断是否是目录
[ -f $file ] #判断是否普通文件
[ -s $file ] #判断文件大小是否为0，不为空返回true
[ -e $file ] #检测文件或目录是否存在
```

## 流程控制

#### if then fi

```bash
# if用法1
if condition1
then
  cmd
fi

# if用法2
if condition1
then
  cmd1
  cmd2
elif confition2
then
  cmd3
  cmd4
else
  cmd5
fi
```

#### for in do done

```bash
# for用法1
for loop in 1 2 3 4
do
  echo "value:$loop"
done

# for用法2 
for loop in `seq 1 $#` #遍历参数个数
for loop in {1..4} #从1到4遍历
```

#### while do done

```bash
index=1
while [ $index -lt 5 ]
do
  echo $index
  let index++
done

# 无限循环
while true
do
  command
done
```

## 脚本参数

#### 基本参数

```bash
echo "$0" # 执行脚本名
echo "$1" # 第一个参数，以此类推
echo "$#" # 参数个数，从$1算起
echo "$*" # 参数排列字符串"$1 $2 $3 ... $n"
echo "$@" # 参数排列字符串"$1" "$2" "$3" ... "$n"
echo "$?" # 最后命令退出状态，0表示没有错误
```

#### shift操作

```bash
# shift实现参数左右，可用于不确定参数时确定参数
while [ $# != 0 ];do  
  echo "第一个参数为：$1,参数个数为：$#"  
  shift  
done 
```

