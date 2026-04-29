#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
#git clone --depth 1 https://github.com/Siriling/5G-Modem-Support package/5gmodem
# 1. 彻底删除你之前 diy-part1.sh 里的这一行（重要，防止双重冲突）
# sed -i '/5G-Modem-Support/d' diy-part1.sh (如果你之前是 sed 进去的)
# 或者直接在文件中删除 git clone Siriling 的那一行

# 2. 按照 QModem 官方标准，添加 feed 源
echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
