


初期使用了 21版237 试用后发现不适合

后改用24版  5G支持库 代码没跟上 

退回 23.10  

用Siriling 发现 驱动在打架 ，搞不定。

用了 QModem 还行 还是有问题，凑合用吧。
-----------------------------------------------------------------------------------
Sirilin
https://github.com/Siriling/5G-Modem-Support

QModem
https://github.com/FUjr/modem_feeds.git;main
---------------------------------------------------------------------------------------------------------------
bin文件 uboot 用这个大文件版本
https://www.right.com.cn/forum/thread-8328967-1-1.html

刷回原厂固件，可以恢复空间，在重复刷uboot中 中间会损失 十几兆空间。
按照
https://www.right.com.cn/forum/thread-8346752-1-1.html
这个教程， 一定要看分区情况 ，
注意，在ita后 分区表是会变的  不看，运气不好刷到bl2 重启就完了 

kmod-mtd-rw  记得预装

不菜鸡救砖看这个
https://www.right.com.cn/forum/thread-8414036-1-1.html
只熟悉，代码没必要看 问豆包 会随机应变 


备份文件会上传到这里

