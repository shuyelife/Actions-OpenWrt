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
find feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm.*/+quectel_cm_5G/g'

# 2. 强行修正架构：直接把 5gmodem 目录下所有插件的架构设为 all
# 这能彻底解决 "incompatible architecture" 的报错，让它在 MT7981 上畅通无阻
find feeds/5gmodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'
