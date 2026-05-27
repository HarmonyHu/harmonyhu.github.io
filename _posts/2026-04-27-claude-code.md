---
layout: single
title: ClaudeCode学习整理
categories:
  - AI
tags:
  - AI Agent
  - tools
---



* content
{:toc}


## 学习资料

本文全部内容来自：

[claude code docs](https://code.claude.com/docs/)

## 使用基础

### 1. 安装

* Windows安装命令：`irm https://claude.ai/install.ps1 | iex`
* Linux方法一：`curl -fsSL https://claude.ai/install.sh | bash`
* Linux方法二：
  * `curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh`，安装brew后按提示命令，添加brew到shell中
  * `brew install --cask claude-code@latest`

* 安装完后`vim ~/.claude.json`中添加配置`"hasCompletedOnboarding": true`

### 2. 自定义模型

#### 1) 方法一

```shell
vim ~/.claude/setting.json

{
    "env": {
        "ANTHROPIC_AUTH_TOKEN": "api key",
        "ANTHROPIC_BASE_URL": "server",
        "ANTHROPIC_MODEL": "model name"
    }
}
```

#### 2) 方法二

采用[cc-switch](https://github.com/farion1231/cc-switch)，安装方法如下：

```shell
# 官网找最新版安装
wget https://github.com/farion1231/cc-switch/releases/download/v3.15.0/CC-Switch-v3.15.0-Linux-x86_64.deb
dpkg -i xxx.deb
# 运行cc-switch
cc-switch
```



## 3. 启动与命令

* `claude`: 启动交互模式
* `claude "task"`: 运行一次性任务
* `claude -p "query"`: 一次查询操作
* `claude -c`: 当前目录继续上一次会话
* `claude -r`: 恢复之前的会话
* `/clear`: 清除历史
* `/help`: 显示可用命令
* `/exit`: 退出
* `/model`: 切换模型

* `/init`: 分析项目，在当前项目构建`CLAUDE.md`文件
* `/memory`: 编辑记忆文件，包括`CLAUDE.md`等文件
* `/rename`: 给当前会话命令，方便后续打开会话
* `/resume`: 继续之前的会话
* `@`: 用于指定目录或文件

## 4. 目录

* `~/.claude/CLAUDE.md`：适用于所有会话
* `./CLAUDE.md`：适用于当前项目
* `./CLAUDE.local.md`：个人使用，用`.gitignore`屏蔽掉
* `.claude/skills`：存放skill
* `.claude/agents`：存放agent
* `.claude/settings.json`：存放配置

## 5. 工作流

`探索 -> 规划 -> 实现 -> 提交`

* 探索(plan mode)：先阅读和理解环境、代码等等，举例：

  ```
  read /src/auth and understand how we handle sessions and login.
  also look at how we manage environment variables for secrets.
  ```

* 规划(plan mode)：要求Claude创建实施计划，举例：

  ```
  I want to add Google OAuth. What files need to change?
  What's the session flow? Create a plan.
  ```

  按`Ctrl + G`可以直接计划

* 实现(default mode)：切换到默认模式，让其按计划进行，举例：

  ```
  implement the OAuth flow from your plan. write tests for the
  callback handler, run the test suite and fix any failures.
  ```

* 提交(default mode): 要求commit和创建PR

  ```
  commit with a descriptive message and open a PR
  ```

  
