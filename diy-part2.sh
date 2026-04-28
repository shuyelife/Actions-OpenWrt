#!/bin/bash
#!/bin/bash

# A. 【关键：拿回西瓜】先把 237 的闭源驱动底座强行拿过来
cp -f defconfig/mt7981-ax3000.config .config

# B. 【关键：揉进芝麻】把你的 hy.config (HyperModem/三剑客) 强行追加到底座后面
# 这里的 $CONFIG_FILE 对应你 Actions 里指定的 hy.config
[ -f "../$CONFIG_FILE" ] && cat "../$CONFIG_FILE" >> .config

# C. 【降妖除魔】物理抹除底座里的 ASR3000，强制指定唯一的 RAX3000M
# 这样 grep 就只会抓到一行名字，不会再报 Invalid format 错误
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

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
