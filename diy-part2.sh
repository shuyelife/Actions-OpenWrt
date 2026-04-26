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
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# 忽略大小写强行修正依赖，并同时覆盖 feeds 和 package 两个可能的路径
find feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm.*/+quectel_cm_5G/gI'
find package/feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm.*/+quectel_cm_5G/gI'

# 修正架构，路径改为通配符防止找不到文件
find feeds/5gmodem/luci-app-hypermodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'
