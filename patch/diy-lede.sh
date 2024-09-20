#!/bin/sh

#修改feeds.conf.default,在telephony字段行后一行添加SSR
#sed -i '/telephony/a src-git helloworld https://github.com/fw876/helloworld.git' openwrt/feeds.conf.default
sed -i '/^#.*helloworld/s/^#//' openwrt/feeds.conf.default
#修改feeds.conf.default,在helloworld字段行后一行添加我的库package
sed -i '/helloworld/a src-git package https://github.com/kjrzxu/package.git' openwrt/feeds.conf.default

sed -i '/helloworld/a src-git openclash https://github.com/vernesong/OpenClash.git' openwrt/feeds.conf.default

#修改默认插件
#sed -i 's/luci-app-filetransfer //' openwrt/include/target.mk
#sed -i '/ca-certificates/s/$/ \\/' openwrt/include/target.mk
#sed -i '/ca-certificates/s/$/\n/' openwrt/include/target.mk
#sed -i '/ca-certificates/r files/target.txt' openwrt/include/target.mk
