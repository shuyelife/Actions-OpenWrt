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

# 强制删除所有可能导致冲突的 Target 定义，确保只剩下 RAX3000M NAND
sed -i 's/CONFIG_TARGET_mediatek_mt7981_DEVICE_generic-spim-nor-rfb=y/# CONFIG_TARGET_mediatek_mt7981_DEVICE_generic-spim-nor-rfb is not set/g' .config
