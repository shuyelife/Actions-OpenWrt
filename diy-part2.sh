#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.

# 1. 强行修正依赖：不管它在 Makefile 里写的是 +quectel-cm 还是 +quectel-cm-5G
# 统一改为 quectel_cm_5G（对应你仓库里真实的拨号器包名）
# 1. 彻底删除主仓库中可能存在的同名旧包，防止“双胞胎”冲突
rm -rf feeds/packages/net/quectel-cm
rm -rf package/feeds/packages/quectel-cm

# 2. 强行把 5G 仓库里的拨号工具改名为系统期望的名字
# 这样无论插件喊的是 quectel-cm 还是别的，都能精准对上
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_NAME:=quectel_cm_5G/PKG_NAME:=quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm-5G/+quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel_cm_5G/+quectel-cm/g'

# 3. 强行修正架构为 all
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'

# 修改默认 IP 为 192.168.1.1
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate
# 修改默认密码为 shuye (先删掉原来的 root 行，再追加一行带密码的)
sed -i '/root/d' package/base-files/files/etc/shadow
echo 'root:$1$shuye$F/R9QOqG6nF9v7K.uF3E10:18872:0:99999:7:::' >> package/base-files/files/etc/shadow


# 删掉自带的旧版 OpenClash
rm -rf package/feeds/luci/luci-app-openclash
# 克隆官方最新版到 package 目录（优先级更高）
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash
