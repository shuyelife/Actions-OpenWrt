#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
# 1. 强制使用仓库预设的 RAX3000M 满血配置文件（包含闭源驱动和加速）
# 注意：237仓库针对RAX3000M的预设文件可能叫 mt7981-rax3000m.config 或 mt7981-ax3000.config
# 我们需要先确认这个文件名。根据你的仓库，大概率是下面这一行：
cp -f defconfig/mt7981-ax3000.config .config
# 2. 【核心修改】将你真正想运行的那个配置（比如 m.config）的内容追加进去
# 注意：这行代码会把你的自定义需求强行注入到闭源驱动底座中
cat m.config >> .config
# 2. 核心修正：将模板中的默认设备（无论它是 asr3000 还是别的）全局替换为 rax3000m
# 这样可以确保 .config 里的设备 ID 唯一且正确，不会产生两个等号的环境变量错误
sed -i 's/CONFIG_TARGET_mediatek_mt7981_DEVICE_.*=y/CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y/g' .config
# 2. 修改设备 ID 确保匹配（我们在上一轮确认过的正确 ID）
# 1. 彻底删除源码自带的（或旧版的）AdGuard Home，防止冲突
rm -rf package/feeds/luci/luci-app-adguardhome
rm -rf package/feeds/packages/adguardhome

# 2. 克隆最新版 AdGuard Home LuCI 插件（界面版）
# 采用你截图中推荐的作者仓库，这是目前最稳的版本之一
git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# 3. 抄走那个关键的权限代码，确保插件脚本有执行权限
chmod -R 755 ./package/luci-app-adguardhome/*
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
# 修改默认密码为 shuye (先删掉原来的 root 行，再追加一行带密码的)
#sed -i '/root/d' package/base-files/files/etc/shadow
#echo 'root:$1$shuye$F/R9QOqG6nF9v7K.uF3E10:18872:0:99999:7:::' >> package/base-files/files/etc/shadow


# 删掉自带的旧版 OpenClash
rm -rf package/feeds/luci/luci-app-openclash
# 克隆官方最新版到 package 目录（优先级更高）
git clone --depth 1 -b master https://github.com/vernesong/OpenClash package/luci-app-openclash
