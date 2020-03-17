---
layout: post
title:  MFC 自定义简单的工具栏类
date:   2009-04-28
categories: 编程
tags: 编程 MFC
---
>本文最初是2009-04-28发表于[CSDN](http://blog.csdn.net/harmonyhu/article/details/4134476),当时正在用MFC乐此不疲地写各种Windows的小应用。如今出来工作很多年了，几乎很少用到MFC的东西，而且在移动互联网时代的到来，MFC也跟着落伍了。再来回看当时做的事情，真是微不足道，人果真要把时间花在那些亘久不变的事物上。 

<!--more-->

本以为很简单的东西,居然 查了半天资料,才勉强完成这个工具栏类,也懒得去再优化.为了方便以后查阅,就写在博客里吧.

```c++
//CToolBarCtrlEx.h  
#pragma once  
class CToolBarCtrlEx : public CToolBarCtrl{  
public:    
    CToolTipCtrl m_Tip;  
    CImageList m_ImageList;  
  
public:  
    void CToolBarCtrlEx::CreateEx(
            CWnd *pParentWnd,
            int numButton,
            UINT *res,  //res表示bitmap资源序列
            UINT *str,  //str表示字符串资源序列,以它作为各个按钮的ID
            CSize size=CSize(32,32), //size表bitmap图像大小
            int pixel=ILC_COLOR24    //pixel表示bitmap图像像素,如ILC_COLOR24  
    );
};  
```

----------

```c++
#include "stdafx.h"  
#include"CToolBarCtrlEx.h"  
  
void CToolBarCtrlEx::CreateEx(
        CWnd *pParentWnd,
        int numButton, 
        UINT *res, 
        UINT *str,
        CSize size,
        int pixel
        )  
{  
    //初始化ImageList  
    CBitmap bm;  
    m_ImageList.Create(size.cx,size.cy,pixel|ILC_MASK,0,0);  
    for(int i=0;i<numButton;i++){          
        bm.LoadBitmap(res[i]);  
        m_ImageList.Add(&bm,(CBitmap *)NULL);  
        bm.Detach();  
    }  
    //设置工具条  
    Create(TBSTYLE_FLAT |CCS_TOP| WS_CHILD | WS_VISIBLE|WS_BORDER | CCS_ADJUSTABLE|CBRS_TOOLTIPS,
           CRect(0,0,0,0),
           pParentWnd,
           NULL
           );  
    SetBitmapSize(size);  
    m_Tip.Create(pParentWnd);  
    TBBUTTON * Buttons=new TBBUTTON[numButton];  
    CRect toolRect;  
    CString temp;  
    for(int i=0;i<numButton;i++){  
        Buttons[i].iString=AddStrings("");  
        Buttons[i].dwData=0;  
        Buttons[i].fsState=TBSTATE_ENABLED ;  
        Buttons[i].fsStyle=TBSTYLE_BUTTON;  
        Buttons[i].iBitmap=i;  
        Buttons[i].idCommand=str[i];  
    }  
    SetImageList(&m_ImageList);  
    AddButtons(numButton,Buttons);  
    delete [] Buttons;  
  
    //位置摆放  
    GetWindowRect(&toolRect);  
    //改变主窗口大小  
    CRect parentRect;  
    pParentWnd->GetWindowRect(&parentRect);  
    parentRect.bottom+=toolRect.Height()+30;  
    pParentWnd->MoveWindow(&parentRect,FALSE);  
  
    //改变子窗口位置  
    CWnd * pwndChild=pParentWnd->GetWindow(GW_CHILD);  
    CRect rcChild;  
    while(pwndChild){  
        if(pwndChild!=this){
            pwndChild->GetWindowRect(&rcChild);  
            pParentWnd->ScreenToClient(rcChild);    
            rcChild.top+=toolRect.Height()+30;  
            rcChild.bottom+=toolRect.Height()+30;  
            pwndChild->MoveWindow(&rcChild,FALSE);  
        }
        pwndChild=pwndChild->GetNextWindow();  
    }  
  
    for(int i=0;i<numButton;i++){  
        temp.LoadString(str[i]);  
        GetItemRect(i,&toolRect);  
        m_Tip.AddTool(this,temp,&toolRect,res[i]);  
    }  
    SetToolTips(&m_Tip);  
    AutoSize();  
    ShowWindow(SW_SHOW);  
} 
```
