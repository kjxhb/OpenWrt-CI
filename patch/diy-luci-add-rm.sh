#!/bin/sh

# 替换原argon主题和argon-config主题设置
rm -rf openwrt/feeds/luci/themes/luci-theme-argon
#cp -r files/luci-theme-argon openwrt/feeds/luci/themes
git clone -b 18.06 https://github.com/kjrzxu/luci-theme-argon.git openwrt/feeds/luci/themes/luci-theme-argon
rm -rf openwrt/feeds/luci/applications/luci-app-argon-config
#cp -r files/luci-app-argon-config openwrt/feeds/luci/applications
git clone -b 18.06 https://github.com/kjrzxu/luci-app-argon-config.git openwrt/feeds/luci/applications/luci-app-argon-config

# 替换默认主题bootstrap为argon主题
#sed -i 's/bootstrap/argon/g' openwrt/feeds/luci/collections/luci/Makefile

# 替换update_cloudflare_com_v4.sh
rm -rf openwrt/feeds/packages/net/ddns-scripts/files/update_cloudflare_com_v4.sh
cp files/update_cloudflare_com_v4.sh openwrt/feeds/packages/net/ddns-scripts/files

#修改cloudflared
sed -i 's/2023.2.2/2023.10.0/g' openwrt/feeds/packages/net/cloudflared/Makefile
sed -i 's/b0abaff125d29c517894f6ea74dcc7044c92500670463595ba9ff4950a1d2fc2/2d2df4dd4992eef485f7ffebc0a1e9e6292b42ca42341f2e46224f17155e9532/g' openwrt/feeds/packages/net/cloudflared/Makefile
#sed -i 's/2023.2.2/2023.7.3/g' openwrt/feeds/packages/net/cloudflared/Makefile
#sed -i 's/b0abaff125d29c517894f6ea74dcc7044c92500670463595ba9ff4950a1d2fc2/772ddcb721f5b479192117d1156b1091505721aa81d6bab3de9577176b930191/g' openwrt/feeds/packages/net/cloudflared/Makefile
sed -i '/init.d/d' openwrt/feeds/packages/net/cloudflared/Makefile
sed -i '/cloudflared.config $(1)/d' openwrt/feeds/packages/net/cloudflared/Makefile
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.init
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.config

#替换原msd_lite
rm -rf openwrt/feeds/packages/net/msd_lite
git clone https://github.com/kjrzxu/msd_lite.git openwrt/feeds/packages/net/msd_lite

#替换automount自动共享设置文件
rm -rf openwrt/package/lean/automount/files/15-automount
cp -r files/15-automount openwrt/package/lean/automount/files

#修改autosamba中samba4为samba并更改0777权限
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/Makefile
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/files/20-smb
sed -i 's/0666/0777/' openwrt/package/lean/autosamba/files/20-smb

#修改插件配置文件
sed -i 's#sda#/mnt/sda1#g' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
sed -i 's/10/5/g' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
sed -i 's/0/1/g' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
