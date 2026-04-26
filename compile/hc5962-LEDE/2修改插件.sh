# 修改内核5.4和hnat驱动
#sed -i 's/PATCHVER:=5.10/PATCHVER:=5.4/' openwrt/target/linux/ramips/Makefile
#rm -rf openwrt/target/linux/ramips/dts/mt7621_hiwifi_hc5962.dts
#rm -rf openwrt/target/linux/ramips/mt7621/base-files/etc/board.d/02_network
#cp files/hc5962-lede/LEDE-hnat-02network-dst/mt7621_hiwifi_hc5962.dts openwrt/target/linux/ramips/dts
#cp files/hc5962-lede/LEDE-hnat-02network-dst/02_network openwrt/target/linux/ramips/mt7621/base-files/etc/board.d
# 替换dts
rm -rf openwrt/target/linux/ramips/dts/mt7621_hiwifi_hc5962.dts
cp -r files/hc5962-lede/LEDE-DSA-02network-dst/mt7621_hiwifi_hc5962.dts openwrt/target/linux/ramips/dts
# 修复batman-adv编译错误
#rm -rf openwrt/feeds/routing/batman-adv
#cp -r files/hc5962-lede/batman-adv openwrt/feeds/routing
# 添加插件
git clone --depth 1 https://github.com/kjxhb/luci-app-eqosplus openwrt/package/luci-app-eqosplus
git clone -b dev --depth 1 https://github.com/vernesong/OpenClash openwrt/package/OpenClash
rm -rf openwrt/feeds/luci/applications/luci-app-openclash
rm -rf openwrt/feeds/luci/applications/luci-app-advancedsetting
rm -rf openwrt/feeds/luci/applications/luci-app-fileassistant
cp -r files/luci-app-advancedsetting openwrt/feeds/luci/applications
cp -r files/luci-app-fileassistant openwrt/package
# 替换luci-theme-argon的cascade.css
rm -rf openwrt/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css
cp -r files/cascade.css openwrt/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css
# 替换msd_lite
rm -rf openwrt/feeds/packages/net/msd_lite
cp -r files/msd_lite openwrt/feeds/packages/net
# 替换tailscale
#rm -rf openwrt/feeds/packages/net/tailscale
#cp -r files/tailscale openwrt/feeds/packages/net
#sed -i 's/VERSION:=.*/VERSION:=1.72.1/g' openwrt/feeds/packages/net/tailscale/Makefile
#sed -i 's/HASH:=.*/HASH:=21b529e85144f526b61e0998c8b7885d53f17cba21252e5c7252c4014f5f507b/' openwrt/feeds/packages/net/tailscale/Makefile
# 替换update_cloudflare_com_v4.sh
rm -rf openwrt/feeds/packages/net/ddns-scripts/files/usr/lib/ddns/update_cloudflare_com_v4.sh
cp files/update_cloudflare_com_v4.sh openwrt/feeds/packages/net/ddns-scripts/files/usr/lib/ddns
# 替换cloudflared
rm -rf openwrt/feeds/luci/applications/luci-app-cloudflared
cp -r files/luci-app-cloudflared openwrt/feeds/luci/applications
sed -i '/init.d/d;/cloudflared.config $(1)/d;' openwrt/feeds/packages/net/cloudflared/Makefile
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.init
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.config
# 替换autosamba的20-smb
rm -rf openwrt/package/lean/autosamba/files/20-smb
cp -r files/20-smb openwrt/package/lean/autosamba/files
# 修改autosamba
sed -i '/default PACKAGE/s/_KSMBD/_SAMBA3/' openwrt/package/lean/autosamba/Makefile
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/files/20-smb
# 替换15-automount脚本
rm -rf openwrt/package/lean/automount/files/15-automount
cp -r files/15-automount openwrt/package/lean/automount/files
# 修改硬盘休眠配置文件
sed -i 's#sda#/mnt/sda1#g' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
# 替换luci-app-zerotier
#rm -rf openwrt/feeds/luci/applications/luci-app-zerotier
#cp -r files/luci-app-zerotier openwrt/feeds/luci/applications
# 修改插件顺序和分类
find openwrt/feeds/luci -path '*/luci-mod-system.json' -exec sed -i 's/"order": 46/"order": 48/' {} \;
find openwrt/feeds/luci -path '*/luci-mod-system.json' -exec sed -i 's/"order": 50/"order": 47/' {} \;
find openwrt/feeds/luci -path '*/luci-mod-status.json' -exec sed -i 's/"order": 6/"order": 2/' {} \;
find openwrt/feeds/luci -path '*/luci-mod-network.json' -exec sed -i 's/"order": 45/"order": 31/' {} \;
find openwrt/feeds/luci -path '*/luci-mod-network.json' -exec sed -i 's/"order": 40/"order": 32/' {} \;
find openwrt/feeds/luci -path '*/luci-app-firewall.json' -exec sed -i 's/"order": 60/"order": 35/' {} \;
find openwrt/feeds/luci -path '*/luci-app-cloudflared.json' -exec sed -i 's#admin/vpn#admin/services#g' {} \;
find openwrt/feeds/luci -path '*/luci-app-hd-idle.json' -exec sed -i 's#admin/services#admin/nas#g' {} \;
find openwrt/feeds/luci -path '*/luci-app-nlbwmon.json' -exec sed -i 's#admin/services/#admin/#g' {} \;
find openwrt/feeds/luci -path '*/luci-app-samba4.json' -exec sed -i 's#admin/services#admin/nas#g' {} \;
find openwrt/feeds/luci -path '*/luci-app-ttyd.json' -exec sed -i 's#admin/services#admin/system#g' {} \;
find openwrt/feeds/luci -path '*/arpbind.lua' -exec sed -i 's/MAC Binding"), 45/MAC Binding"), 65/' {} \;
find openwrt/feeds/luci -path '*/ddns.lua' -exec sed -i 's/"Dynamic DNS"), 59/"Dynamic DNS"), 105/' {} \;
find openwrt/feeds/luci -path '*/easymesh.lua' -exec sed -i 's/"EASY MESH"), 60/"EASY MESH"), 80/' {} \;
find openwrt/feeds/luci -path '*/hd_idle.lua' -exec sed -i 's/("HDD Idle"), 60/("HDD Idle"), 70/' {} \;
find openwrt/feeds/luci -path '*/terminal.lua' -exec sed -i 's/"TTYD Terminal"), 10/"TTYD Terminal"), 55/' {} \;
find openwrt/feeds/luci -path '*/luci-app-zerotier.json' -exec sed -i 's/"order": 90/"order": 115/' {} \;
find openwrt/feeds/luci -path '*/luci-app-zerotier.json' -exec sed -i 's/vpn/services/g' {} \;
find openwrt/feeds/luci -path '*/eqos.lua' -exec sed -i 's/"EQoS"/_("EQoS"), 80/g' {} \;
find openwrt/feeds/luci -path '*/eqos.lua' -exec sed -i 's/"network"/"services"/g' {} \;
# 修改插件名称
find openwrt/package/OpenClash -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "OpenClash"/msgstr "科学上网"/' {} \;
find openwrt/feeds -path '*/zh_Hans/base.po' -exec sed -i '9416s/msgstr "重启"/msgstr "系统重启"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's#msgstr "备份与更新"#msgstr "备份升级"#' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "上网时间控制"/msgstr "时间控制"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Argon 主题设置"/msgstr "主题设置"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's#msgstr "IP/MAC绑定"#msgstr "MAC绑定"#' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Cloudflare 零信任隧道"/msgstr "Cloudflare"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "easymesh"/msgstr "简单MESH"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "动态 DNS"/msgstr "动态DNS"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "frp 客户端"/msgstr "Frp客户端"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "诊断"/msgstr "网络诊断"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "带宽监控"/msgstr "带宽"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "MultiWAN 管理器"/msgstr "负载均衡"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Socat"/msgstr "端口转发"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Tailscale"/msgstr "内网穿透"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "终端"/msgstr "命令终端"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Turbo ACC 网络加速"/msgstr "网络加速"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "uHTTPd"/msgstr "WEB管理"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "UPnP IGD 和 PCP"/msgstr "UPnP转发"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "USB 打印服务器"/msgstr "USB 打印"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "KMS 服务器"/msgstr "KMS 激活"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "网络存储"/msgstr "存储"/' {} \;
find openwrt/feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "FTP 服务器"/msgstr "FTP 服务"/' {} \;
