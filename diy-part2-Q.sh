#!/bin/bash

# =========================================================
# 1. 搬运 237 底座并提取 RAX3000M 单设备 (完美防报错)
# =========================================================
mv .config user_config
cp -f defconfig/mt7981-ax3000.config .config
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

# =========================================================
# 2. 降维打击：物理删除闲杂软件的源码目录 (彻底瘫痪强行复活机制)
# =========================================================
# 物理清除 UPnP
rm -rf feeds/luci/applications/luci-app-upnp
rm -rf feeds/routing/miniupnpd
# 物理清除 Samba 共享
rm -rf feeds/luci/applications/luci-app-ksmbd
rm -rf feeds/net/ksmbd-server
rm -rf feeds/luci/applications/luci-app-samba4
rm -rf feeds/net/samba4
# 物理清除 打印机
rm -rf feeds/luci/applications/luci-app-usb-printer
# 物理清除 繁重的 Argon 主题
rm -rf feeds/luci/themes/luci-theme-argon

# =========================================================
# 3. 防砖机制：将系统默认主题强制变更为轻量级 Bootstrap
# =========================================================
sed -i 's/luci-theme-argon/luci-theme-bootstrap/g' feeds/luci/collections/luci/Makefile

# =========================================================
# 4. 更新源并注入 5G 专属 Modem 驱动
# =========================================================
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -f -p modem

# =========================================================
# 5. 拉取最新版 OpenClash (更规范的目录层级命名)
# =========================================================
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/OpenClash

# =========================================================
# 6. 系统默认设置 (锁定网关 IP)
# =========================================================
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate

# =========================================================
# 7. 拼接你那份干干净净的个人配置单
# =========================================================
cat user_config >> .config
rm user_config
