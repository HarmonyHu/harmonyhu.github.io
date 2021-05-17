---
layout: article
title: Bash shell脚本
categories: 编程
tags: Shell
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

* 内部执行命令用``，或者$()

  ```bash
  `expr 1 + 1` #数学运算
  $(expr 1 + 1) #同上
  ```

<!--more-->

## 变量

#### 常规说明

```bash
# 1. 定义变量, 注意等号两边不能有空格
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
# 5. 全局变量
export VAR="abc" #该变量存在整个shell执行过程中
export -n VAR    #删除变量
```

#### 数值

```bash
# 支持+-*/%
a=10
b=20
c=`expr $a + $b` # `expr`表达式，注意空格隔开
d=$[a*b/2+4-3] # []方式，不需要空格
let e=a+b # 30
let e++ # 31
```

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
echo ${str:1} #ello,world
# 默认值
var=${test:-$str} #如果$test是空或者没有定义，则var=$str；否则var=$test
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

## 判断运算

#### 通用说明

```bash
# 判断使用[] 或者 test，注意[]中需要空格
a=0;b=0
test $a == $b && echo "ture" #打印true
[ $a == $b ] && echo "true" #同上
# 判断中0是true，非0是false
[ $a == $b ]; echo $? # 0
[ $a != $b ]; echo $? # 1
```

#### 数值判断

```bash
a=0;b=0
[ $a == $b ]
[ $a != $b ]
[ $a -eq $b ] #支持eq/ne/gt/lt/ge/le
```

#### 字符串判断

```bash
a="abc";b="cde"
[ $a = $b ] #判断是否相等
[ $a != $b ] #判断是否不相等
[ -z $a ] #判断是否长度为0
[ -n $a ] #判断长度是否不为0
[ $a ] #判断长度是否不为0
#注意事项
[ $a = $b ] #若$a为空，则语法错误
[ "x$a" = "x$b" ] #加上辅助字符
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
# 与或，-a 和 -o, []中使用
[ $b -lt 101 -a $b -gt 99 ] #true
```

#### 文件测试

```bash
[ -d $file ] #判断是否是目录
[ -f $file ] #判断是否普通文件
[ -s $file ] #判断文件大小是否为0，不为空返回true
[ -e $file ] #检测文件或目录是否存在
[ -L $file ] #判断是否是链接
```

## 流程控制

#### if then fi

```bash
# if用法1
if condition1; then
  cmd
fi

# if用法2
if condition1; then
  cmd1
  cmd2
elif confition2; then
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

# for用法3
total=100
for((i=0;i<$total;i++))

# for用法4
for loop in "hello world" #以空格为分隔，进行遍历
for loop in `ls` #遍历命令输出字符串，原理同上
for loop in $* #遍历入参，原理同上
for loop in ~/*.h #遍历路径

# 举例1 ： 多进程
for((i=0;i<10;i++))
do
{
    echo $i
}&
done
wait # 等待前面命令结束后再继续
```

#### while do done

```bash
index=1
while [ $index -lt 5 ]; do
  echo $index
  let index++
done

# 无限循环
while true; do
  command
done
```

## 执行方式

#### 四种方式

  ```bash
# 执行方式一, 在子shell中执行，结束后变量函数都是消失
./test/test.sh
# 执行方式二，同一
sh test/test.sh
# 执行方式三, 脚本中的变量、函数都会在当前shell存在
source test/test.sh
# 执行方式四，同三
. test/test.sh

# 注意不同方式的变量范围
export VAR="abc" #该变量存在整个shell执行过程中
VAR2="123"
./test.sh  #VAR有定义，VAR2无定义
. test.sh  #VAR有定义，VAR2有定义
  ```


#### 脚本参数

```bash
# 基本参数
echo "$0" # 执行脚本名，这里要特别注意，如果是source调用，则$0为-bash，不推荐
echo "${BASH_SOURCE[0]}" # 执行脚本名，这里source调用无差异，推荐方式
echo "$1" # 第一个参数，以此类推
echo "$#" # 参数个数，从$1算起
echo "$*" # 参数排列字符串"$1 $2 $3 ... $n"
echo "$@" # 参数排列字符串"$1" "$2" "$3" ... "$n"
echo "$?" # 最后命令退出状态，0表示没有错误

# shift实现参数左右，可用于不确定参数时确定参数
while [ $# != 0 ]; do
  echo "第一个参数为：$1,参数个数为：$#"
  shift
done
```



## 常用积累

```bash
# 判断当前是否为管理员
if [ `id -u` -ne 0 ]; then
    echo "ERROR: must be run as root"
    exit 1
fi

# 得到当前执行脚本所在目录的全路径，不改变当前路径
# 对source,bash,. 三种方式都适用
FOLDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 得到git最新sha
SHA=`git log -1|head -1|grep -E [0-9a-fA-F]{40} -o`

# 随机数
$RANDOM

# 按任意键继续
read -n 1

# 脚本内生成文件，能够转义或执行当前脚本的变量，
# 如果不希望转义，则用\
cat<<EOF > "../test.txt"
echo $RANDOM #会执行
echo \$RANDOM #不会执行
EOF
```

