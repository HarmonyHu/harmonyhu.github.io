---
layout: post
title: Dockerfile的使用
categories: Linux
tags: Linux docker
---

* content

{:toc}

## 指令说明

#### FROM

制定所创建镜像的基础镜像，如果本地不存在，则默认会去Docker Hub下载指定镜像。格式为`FROM<image>`，或`FROM<image>:<tag>`,或`FROM<image>@<digest>`。 注意：任何Dockerfile中的第一条指令必须为FROM指令，并且，如果在同一个Dockerfile中创建多个镜像，可以使用多个FROM指令（每个镜像一次）。比如：

```dockerfile
FROM centos
FROM centos:latest
```

#### MAINTAINER

指定维护者信息，格式为`MAINTAINER<name>` ，该信息会写入生成镜像的Author属性域中。比如：

```dockerfile
MAINTAINER test test@example.com
```

#### RUN

运行指定命令，格式为`RUN<command>`或`RUN ["executable", "param1" , "param2"]`。注意 后一个指令会被解析成Json数组。因此必须使用双引号。 注意： 前者默认将在shell终端中运行命令，即`/bin/sh -c`；后者则使用exec执行，不会启动shell环境。举例：

```dockerfile
RUN apt-get update \
	&& apt-get install -y libsnappy-dev libgoogle-glog-dev \
	&& rm -rf /var/cache/apt
RUN ["/bin/bash", "-c", "echo hello"]
```

#### CMD
启动容器时默认执行的命令，支持如下3种形式：

`CMD ["executable","param1","param2"]` 使用exec执行，是推荐使用的。
`CMD command param1 param2` 在/bin/sh中执行，提供给需要交互的应用。
`CMD ["param1" ,"param2"]` 提供给ENTRYPOINT的默认参数。 

举例：

```dockerfile
CMD ["/bin/bash", "/usr/local/nginx/sbin/nginx", "-c", "/usr/local/nginx/conf/nginx.conf"]
```

注意：每个Dodckerfile 只能有一条CMD命令，如果指定了多条命令，只有最后一条会被执行。另外CMD会被`docker run -it test /bin/bash`中的`/bin/bash`覆盖。

#### LABEL

指定生成镜像的元数据标签信息，格式为`LABEL <KEY>=<VALUE> .....` ，比如：
`LABEL version = "1.0"` 
`LABEL description = "This text illustrates ...."`

#### EXPOSE

声明镜像内服务所监听的端口。 
格式为`EXPOSE <port > [<port> ... ]` ，比如：
`EXPOSE 22 80 8443` 
**注意：**该指令只能声明作用，并不会自动完成端口映射。

#### ENV

指定环境变量，在镜像生成过程中会被后续RUN指令使用，在镜像启动的容器中也存在。 
格式为：`ENV<key><value>`或`ENV<key> = <value> ...`，比如：

```dockerfile
ENV PG_MAJOR 9.3
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH
```

#### ADD

格式为：`ADD <src> <dest>`，赋值指定的`< src >` 路径下的内容到容器中的`<dest>`路径下，`<src>`可以为URL；如果为tar文件，会自动解压到`<dest>`路径下；支持正则格式。比如：`ADD *.c /code/`

#### COPY

格式为：`COPY <src> <dest>`，复制本地主机的<src>路径下的内容到镜像中的<dest>路径下；目标路径不存在则自动创建；支持正则格式；一般情况下推荐使用COPY，而不是ADD

#### ENTRYPOINT

指定镜像的默认入口命令，该入口命令会在启动容器时作为根命令执行，所有传入值作为该命令的参数。 
支持两种格式： 
`ENTRYPOINT ["executable" , "param1" , "param2"]`，由exec调用执行

`ENTRYPOINT command param1 param2`，由shell 执行

注意：每个Dockerfile只能有一个ENTRYPOINT，当指定多个时候，只有最后一个有效。在运行时可以被`--entrypoint`覆盖，如`docker run --entrypoint`。

#### VOLUME

创建一个数据卷挂在点。 格式为:`VOLUME ["/data"]` 
可以从本地主机或其他容器挂载数据卷，一般用来存放数据库和需要保存的数据等。

#### USER

指定运行容器时的用户名或UID，格式为：`USER daemon`。当服务不需要管理员权限时，可以通过该命令指定用户名。

#### WORKDIR

为后续RUN、CMD和ENTRYPOINT指令配置工作目录。 
格式为：`WORKDIR /path/to/workdir`

#### ARG

指定镜像内使用的外部参数（例如版本号信息等），如下：

```dockerfile
ARG VERSION
ARG DATE
RUN echo $DATE_$VERSION > version.txt
```

参数在build时传递进来，如下：

```shell
$ docker build --build-arg VERSION=1.0.0 \
               --build-arg DATE=2018 \
               docker_folder
```

#### ONBUILD

配置当前所创建的镜像作为其他镜像的基础镜像时，所执行的创建操作指令

#### STOPSIGNAL

容器退出的信号值

#### HEALTHCHECK

如何进行健康检查

## 范例文件

```dockerfile
## Set the base image to CentOS  基于centos镜像
FROM centos
# File Author / Maintainer  作者信息
MAINTAINER test test@example.com
# Install necessary tools  安装一些依赖的包
RUN yum install -y pcre-devel wget net-tools gcc zlib zlib-devel make openssl-devel
# Install Nginx  安装nginx
ADD http://nginx.org/download/nginx-1.8.0.tar.gz .  # 添加nginx的压缩包到当前目录下
RUN tar zxvf nginx-1.8.0.tar.gz  # 解包
RUN mkdir -p /usr/local/nginx  # 创建nginx目录
RUN cd nginx-1.8.0 && ./configure --prefix=/usr/local/nginx && make && make install  # 编译安装
RUN rm -fv /usr/local/nginx/conf/nginx.conf  # 删除自带的nginx配置文件
ADD http://www.apelearn.com/study_v2/.nginx_conf /usr/local/nginx/conf/nginx.conf  # 添加nginx配置文件
# Expose ports  开放80端口出来
EXPOSE 80
# Set the default command to execute when creating a new container  这里是因为防止服务启动后容器会停止的情况，所以需要多执行一句tail命令
ENTRYPOINT /usr/local/nginx/sbin/nginx && tail -f /etc/passwd
```

## 创建镜像

命令为：`docker build [OPTION]`，该命令读取指定路径（包括子路径）下的Dockerfile，并将该路径的所有内容发给Docker服务端，由服务端来创建镜像。比如：

```shell
$ docker build -t build_repo/first_image /tmp/docker_builder/
```

其中`build_repo/first_image`是标签，`/tmp/docker_builder/`是Dockerfile目录。

* 可以用`-f`指定Dockerfile路径

* 可以用`-t`指定生成的标签

* 可以通过`.dockerignore`指定忽略文件，如下：

  ```dockerfile
  # comment
  */temp*
  */*/temp*
  tmp?
  ~*
  ```
