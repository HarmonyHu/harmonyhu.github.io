###### Mac快捷键

| 文本                                                         | 文件                                                         | 触控板                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ | :----------------------------------------------------------- |
| Command-C 拷贝<br/>Command-V 粘贴<br/>Command-X 剪切<br/>Command-Z 撤销<br/>Command-A 全选<br/>command-S 保存<br/>Command-F 查找 | Command <- 删除文件<br/>Command c 拷贝文件<br/>Command v 粘贴文件<br/>Command option v 移动文件<br />Command Shift 4 选取截图<br/>Command Shift 3 全屏截图<br/>Control 空格 切换输入法 | 单指点     鼠标左键<br/>双指点     鼠标右键<br/>双指上下滑  滚动页面<br/>双指张合    页面放大缩小<br/>三指上滑    多界面切换<br/>四指张开    桌面<br/>四指合并    程序 |

###### 常用命令

```bash
find /home -name xxxx -exec cp {} abc/ \; #将找到的文件拷贝到abc目录
scp -r -P 2020 charle.hu@47.244.27.123:~/cvimodel_regression .
minicom -D /dev/cu.usbserial-0001 -b 115200 -C $(date +%Y-%m-%d_%H%M%S).log #esc+z菜单
mount /dev/mmcblk1p1 /tmp
tar -xzf file.tar.gz #解压
tar –czf jpg.tar.gz *.jpg #压缩
export SET_CHIP_NAME=cv182x
export TPU_ENABLE_PMU=1
model_runner --dump-all-tensors --input in.npz --model  test.cvimodel
             --batch-num 4 --output output.npz --reference  out_ref.npz
cvimodel_tool -a dump -i resnet50.cvimodel
for name in `ls *.3.2`; do mv $name ${name%.3.2}.3; done #将文件.3.2改名为.3
ctrl+q+p # 退出但不关闭docker
```

###### vim

| 控制快捷键                                                   | 文本操作                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| dd 剪切光标所在行<br/>yy 拷贝光标所在行<br/>p 粘贴到光标所在行<br/>u 撤销上一次操作<br/>ctrl+u 恢复撤销 | /search 从头到为搜索<br/>?search 从尾到头搜索<br/>n表示下一个，shift+n表示上一个<br/>:10 跳转到第10行<br/>gg 跳到文头，shift+g 跳到文尾<br/>^ 跳到行头，$ 跳到行尾 |

