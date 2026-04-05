# 修复batman-adv编译错误
rm -rf openwrt/feeds/routing/batman-adv
cp -r files/hc5962-lede/batman-adv openwrt/feeds/routing
# 添加插件
git clone --depth 1 https://github.com/vernesong/OpenClash openwrt/package/OpenClash
cp -r files/luci-app-advancedsetting openwrt/package
cp -r files/luci-app-cloudflared openwrt/package
cp -r files/luci-app-fileassistant openwrt/package
cp -r files/luci-app-msd_lite openwrt/package
cp -r files/luci-theme-argon-lede openwrt/package
# 替换msd_lite
rm -rf openwrt/feeds/packages/net/msd_lite
cp -r files/msd_lite openwrt/feeds/packages/net
# 替换tailscale
#rm -rf openwrt/feeds/packages/net/tailscale
#cp -r files/tailscale openwrt/feeds/packages/net
sed -i 's/VERSION:=.*/VERSION:=1.72.1/g' openwrt/feeds/packages/net/tailscale/Makefile
sed -i 's/HASH:=.*/HASH:=21b529e85144f526b61e0998c8b7885d53f17cba21252e5c7252c4014f5f507b/' openwrt/feeds/packages/net/tailscale/Makefile
# 替换update_cloudflare_com_v4.sh
rm -rf openwrt/feeds/packages/net/ddns-scripts/files/update_cloudflare_com_v4.sh
cp files/update_cloudflare_com_v4.sh openwrt/feeds/packages/net/ddns-scripts/files
#rm -rf openwrt/feeds/packages/net/ddns-scripts/files/usr/lib/ddns/update_cloudflare_com_v4.sh
#cp files/update_cloudflare_com_v4.sh openwrt/feeds/packages/net/ddns-scripts/files/usr/lib/ddns
# 修改cloudflared
sed -i 's/VERSION:=.*/VERSION:=2024.9.1/g' openwrt/feeds/packages/net/cloudflared/Makefile
sed -i 's/HASH:=.*/HASH:=f96b703ea848bc538322eb957749b0b2395e0cf83213cf310cbde0a3f598eac4/' openwrt/feeds/packages/net/cloudflared/Makefile
sed -i '/init.d/d;/cloudflared.config $(1)/d;' openwrt/feeds/packages/net/cloudflared/Makefile
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.init
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.config
# 修改autosamba和automount
rm -rf openwrt/package/lean/autosamba/files/20-smb
cp -r files/20-smb openwrt/package/lean/autosamba/files
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/Makefile
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/files/20-smb
rm -rf openwrt/package/lean/automount/files/15-automount
cp -r files/15-automount openwrt/package/lean/automount/files
# 修改硬盘休眠配置文件
sed -i 's#sda#/mnt/sda1#g' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
# 修改插件顺序
find openwrt/feeds/luci -path '*/network.lua' -exec sed -i 's/page.order  = 30/page.order  = 42/' {} \;
find openwrt/feeds/luci -path '*/network.lua' -exec sed -i 's/page.order  = 60/page.order  = 41/' {} \;
find openwrt/feeds/luci -path '*/network.lua' -exec sed -i '134s/page.order  = 50/page.order  = 43/' {} \;
find openwrt/feeds/luci -path '*/firewall.lua' -exec sed -i 's/_("Firewall"), 60/_("Firewall"), 35/' {} \;
find openwrt/feeds/luci -path '*/system.lua' -exec sed -i 's/Scheduled Tasks"), 46/Scheduled Tasks"), 51/' {} \;
find openwrt/feeds/luci -path '*/arpbind.lua' -exec sed -i 's/MAC Binding"), 45/MAC Binding"), 65/' {} \;
find openwrt/feeds/luci -path '*/ddns.lua' -exec sed -i 's/"Dynamic DNS"), 59/"Dynamic DNS"), 105/' {} \;
find openwrt/feeds/luci -path '*/easymesh.lua' -exec sed -i 's/"EASY MESH"), 60/"EASY MESH"), 80/' {} \;
find openwrt/feeds/luci -path '*/hd_idle.lua' -exec sed -i 's/("HDD Idle"), 60/("HDD Idle"), 70/' {} \;
find openwrt/feeds/luci -path '*/terminal.lua' -exec sed -i 's/"TTYD Terminal"), 10/"TTYD Terminal"), 55/' {} \;
find openwrt/feeds/luci -path '*/zerotier.lua' -exec sed -i 's/"ZeroTier"), 99/"ZeroTier"), 115/' {} \;
find openwrt/feeds/luci -path '*/zerotier.lua' -exec sed -i 's/"vpn"/"services"/g' {} \;
find openwrt/feeds/luci -path '*/zerotier.lua' -exec sed -i '/firstchild/d;' {} \;
# 修改插件名称
find openwrt/package/OpenClash -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "OpenClash"/msgstr "科学上网"/' {} \;
find openwrt/feeds -path '*/zh-cn/base.po' -exec sed -i '2692s/msgstr "重启"/msgstr "系统重启"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's#msgstr "备份/升级"#msgstr "备份升级"#' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "上网时间控制"/msgstr "时间控制"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Argon 主题设置"/msgstr "主题设置"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's#msgstr "IP/MAC 绑定"#msgstr "MAC绑定"#' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "广告屏蔽大师 Plus+"/msgstr "广告屏蔽"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "动态 DNS(DDNS)"/msgstr "动态 DNS"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "easymesh"/msgstr "简单MESH"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Frp 内网穿透"/msgstr "FRP 穿透"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "诊断"/msgstr "网络诊断"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "带宽监控"/msgstr "带宽"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Socat"/msgstr "端口转发"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "TTYD 终端"/msgstr "命令终端"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Turbo ACC 网络加速"/msgstr "网络加速"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "uHTTPd"/msgstr "WEB 管理"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "UPnP"/msgstr "UPnP转发"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "USB 打印服务器"/msgstr "USB 打印"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "KMS 服务器"/msgstr "KMS 激活"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "网络存储"/msgstr "存储"/' {} \;
find openwrt/feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "FTP 服务器"/msgstr "FTP 服务"/' {} \;
