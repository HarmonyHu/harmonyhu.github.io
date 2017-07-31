---
layout: post
title:  Git学习整理
date:   2015-05-10
categories: 技术类 Git
excerpt: Git学习整理
---

* content
{:toc}

## 一、存储分为4个阶段  
*   `workspace`: 当前可见的工作目录  
*   `stage(index)`：标记被Git管理的文件  
*   `local repository`：本地仓库，通过commit命令保存的各个版本  
*   `remote repository`：远程仓库，通过push命令提交的各个版本

## 二、环境配置  

* 配置邮箱和用户名:  
`git config --global user.email "you@example.com"`  
`git config --global user.name "Your Name"`  
(查看配置：`git config --global -l`)  

* 创建SSH key  
`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`  

>Enter file in which to save the key (/Users/you/.ssh/id_rsa):**直接回车**  
>Enter passphrase (empty for no passphrase):**直接回车,不然每次都要输密码**  
>Enter same passphrase again:**直接回车**  

* 将SSH key添加到ssh-agent  
先执行：  
`eval $(ssh-agent -s)`   
*如果是在linux上的git操作，则SSH Key命令是：*
```
eval `ssh-agent -s`  
```  
然后执行：  
`ssh-add ~/.ssh/id_rsa` 

* 将SSH key添加到服务器账户(如github)  
`clip < ~/.ssh/id_rsa.pub`  
然后在服务器账户上粘贴到SSH Key中

## 三、文件状态的变迁  

#### 1. 文件的4种状态  
* **untrack**: 代表没有被跟踪的文件，比如新放进git目录下的文件  
* **modified**: 代表被跟踪，且被修改的文件  
* **staged**: 代表待提交的文件(包括标记修改的、或者新增的、或者被解决冲突的文件）  
* **unmodified**: 代表被跟踪，且没有被修改的文件  

#### 2. 文件状态的变迁  
* `git add`操作，可以将untrack和modified状态转换成staged状态  
* `git commit`操作，可以将staged状态的文件提交到本地仓库，文件状态变为unmodifed    
* `git reset HEAD <file>`操作，可以将staged状态的文件回到modified状态  
* `git rm --cached <file>`操作，可以将其他状态转换成untrack状态  
* 编辑unmodified状态的文件，文件状态变为modified
* `git reset <SHA>`操作，回退到<SHA>历史版本，基于其修改的文件变为modified状态  
* `git reset --soft <SHA>`操作，回退历史版本，基于其修改的文件变为staged状态  
* `git reset --hard <SHA>`操作，回退历史版本，基于其修改的文件被删除  

## 四、命令操作（常用）  

#### 1. 本地仓库操作  

`git init`：将当前目录创建成本地仓库  
`git add`：标记文件，且该文件被管理  
├──`git add <filename>`  标记指定文件  
├──`git add .` 标记当前目前所有文件，包括子目录文件  
└──`git add *`=`git add .`=`git add -A`  
`git status`：查看工作目录状态  
`git rm --cached <filename>`：取消跟踪的文件  
`git commit -m "注释"`：将标记文件的修改提交到本地仓库  
├──`git commit -a -m "注释"`：将所有跟踪的文件的修改提交到本地仓库  
└──`git commit --amend`：修改上一次提交  

#### 2. 远程仓库操作  

`git remote`：远程仓库管理  
├──`git remote -v`：查看远程仓库  
├──`git remote add origin git@github.com:abc.git`：添加远程仓库地址  
├──`git remote rm origin`：删除origin地址  
├──`git remote set-url origin git@github.com:abc.git`：设定仓库地址  
└──`git remote rename origin github`：将更改远程库别名为github  
`git push`：将本地仓库更新到远程仓库  
├──`git push`：将本地的默认分支更新到远程的对应分支  
├──`git push origin master`：将master分支更新到origin仓库的master分支  
├──`git push origin master:mymaster`：将本地master分支更新到origin的mymaster分支  
├──`git push --force`：将分支强制更新到远程库  
└──`git push origin --delete branch1`:删除远程分支  
`git pull`：将远程仓库更新到本地仓库  
├──`git pull origin`：将origin库所有分支更新到本地  
├──`git pull origin branch1`：将origin库的branch1分支更新到本地  
└──`git pull -r`：等同于fetch+rebase(不过单个fetch可以下载全部远程分支)  
`git clone`：下载远程仓库到本地  
└──`git clone git@github.com:abc.git abc`：下载到abc文件夹  

#### 3. 分支及历史版本操作  

`git branch`：查看当前本地分支  
├──`git branch -a`：查看本地和远程所有分支  
├──`git branch branch1 origin/branch`：本地创建branch1分支，基于origin/branch分支  
├──`git branch mybranch <SHA>`：基于某个历史版本建立mybranch分支
├──`git branch -D branch1`:删除本地branch1分支  
├──`git branch -r -d origin/branch`：删除远程分支  
└──`git branch branch1 -u origin/branch`：将本地分支对应到远程分支  
`git checkout local`：切换到local分支  
├──`git checkout file_name`：放弃file_name的修改  
├──`git checkout -b mybranch origin/mybranch`：新建分支mybranch并切过去  
└──`git checkout --track origin/mybranch`:新建分支mybranch并切过去(--track==-t)  
`git reset`：恢复操作  
├──`git reset --hard <SHA>`：强制回退到某个历史版本  
└──`git reset --soft <SHA>`：回退到某个历史版本，但文件修改不变  
`git merge local`：当前分支合并local分支的修改  
`git rebase origin/branch`: 将本地新修改合并到远程最新修改之后  
`git cherry-pick <SHA>`：合入其他分支的某次修改  
`git log`：查看历史记录  
├──`git log -p -2`：-p代表查看修改内容，-2代表最近两条  
└──`git log --stat`：查看日志，且报告修改的简要信息  
`git show <SHA>`：查看某次修改的详细信息  

#### 4. 对比和补丁操作  
`git diff`：查看修改但没有staged的文件  
├──`git diff --staged`：查看修改且staged的文件  
├──`git difftool`：可以在.gitconfig文件中配置BeyondCompare工具对比差异  
└──`git difftool --staged`:同理  
`git format-patch -n`：将前n次的提交生成patch  
`git apply new.patch`：本地目录合入补丁  
`git am new.patch`：本地仓库和目录都合入补丁  

#### 5. 其他  
* 忽略文件  
将其添加到.gitignore或者.git/info/exclude中  
* 删除所有不被跟踪的文件  
`git clean -df`  
* 修改git配置  
`vi ~/.gitconfig`  
* 合并最近几次提交  
`git rebase -i <SHA>`，然后将第2个及之后的pick改成s，达到的效果是：将SHA之后（不包括SHA本身)的所有修改合并到SHA之后的一次修改  
* 强制pull  
`git fetch origin`  
`git reset --hard origin/mybranch`  
`git pull origin mybranch`  

