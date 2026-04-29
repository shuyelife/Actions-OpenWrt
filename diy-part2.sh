#!/bin/bash
# 1. 保存芝麻：先把你上传的自定义配置（此刻名为 .config）改名存起来
mv .config user_config

# 2. 搬运西瓜：把 237 仓库自带的闭源驱动底座搬过来，生成新的 .config
cp -f defconfig/mt7981-ax3000.config .config

# 3. 强强联手：把你的插件配置追加到底座后面（后来者居上，覆盖底座的默认插件）
cat user_config >> .config

# 4. 降妖除魔：执行社区公认的“型号清理”，解决 abt_asr3000 报错 [cite: 37]
# 先把所有 mt7981 的设备 ID 删干净
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
# 重新精准植入唯一的 RAX3000M 身份
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

# 5. 清理现场
rm user_config

# D. 后续的插件删除、克隆、改名、授权（保持你之前的代码不动）
# ... (rm -rf, git clone, sed 修正 5G 名字, chmod 等)
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

# A. 修改默认 IP
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate


chmod -R 755 package/5gmodem 2>/dev/null || true

# ---------------------------------------------------------
# WiFi 自动预设脚本 (24.10 / WPA2 & WPA3 混合兼容版)
# ---------------------------------------------------------

# 1. 创建 uci-defaults 存放目录
mkdir -p package/base-files/files/etc/uci-defaults

# 2. 写入 WiFi 自动化配置脚本
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-wifi
#!/bin/sh

# 动态获取并设置 2.4G (兼容模式)
DEVICE_2G=\$(uci show wireless | grep "band='2g'" | cut -d. -f1 | uniq)
for dev in \$DEVICE_2G; do
    uci set wireless.\${dev}.ssid='ZTE-5A2H8Y'
    uci set wireless.\${dev}.encryption='sae-mixed'  # 开启 WPA2/WPA3 混合模式
    uci set wireless.\${dev}.key='Wang12345..'
    uci set wireless.\${dev}.ieee80211w='1'         # PMF 设为可选，照顾老设备
    uci set wireless.\${dev}.disabled='0'
done

# 动态获取并设置 5G (兼容模式)
DEVICE_5G=\$(uci show wireless | grep "band='5g'" | cut -d. -f1 | uniq)
for dev in \$DEVICE_5G; do
    uci set wireless.\${dev}.ssid='ZTE-5A2H8Y-5G'
    uci set wireless.\${dev}.encryption='sae-mixed'  # 开启 WPA2/WPA3 混合模式
    uci set wireless.\${dev}.key='Wang12345..'
    uci set wireless.\${dev}.ieee80211w='1'         # PMF 设为可选，照顾老设备
    uci set wireless.\${dev}.disabled='0'
done

# 提交并保存
uci commit wireless
exit 0
EOF
