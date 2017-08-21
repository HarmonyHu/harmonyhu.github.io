---
layout: post
title:  我的独立域名博客开通了
date:   2015-03-06
categories: Git
tags: Git 博客 域名
---

* content
{:toc}

近来浏览一些技术性文章，发现大神们都有属于自己的独立域名博客，对大神的专业表示敬畏的同时，也很好奇：搞个独立域名博客很难吗？我是一个喜欢研究新东西的人，于是决定自己也试试整一个出来。于是就整出来了：<http://www.harmonyhu.com>

### 过程  
当然这整个过程并非简单，我也并非聪明人，能够这么顺利全靠互联网，具体的说，是靠互联网上各个乐于分享的人们。这里我整个过程参考的链接也罗列出来，希望也能帮到一些人。  
[理想的写作环境：Git+Github+Markdown+Jekyll](http://www.yangzhiping.com/tech/writing-space.html)  
[搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)  
[使用 GitHub, Jekyll 打造自己的免费独立博客](http://blog.csdn.net/on_1y/article/details/19259435)  
[Jekyll Themes](http://jekyllthemes.org/)  
[markdown语法实例](http://maxiang.info/)  
[图解git](http://marklodato.github.io/visual-git-guide/index-zh-cn.html)  
这个过程又学习了不少新东西，也成功搭建起了github pages博客<http://harmonyhu.github.io>  

### 域名绑定  
经过同学介绍，域名在[GoDaddy](https://www.godaddy.com/)上购买，可以用支付宝，很方便。在想`域名`上花了一些时间，起初打算用自己的名字，最后还是用了自己的网名HarmonyHu(我姓胡，我想做一个与内外和谐的人)。最后怎么把`harmonyhu.com`绑定到`harmonyhu.github.io`花了一些时间，网上还没有详细的教程，所以我就来写一个。
首先在GoDaddy网上，在`My Domains`页面选择`Domain Details`，如下图:  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/godaddy1.jpg)  
  
  
然后选择`DNS ZONE FILE`，如下图：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/godaddy2.jpg)  
  
  
然后填写`A(Host)`和`CName(Alias)`信息，如下图：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/godaddy3.jpg)  
上图中的ip地址可以在[GitHub Pages Help](https://help.github.com/articles/tips-for-configuring-an-a-record-with-your-dns-provider/)找到。  

最后在[GitHub](https://github.com/)的对应工程根路径加入CNAME文件，并且内容填上`harmonyhu.com`，如下图：  
![](https://github.com/HarmonyHu/harmonyhu.github.io/raw/master/_posts/images/github1.jpg)
  
这样就大功告成了。

### 博客写些什么  
我认为写博客是很有好处的，一来可以分享知识回馈互联网的恩惠，二来可以结交志同道合的朋友，三来可以记录自己的历程，四来可以在躁动的社会环境下舒缓自己的心智。  
既然域名博客这么豪华的诞生了，那么以后就会充分用上，常来写写。但不会写像微博上哪些只言片语的东西，用尼古拉斯•卡尔的《浅薄》一书的观点来说，就是这些支离破碎的东西会让人越来越"浅薄"。所以我打算写一些深入的东西，至少字数上要多于微博。  
我大致会写这些东西：读书心得体会；日常生活观感；技术文章。另外也会把以前在其他网站上发表的文章，目前看来还有价值的，就都搬移过来。  

最后，我的独立域名博客开通了，好开心O(∩_∩)O~~