---
layout: single
title: Python常用工具
categories:
  - python
tags:
  - python
---

* content
{:toc}
## ipython

可以执行python交互命令

安装方式：

``` shell
pip3 install ipython
```



## venv

创建虚拟环境，可以做python环境隔离

``` python
cd myfold
# 创建虚拟环境，不包含pip；也可以去掉without-pip，包含pip
python3 -m venv --without-pip myenv
# 进入虚拟python环境
source myenv/bin/activate
# 执行python相关操作
...
# 退出环境
deactivate
```

<!--more-->

## jupyter notebook

(待补充)
