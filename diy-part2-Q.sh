#!/bin/bash

# 1. 搬运底座 (保留)
mv .config user_config
cp -f defconfig/mt7981-ax3000.config .config
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

# 3. 既然你要用 Bootstrap，直接在配置里指定，不要删 Argon
echo "CONFIG_PACKAGE_luci-theme-bootstrap=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-argon=n" >> .config

# 4. 更新源并安装 (顺序不要乱)
./scripts/feeds update -a
./scripts/feeds install -a
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
# 强制修补：如果安装脚本漏掉了面板，我们手动把它拎出来
# 5. 不要手动拉取 OpenClash，让 feeds 自动处理，除非你确定要用 master 分支
# 如果一定要换，就在 ncm.txt 里写清楚，不要在脚本里 rm -rf 物理覆盖

# 6. 个人配置拼接 (保留)
cat user_config >> .config
rm user_config
