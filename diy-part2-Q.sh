#!/bin/bash

# =========================================================
# 1. 搬运 237 满血底座
# =========================================================
mv .config user_config
cp -f defconfig/mt7981-ax3000.config .config

# =========================================================
# 2. 根部物理切除：彻底斩断垃圾包的“连带依赖链”
# (用 /d 直接删掉整行配置，防止系统自动复活它们)
# =========================================================
# 杀 UPnP 及其底层核心
sed -i '/luci-app-upnp/d' .config
sed -i '/miniupnpd/d' .config
# 杀 Samba/Ksmbd 共享及其底层核心
sed -i '/luci-app-ksmbd/d' .config
sed -i '/ksmbd-server/d' .config
sed -i '/luci-app-samba4/d' .config
sed -i '/samba4/d' .config
# 杀打印机服务
sed -i '/luci-app-usb-printer/d' .config
# 杀重型主题
sed -i '/luci-theme-argon/d' .config

# =========================================================
# 3. 追加你的精选配置 (此刻底座已经干净了)
# =========================================================
cat user_config >> .config

# =========================================================
# 4. 更新软件源
# =========================================================
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -f -p modem

# =========================================================
# 5. 核心插件拉取 (去掉了 ADG 的克隆，完全交由官方源处理)
# =========================================================
# OpenClash (这个库更新快且兼容，必须保留克隆)
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash

# =========================================================
# 6. 系统默认设置
# =========================================================
# 修改默认 IP 为 192.168.1.1
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate

# 打扫战场
rm user_config
