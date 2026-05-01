#!/bin/bash

# =========================================================
# 1. 核心底座合并 (继承 237 闭源 WiFi 驱动 + 个人精选插件)
# =========================================================
# 保存个人插件清单
mv .config user_config
# 引入 237 满血闭源驱动底座
cp -f defconfig/mt7981-ax3000.config .config
# 将个人插件追加到底座之后
cat user_config >> .config

# 降妖除魔：执行社区公认的“型号清理”，解决 abt_asr3000 报错
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config
# 清理临时文件
rm user_config

# =========================================================
# 2. 更新并安装所有软件源
# =========================================================
./scripts/feeds update -a
./scripts/feeds install -a
# 强制优先安装 QModem 相关源
./scripts/feeds install -f -p modem  

# =========================================================
# 3. 核心大扫除 (从源码底层彻底物理铲除 UPnP)
# =========================================================
sed -i 's/luci-app-upnp//g' include/target.mk
sed -i 's/luci-app-upnp//g' target/linux/mediatek/Makefile

# =========================================================
# 4. 插件高阶定制 
# =========================================================
# 拉取最新版 OpenClash (ADG 已交由官方源自动处理，绝不画蛇添足)
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash

# =========================================================
# 5. 基础网络设置
# =========================================================
# 锁定路由器默认 IP 
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate
