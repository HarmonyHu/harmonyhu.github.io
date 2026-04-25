---
layout: single
title: Copilot-CLI学习
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

[copilot-cli](https://docs.github.com/en/copilot/concepts/agents/copilot-cli)

[copilot-cli-for-beginners](https://github.com/github/copilot-cli-for-beginners)

## 使用基础

### 1. 安装

* Windows下安装命令：`winget install GitHub.Copilot`

* Linux下安装命令：`curl -fsSL https://gh.io/copilot-install | bash`

### 2. 登录

* 执行：`copilot`
* 登录：`/login`，根据提示在网页打开`https://github.com/login/device`，授权后即可登录
* 退出登录：`/logout`

<!--more-->

### 3. 使用模式

有三种使用模式，可以通过`shift+Tap`切换模式，可以用`ctrl+c`停止

#### a) Interactive Mode

直接用`copilot`登录，然后一问一答

#### b) Plan Mode

使用`/plan`命令或者`copilot --plan`

用于复杂的任务，在该模式下会先给出实现目标的步骤。我们可以审查和修改步骤，甚至可以保存步骤：`Save this plan to mark_as_read_plan.md`。实施时每一步结束都会停下来等待输入。

该模式下可以通过`Shift+Tap`切换到**AutoPilot**模式，或者直接`copilot --autopilot`，这样每一步就不会停止。

#### c) Programmatic Mode

`copilot -p "xxxxxxxxx"`，等同于交互模型一问一答后执行`exit`

文档中举例如下使用例子：

``` shell
#!/bin/bash

# Generate commit messages automatically
COMMIT_MSG=$(copilot -p "Generate a commit message for: $(git diff --staged)")
git commit -m "$COMMIT_MSG"

# Review a file
copilot --allow-all -p "Review @myfile.py for issues"
```

### 4. 常用命令

设置环境变量`COPILOT_HOME`指定配置文件，默认为`~/.copilot/settings.json`

| Command     | What It Does                                                 | When to Use                                                  |
| ----------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `/ask`      | Ask a quick question without it affecting your conversation history | When you want a quick answer without derailing your current task |
| `/clear`    | Clear conversation and start fresh                           | When switching topics                                        |
| `/help`     | Show all available commands                                  | When you forget a command                                    |
| `/model`    | Show or switch AI model                                      | When you want to change the AI model                         |
| `/plan`     | Plan your work out before coding                             | For more complex features                                    |
| `/research` | Deep research using GitHub and web sources                   | When you need to investigate a topic before coding           |
| `/exit`     | End the session                                              | When you're done                                             |
| /keep-alive | keep server alive avoid sleeping                             |                                                              |
| /cwd        | change current directory                                     |                                                              |

另外有些权限选项比较有用如下：

* `--allow-all-tools`是允许使用所有工具
* `--deny-tool="shell(rm)" --deny-tool="shell(git push)"`：禁止使用`rm`和`git push` 
* `--allow-all-paths`：允许访问所有路径
* `--allow-all-urls`：允许访问所有域名
* `--allow-url=github.com`：允许访问指定域名
* `--deny-url=github.com`：禁止访问指定域名
* `--allow-all` == `--allow-all-tools` + `--allow-all-paths` + `allow-all-urls`



## Context-Conversations

### 1. 用@语法

``` shell
copilot

# Point at any file you have
> Explain what @package.json does
> Summarize @README.md
> What's in @.gitignore and why?
```

* 可以@文件或者@文件夹，同时可以@多个
* 可以用*匹配多个，如`@folder/*.py`，`@**/test_*.py`

### 2. 相关选项

* `--continue`：从上一次对话继续
* `--resume`：从某个会话继续
* `/context`：查看tokens使用
* `/clear`：清理历史
* `/new`：新建对话
* `/rewind`：回退到当前会话的某个部分
* `/rename`：给当前会话一个名字，方便找到
* `/session`：查看会话信息
* `/usage`：查看使用统计
* `/share my-session.md`：将会话导出到文件中
* `/compact`：打包历史会话，释放历史token



## Development-Workflows

### 1. Code Review

* 参考如 `Review @samples/book-app-project/book_app.py for code quality`
* `/review` 用于审查`staged/unstaged`的修改

### 2. Refactoring

* 参考如`@samples/book-app-project/book_app.py The command handling uses if/elif chains. Refactor it to use a dictionary dispatch pattern.`
* 关键字如：`Refactor`

### 3. Debugging

* 参考如`I'm getting this error: ...... Explain why and how to fix it`

### 4. Test Generation

* 参考如`@samples/book-app-project/books.py Generate pytest tests for all functions including edge cases`

### 5. Git Integration

* 参考如`copilot -p "Generate a conventional commit message for: $(git diff --staged)"`

* `/diff` 显示当前会话做的所有修改



## Agents Custom Instructions

### 1. 添加自定义Agents

文件扩展名为`.agent.md`，文件内容如下：

``` markdown
---
name: my-reviewer
description: Code reviewer focused on bugs and security issues
---

# Code Reviewer

You are a code reviewer focused on finding bugs and security issues.

When reviewing code, always check for:
- SQL injection vulnerabilities
- Missing error handling
- Hardcoded secrets
```

文件存放目录：

| Location             | Scope                 | Best For                                    |
| -------------------- | --------------------- | ------------------------------------------- |
| `.github/agents/`    | Project-specific      | Team-shared agents with project conventions |
| `~/.copilot/agents/` | Global (all projects) | Personal agents you use everywhere          |

社区agents可以参考：[awesome-copilot](https://github.com/github/awesome-copilot)

### 2. 调用方法

* Interactive mode: `/agent`. 列出所有agents，然后选择一个执行
* Programmatic mode: `copilot --agent python-reviewer`. 直接执行
* `/init`：可以直接生成项目配置文件和Agents



## SKILLs

Agents用于告诉Copilot如何思考，Skills告诉Copilot具体怎么做。

文件存放目录：

| Location             | Scope                 | Best For                                    |
| -------------------- | --------------------- | ------------------------------------------- |
| `.github/skills/`    | Project-specific      | Team-shared skills with project conventions |
| `~/.copilot/skills/` | Global (all projects) | Personal skills you use everywhere          |

文件结构：

```shell
.github/skills/
└── my-skill/
    ├── SKILL.md           # Required: Skill definition and instructions
    ├── examples/          # Optional: Example files Copilot can reference
    │   └── sample.py
    └── scripts/           # Optional: Scripts the skill can use
        └── validate.sh
```

文件格式：

```markdown
---
name: code-checklist
description: Comprehensive code quality checklist with security, performance, and maintainability checks
license: MIT
---

# Code Checklist

When checking code, look for:

## Security
- SQL injection vulnerabilities
- XSS vulnerabilities
- Authentication/authorization issues
- Sensitive data exposure

## Performance
- N+1 query problems (running one query per item instead of one query for all items)
- Unnecessary loops or computations
- Memory leaks
- Blocking operations

## Maintainability
- Function length (flag functions > 50 lines)
- Code duplication
- Missing error handling
- Unclear naming

## Output Format
Provide issues as a numbered list with severity:
- [CRITICAL] - Must fix before merge
- [HIGH] - Should fix before merge
- [MEDIUM] - Should address soon
- [LOW] - Nice to have
```

使用方法：

* `/skills list`：列出已有的skills；`/skills info xxxx`：查看某个skill信息；`/skills reload`：重载

* `What skills did you use for that response?`：询问使用了什么skill

* `What skills do you have available for security reviews?`：询问有什么skill解决具体问题

* 触发方式它可以根据prompt自动触发，也可以手动触发，如下：

  `/generate-tests Create tests for the user authentication module`，其中`generate-tests`对应skill文件名称



## MCP(Model Context Protocol)

没有MCP，Copilot只能看到@本地文件；有MCP，它能浏览整个项目。

MCP配置在`~/.copilot/mcp-config.json`(全局)；`.mcp.json`项目根目录，用于项目本身。

文件格式如下：

```
{
  "mcpServers": {
    "server-name": {
      "type": "local",
      "command": "npx",
      "args": ["@package/server-name"],
      "tools": ["*"]
    }
  }
}
```



