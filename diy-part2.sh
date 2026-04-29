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

# 添加 FUjr 的 modem 仓库源
#echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
# 更新并安装 modem feed
./scripts/feeds update modem
# 标准“强制”安装逻辑：使用 -f 参数强制覆盖系统旧驱动，确保使用 QModem 优化的驱动
./scripts/feeds install -a -f -p modem

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
#rm -rf package/feeds/packages/quectel-cm
#rm -rf feeds/packages/net/quectel-cm
# 执行你那套非常专业的 Makefile 批量修正 (针对 5G 仓库)
# 注意：前提是你已经在 part1 里克隆了 package/5gmodem
#find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_NAME:=quectel_cm_5G/PKG_NAME:=quectel-cm/g'
#find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm-5G/+quectel-cm/g'
#find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel_cm_5G/+quectel-cm/g'
#find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'
# 5. 统一授权
#chmod -R 755 package/luci-app-adguardhome
#chmod -R 755 package/luci-app-openclash

# =========================================================
# 5G 堡垒深度优化 (1.时区NTP | 2.主机名 | 11.欢迎语 | 14.日志保护)
# =========================================================

# 1. 预设 SSH 登录欢迎语 (项 11)
# 展现老兵搞机范儿，同时确认脚本执行成功
mkdir -p package/base-files/files/etc
cat <<EOF > package/base-files/files/etc/banner
  _______  _______     _______  _______  _______  _______ 
 |  _    ||  _    |   |       ||   _   ||       ||   _   |
 | |_|   || |_|   |   |    ___||  |_|  ||_     _||  |_|  |
 |       ||       |   |   | __ |       |  |   |  |       |
 |  _    ||  _    |   |   ||  ||       |  |   |  |       |
 | |_|   || |_|   |   |   |_| ||   _   |  |   |  |   _   |
 |_______||_______|   |_______||__| |__|  |___|  |__| |__|
 ---------------------------------------------------------
  RM500U CMCC RAX3000M NAND | 24.10 (Kernel 6.6)
         SHUYE                2026-04-29
 ---------------------------------------------------------
EOF

# 2. 注入自动化系统配置脚本 (项 1, 2, 14)
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-system-setup
#!/bin/sh

# --- 预设 1: 时区与 NTP (同步北京时间) ---
# 确保 AdGuardHome 和系统日志时间准确
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.ntp.server='ntp.aliyun.com' 'time1.cloud.tencent.com' 'ntp.ntsc.ac.cn' '2.openwrt.pool.ntp.org'

# --- 预设 2: 修改路由主机名 ---
# 告别默认的 ImmortalWrt，改用个性化名称
uci set system.@system[0].hostname='SHUYE'

# --- 预设 14: 保护 Flash 寿命 ---
# 将 5G 模块和三剑客产生的海量日志挂载到内存 (/tmp)，防止刷爆闪存
uci set system.@system[0].log_file='/tmp/system.log'
uci set system.@system[0].log_size='512'

# 提交更改
uci commit system
exit 0
EOF

# 确保脚本具备执行权限
chmod +x package/base-files/files/etc/uci-defaults/99-system-setup


# A. 修改默认 IP
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate


chmod -R 755 package/5gmodem 2>/dev/null || true

# ---------------------------------------------------------
# WiFi 自动预设脚本 (针对 MTK 闭源驱动 24.10 增强版)
# ---------------------------------------------------------

# 1. 创建 uci-defaults 存放目录
mkdir -p package/base-files/files/etc/uci-defaults

# 2. 写入 WiFi 自动化配置脚本
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-wifi
#!/bin/sh

# 强制开启无线并设置 2.4G (通常为 radio0)
uci set wireless.radio0.disabled='0'
uci set wireless.default_radio0.ssid='ZTE-5A2H8Y'
uci set wireless.default_radio0.encryption='sae-mixed'
uci set wireless.default_radio0.key='Wang12345..'
uci set wireless.default_radio0.ieee80211w='1'

# 强制开启无线并设置 5G (通常为 radio1)
uci set wireless.radio1.disabled='0'
uci set wireless.default_radio1.ssid='ZTE-5A2H8Y-5G'
uci set wireless.default_radio1.encryption='sae-mixed'
uci set wireless.default_radio1.key='Wang12345..'
uci set wireless.default_radio1.ieee80211w='1'

# 提交并保存
uci commit wireless

# 针对某些特殊固件，如果上面的 radio0/1 不生效，执行万能循环
index=0
for dev in \$(uci show wireless | grep "=wifi-device" | cut -d. -f2 | cut -d= -f1); do
    uci set wireless.\${dev}.disabled='0'
    if [ "\$index" = "0" ]; then
        SSID='ZTE-5A2H8Y'
    else
        SSID='ZTE-5A2H8Y-5G'
    fi
    # 找到关联该设备的接口并设置
    iface=\$(uci show wireless | grep "device='\${dev}'" | cut -d. -f2 | cut -d= -f1)
    [ -n "\$iface" ] && {
        uci set wireless.\${iface}.ssid="\$SSID"
        uci set wireless.\${iface}.encryption='sae-mixed'
        uci set wireless.\${iface}.key='Wang12345..'
    }
    index=\$((index+1))
done

uci commit wireless
exit 0
EOF

# 确保脚本具备执行权限
chmod +x package/base-files/files/etc/uci-defaults/99-custom-wifi
