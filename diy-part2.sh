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
# 1. 忽略大小写精准替换依赖包名，去掉 .* 防止误删后续依赖
find feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm/+quectel_cm_5G/gI'
find package/feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm/+quectel_cm_5G/gI'

# 2. 修正架构为 all（即使该配置没选 H1，留着这行也不会报错）
find feeds/5gmodem/luci-app-hypermodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'
