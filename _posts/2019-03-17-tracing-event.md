---
layout: post
title: Linux Event Tracing
categories: Linux
tags: Linux
---

* content
{:toc}
## Tracepoints添加

参考 [Tracepoints]( https://www.kernel.org/doc/html/latest/trace/tracepoints.html )

#### 1. 添加头文件

`include/trace/events/sample.h`

```c
#undef TRACE_SYSTEM
#define TRACE_SYSTEM sample

#if !defined(_TRACE_SUBSYS_H) || defined(TRACE_HEADER_MULTI_READ)
#define _TRACE_SUBSYS_H

#include <linux/tracepoint.h>

DECLARE_TRACE(sample_event,
        TP_PROTO(int firstarg, struct task_struct *p),
        TP_ARGS(firstarg, p));

#endif /* _TRACE_SUBSYS_H */

/* This part must be outside protection */
#include <trace/define_trace.h>
```


#### 2. 生成结点和导出

`kernel/trace/trace_sample.c`

```c
#include <linux/string.h>
#include <linux/types.h>
#include <linux/module.h>

#define CREATE_TRACE_POINTS
#include <trace/events/sample.h>

EXPORT_TRACEPOINT_SYMBOL_GPL(sample_event);
```

#### 3. 业务代码中调用tracepoint

```c
#include <trace/events/smaple.h>

void somefunc(void)
{
  ...
  trace_sample_event(arg, task);
  ...
}
```



## Event Tracing

参考 [Event Tracing]( https://www.kernel.org/doc/html/latest/trace/events.html )

#### 1. 通过set_event使能某个event

```shell
# enable
echo sample_event >> /sys/kernel/debug/tracing/set_event
# disable
echo '!sample_event' >> /sys/kernel/debug/tracing/set_event
# enable all
echo *:* >> /sys/kernel/debug/tracing/set_event
# enable one evnet all sub event
echo 'irq:*' >> /sys/kernel/debug/tracing/set_event
```

#### 2. 通过enable使能

```shell
# enable                   
echo 1 > /sys/kernel/debug/tracing/events/sample/enable
# disable
echo 0 > /sys/kernel/debug/tracing/events/sample/enable
# enable某个sub event
echo 1 > /sys/kernel/debug/tracing/events/sample/sample_event/enable
# enable所有sub event
echo 1 > /sys/kernel/debug/tracing/events/enable
```

#### 3. 查看tracing日志

```shell
cat /sys/kernel/debug/tracing/trace
```

