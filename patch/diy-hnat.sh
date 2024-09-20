#!/bin/sh

# 替换交换机hnat交换机文件
rm -rf openwrt/target/linux/ramips/dts/mt7621_hiwifi_hc5962.dts
rm -rf openwrt/target/linux/ramips/mt7621/base-files/etc/board.d/02_network
cp files/LEDE-hnat-02network-dst/mt7621_hiwifi_hc5962.dts openwrt/target/linux/ramips/dts
cp files/LEDE-hnat-02network-dst/02_network openwrt/target/linux/ramips/mt7621/base-files/etc/board.d
