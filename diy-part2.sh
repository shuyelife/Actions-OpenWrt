#!/bin/bash

# 1. 强制使用 237 仓库提供的闭源驱动配置文件作为基础底座（西瓜）
cp -f defconfig/mt7981-ax3000.config .config

# A. 修改默认 IP
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate

# B. 三剑客：删旧、取新、授权 (注意顺序：先 clone 后 chmod)
# 1. AdGuardHome
rm -rf package/feeds/luci/luci-app-adguardhome
rm -rf package/feeds/packages/adguardhome
git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome
# 2. OpenClash
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash

# C. 5G 模块：清理冲突并修正拨号器名称
# 删掉可能导致“双胞胎”冲突的旧包
rm -rf package/feeds/packages/quectel-cm
rm -rf feeds/packages/net/quectel-cm

# 执行你那套非常专业的 Makefile 批量修正 (针对 5G 仓库)
# 注意：前提是你已经在 part1 里克隆了 package/5gmodem
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_NAME:=quectel_cm_5G/PKG_NAME:=quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm-5G/+quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel_cm_5G/+quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'
# 5. 统一授权
chmod -R 755 package/luci-app-adguardhome
chmod -R 755 package/luci-app-openclash
chmod -R 755 package/5gmodem 2>/dev/null || true
