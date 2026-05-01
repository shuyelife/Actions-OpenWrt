#!/bin/bash

# 1. 引入 237 满血闭源驱动底座
mv .config user_config
cp -f defconfig/mt7981-ax3000.config .config

# 2. 官方标准操作：剥离“全家桶”，精准提取 RAX3000M 身份
# (完美适配 P3TERX 流水线的单设备抓取逻辑，不再报错)
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

# 3. 暴力斩杀不需要的内置包 (物理删除，防死灰复燃)
sed -i '/luci-app-upnp/d' .config
sed -i '/miniupnpd/d' .config
sed -i '/luci-app-ksmbd/d' .config
sed -i '/ksmbd-server/d' .config
sed -i '/luci-app-samba4/d' .config
sed -i '/samba4/d' .config
sed -i '/luci-app-usb-printer/d' .config
sed -i '/luci-theme-argon/d' .config

# 4. 追加你的纯净版个人插件配置
cat user_config >> .config

# 5. 更新软件源
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -f -p modem

# 6. 拉取最新版 OpenClash
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash

# 7. 锁定默认 IP
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate

# 清理现场
rm user_config
