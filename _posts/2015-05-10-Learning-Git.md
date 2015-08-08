---
layout: post
title:  Git学习整理
date:   2015-05-10
categories: 技术类 Git
excerpt: Git学习整理
---

* content
{:toc}

##一、存储分为4个阶段  
*   `workspace`: 当前可见的工作目录  
*   `stage(index)`：标记被Git管理的文件  
*   `local repository`：本地仓库，通过commit命令保存的各个版本  
*   `remote repository`：远程仓库，通过push命令提交的各个版本

##二、命令操作（常用）  

####1. 环境配置  

* 配置邮箱和用户名:  
`git config --global user.email "you@example.com"`  
`git config --global user.name "Your Name"`  

* 创建SSH key  
`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`  

>Enter file in which to save the key (/Users/you/.ssh/id_rsa): [Press enter]  
>Enter passphrase (empty for no passphrase): [Type a passphrase]  
>Enter same passphrase again: [Type passphrase again]  
>Your identification has been saved in /Users/you/.ssh/id_rsa.  
>Your public key has been saved in /Users/you/.ssh/id_rsa.pub.  
>The key fingerprint is:  
>01:0f:f4:3b:ca:85:d6:17:a1:7d:f0:68:9d:f0:a2:db your_email@example.com  

* 将SSH key添加到ssh-agent  
`eval $(ssh-agent -s)`  
`ssh-add ~/.ssh/id_rsa`  

* 将SSH key添加到服务器账户(如github)  
`clip < ~/.ssh/id_rsa.pub`  
然后在服务器账户上粘贴到SSH Key中

####2. 本地仓库操作  

`git init`：将当前目录创建成本地仓库  
`git add`：标记文件，且该文件被管理  
├──`git add <filename>`  标记指定文件  
├──`git add .` 标记当前目前所有文件，包括子目录文件  
└──`git add *`=`git add .`=`git add -A`  
`git status`：查看工作目录状态  
`git rm --cached <filename>`：取消标记  
`git commit -m "注释"`：将标记文件的修改提交到本地仓库  
└──`git commit -a -m "注释"`：将所有管理文件的修改提交到本地仓库  


####3. 远程仓库操作  

`git remote`：远程仓库管理  
├──`git remote -v`：查看远程仓库  
└──`git remote add origin git@github.com:abc.git`：添加远程仓库地址  
├──`git remote rm origin`：删除origin地址  
└──`git remote set-url origin git@github.com:abc.git`：设定仓库地址  
`git push`：将本地仓库更新到远程仓库  
└──`git push -u origin master`:将master分支更新到origin仓库  
`git pull`：将远程仓库更新到本地仓库  
`git clone`：下载远程仓库到本地  


####4. 分支及历史版本操作  

`git branch`：查看当前本地分支  
└──`git branch local`：本地创建local分支  
`git checkout local`：切换到local分支  
└──`git checkout file_name`：放弃file_name的修改  
`git merge local`：当前分支合并local分支的修改  
`git diff HEAD`：本地目录对比本地仓库的修改  
`git format-patch -n`：将前n次的提交生成patch  
`git apply new.patch`：本地目录合入补丁  
`git am new.patch`：本地仓库和目录都合入补丁  
