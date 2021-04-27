---
layout: post
title: python调试
categories: python
tags: python
---

* content
{:toc}
## python调试

#### 方式一：import pdb

```python
import pdb
pdb.set_trace() #运行到这里会自动暂停
```

<!--more-->

#### 方式二：执行 `python -m pdb xxx.py`

* h：（help）帮助
* w：（where）打印当前执行堆栈
* b：（break）添加断点

  * b 列出当前所有断点，和断点执行到统计次数
  * b line_no：当前脚本的line_no行添加断点
  * b filename:line_no：脚本filename的line_no行添加断点
  * b function：在函数function的第一条可执行语句处添加断点
* cl：（clear）清除断点

  * cl 清除所有断点
  * cl bpnumber1 bpnumber2... 清除断点号为bpnumber1,bpnumber2...的断点
  * cl lineno 清除当前脚本lineno行的断点
  * cl filename:line_no 清除脚本filename的line_no行的断点
* s：（step）执行下一条命令，会进入函数
* n：（next）执行下一条语句
* r：（return）执行当前运行函数到结束
* c：（continue）继续执行，直到遇到下一条断点
* l：（list）列出源码
* a：（args）列出当前执行函数的参数
* p expression：（print）输出expression的值
* pp expression: 输出expression的值
* run：重新启动debug，相当于restart
* q：（quit）退出debug

