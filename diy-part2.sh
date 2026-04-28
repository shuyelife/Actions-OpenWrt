#!/bin/bash
# A. 确保西瓜：复制 237 仓库的闭源驱动底座
if [ -f "$CONFIG_FILE" ]; then
    # 先拿 237 仓库的闭源驱动底座
    cp -f defconfig/mt7981-ax3000.config .config
    # 再追加你当前任务指定的配置文件内容 (不管是 hy 还是 m)
    cat "$CONFIG_FILE" >> .config
fi

# C. 拨乱反正：清理多余设备 ID，强制指定 RAX3000M
sed -i '/CONFIG_TARGET_mediatek_mt7981_DEVICE_/d' .config
echo "CONFIG_TARGET_mediatek=y" >> .config
echo "CONFIG_TARGET_mediatek_mt7981=y" >> .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y" >> .config

# D. 5G 上网补丁：确保 NCM 协议和 TTL 工具必装
echo "CONFIG_PACKAGE_luci-proto-ncm=y" >> .config
echo "CONFIG_PACKAGE_wwan=y" >> .config
echo "CONFIG_PACKAGE_kmod-ipt-ipopt=y" >> .config
echo "CONFIG_PACKAGE_iptables-mod-ipopt=y" >> .config

# E. 权限护航：确保 5G 和 AD 插件有执行权限
chmod -R 755 ./package/luci-app-adguardhome 2>/dev/null || true


rm -rf package/feeds/luci/luci-app-adguardhome
rm -rf package/feeds/packages/adguardhome

# 2. 克隆最新版 AdGuard Home LuCI 插件（界面版）
# 采用你截图中推荐的作者仓库，这是目前最稳的版本之一
git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# 3. 接下来再补上你的 5G 协议支持（防止预设配置里没勾选 NCM）
#echo "CONFIG_PACKAGE_luci-proto-ncm=y" >> .config
#echo "CONFIG_PACKAGE_wwan=y" >> .config
# 1. 强行修正依赖：不管它在 Makefile 里写的是 +quectel-cm 还是 +quectel-cm-5G
# 统一改为 quectel_cm_5G（对应你仓库里真实的拨号器包名）
# 1. 彻底删除主仓库中可能存在的同名旧包，防止“双胞胎”冲突
rm -rf feeds/packages/net/quectel-cm
rm -rf package/feeds/packages/quectel-cm

# 2. 强行把 5G 仓库里的拨号工具改名为系统期望的名字
# 这样无论插件喊的是 quectel-cm 还是别的，都能精准对上
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_NAME:=quectel_cm_5G/PKG_NAME:=quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel-cm-5G/+quectel-cm/g'
find package/5gmodem -name "Makefile" | xargs sed -i 's/+quectel_cm_5G/+quectel-cm/g'

# 3. 强行修正架构为 all
find package/5gmodem -name "Makefile" | xargs sed -i 's/PKG_ARCHITECTURE:=.*/PKG_ARCHITECTURE:=all/g'

# 修改默认 IP 为 192.168.1.1
sed -i 's/192.168.[0-9]*.[0-9]*/192.168.1.1/g' package/base-files/files/bin/config_generate

# 删掉自带的旧版 OpenClash
rm -rf package/feeds/luci/luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash
