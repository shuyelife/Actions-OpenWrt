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
# 1. 强行修正依赖包名，不管它原来是大写还是小写，统一指向 quectel_cm_5G
find feeds/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm/+quectel_cm_5G/g'

# 2. 强行把 hypermodem 设为全架构通用（解决 incompatible architecture 报错）
if [ -f "feeds/5gmodem/luci-app-hypermodem/Makefile" ]; then
    sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g' feeds/5gmodem/luci-app-hypermodem/Makefile
fi
