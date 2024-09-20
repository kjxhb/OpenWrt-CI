#!/bin/sh

#添加界面主页IPTV分类和顺序
sed -i '/"VPN"/a entry({"admin", "iptv"}, firstchild(), _("IPTV"), 45).index = true' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua
sed -i '/"VPN"/s/$/\n/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua
sed -i '/"IPTV"/s/^/\t/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua

#添加界面主页Control分类和顺序
#sed -i '/"VPN"/a entry({"admin", "control"}, firstchild(), "Control", 44).index = true' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua
#sed -i '/"VPN"/s/$/\n/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua
#sed -i '/"IPTV"/s/^/\t/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua

#修改界面主页名称和顺序
sed -i 's/page.order  = 30/page.order  = 42/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/network.lua
sed -i '134s/50/43/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/network.lua
sed -i 's/_("Diagnostics"/_("网络诊断"/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/network.lua
sed -i 's/page.order  = 60/page.order  = 41/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/network.lua

sed -i 's/_("Scheduled Tasks"), 46/_("Scheduled Tasks"), 51/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua
sed -i 's#_("Backup / Flash Firmware"#_("备份升级"#' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua
sed -i 's/_("Reboot"/_("系统重启"/' openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

# 替换原argon主题和argon-config主题设置
rm -rf openwrt/feeds/luci/themes/luci-theme-argon
#cp -r files/luci-theme-argon openwrt/feeds/luci/themes
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git openwrt/feeds/luci/themes/luci-theme-argon
rm -rf openwrt/feeds/luci/applications/luci-app-argon-config
#cp -r files/luci-app-argon-config openwrt/feeds/luci/applications
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git openwrt/feeds/luci/applications/luci-app-argon-config

# 替换默认主题bootstrap为argon主题
#sed -i 's/bootstrap/argon/ig' openwrt/feeds/luci/collections/luci/Makefile

# 替换update_cloudflare_com_v4.sh
rm -rf openwrt/feeds/packages/net/ddns-scripts/files/update_cloudflare_com_v4.sh
cp files/update_cloudflare_com_v4.sh openwrt/feeds/packages/net/ddns-scripts/files

#修改hd-idle配置文件
sed -i 's#sda#/mnt/sda1#' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
sed -i 's/10/5/' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config
sed -i 's/0/1/' openwrt/feeds/packages/utils/hd-idle/files/hd-idle.config

#修改coudflared配置文件
sed -i '/cloudflared.init/d' openwrt/feeds/packages/net/cloudflared/Makefile
rm openwrt/feeds/packages/net/cloudflared/files/cloudflared.init
sed -i '/cloudflared.config $(1)/d' openwrt/feeds/packages/net/cloudflared/Makefile
rm -rf openwrt/feeds/packages/net/cloudflared/files/cloudflared.config

#替换automount自动共享设置文件
rm -rf openwrt/package/lean/automount/files/15-automount
cp -r files/15-automount openwrt/package/lean/automount/files

#修改autosamba中samba4为samba并更改0777权限
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/Makefile
sed -i 's/samba4/samba/g' openwrt/package/lean/autosamba/files/20-smb
sed -i 's/0666/0777/' openwrt/package/lean/autosamba/files/20-smb

#替换原msd_lite
rm -rf openwrt/feeds/packages/net/msd_lite
git clone https://github.com/ximiTech/msd_lite.git openwrt/feeds/packages/net/msd_lite

#修改插件名称并调整顺序
#sed -i 's/_("ShadowSocksR Plus+"/_("科学上网"/' openwrt/feeds/helloworld/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua

sed -i 's/_("OpenClash"/_("科学上网"/' openwrt/feeds/openclash/luci-app-openclash/luasrc/controller/openclash.lua

sed -i 's/_("Internet Access Schedule Control"/_("时间控制"/' openwrt/feeds/luci/applications/luci-app-accesscontrol/luasrc/controller/mia.lua
sed -i 's/"services"/"control"/g' openwrt/feeds/luci/applications/luci-app-accesscontrol/luasrc/controller/mia.lua
sed -i 's/services/control/g' openwrt/feeds/luci/applications/luci-app-accesscontrol/luasrc/view/mia/mia_status.htm

sed -i 's/_("ADBYBY Plus +"/_("广告屏蔽"/' openwrt/feeds/luci/applications/luci-app-adbyby-plus/luasrc/controller/adbyby.lua

sed -i 's/_("AliyunDrive WebDAV"/_("阿里云盘"/' openwrt/feeds/luci/applications/luci-app-aliyundrive-webdav/luasrc/controller/aliyundrive-webdav.lua
sed -i 's/"services"/"nas"/g' openwrt/feeds/luci/applications/luci-app-aliyundrive-webdav/luasrc/controller/aliyundrive-webdav.lua

sed -i 's/_("Argon Config"), 90/_("主题设置"), 80/' openwrt/feeds/luci/applications/luci-app-argon-config/luasrc/controller/argon-config.lua

sed -i 's#"IP/MAC Binding"), 45#"MAC绑定"), 65#' openwrt/feeds/luci/applications/luci-app-arpbind/luasrc/controller/arpbind.lua

sed -i 's/_("BaiduPCS Web"), 300/_("百度网盘"), 20/' openwrt/feeds/luci/applications/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua

sed -i 's/_("Dynamic DNS"), 59/_("动态 DNS"), 105/' openwrt/feeds/luci/applications/luci-app-ddns/luasrc/controller/ddns.lua

sed -i 's/_("EASY MESH"), 60/_("简单MESH"), 80/' openwrt/feeds/luci/applications/luci-app-easymesh/luasrc/controller/easymesh.lua

sed -i 's/_("Firewall"), 60/_("Firewall"), 35/' openwrt/feeds/luci/applications/luci-app-firewall/luasrc/controller/firewall.lua

sed -i 's/_("Frp Setting"/_("内网穿透"/' openwrt/feeds/luci/applications/luci-app-frpc/luasrc/controller/frp.lua

sed -i 's/_("Guest-wifi"), 19/_("Guest-wifi"), 70/' openwrt/feeds/luci/applications/luci-app-guest-wifi/luasrc/controller/guest-wifi.lua

sed -i 's/_("HDD Idle"), 60/_("HDD Idle"), 70/' openwrt/feeds/luci/applications/luci-app-hd-idle/luasrc/controller/hd_idle.lua
sed -i 's/"services"/"nas"/g' openwrt/feeds/luci/applications/luci-app-hd-idle/luasrc/controller/hd_idle.lua

sed -i 's/_("omcproxy")/_("omcproxy"), 10/' openwrt/feeds/luci/applications/luci-app-omcproxy/luasrc/controller/omcproxy.lua
sed -i 's/"services"/"iptv"/g' openwrt/feeds/luci/applications/luci-app-omcproxy/luasrc/controller/omcproxy.lua

sed -i 's/"services"/"nas"/g' openwrt/feeds/luci/applications/luci-app-samba/luasrc/controller/samba.lua

sed -i 's/"services"/"nas"/g' openwrt/feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua

sed -i 's/"Socat"), 100/"端口转发"), 100/' openwrt/feeds/luci/applications/luci-app-socat/luasrc/controller/socat.lua

sed -i 's/"TTYD Terminal"), 10/"命令终端"), 55/' openwrt/feeds/luci/applications/luci-app-ttyd/luasrc/controller/terminal.lua

sed -i 's/"Turbo ACC Center"), 101/"网络加速"), 101/' openwrt/feeds/luci/applications/luci-app-turboacc/luasrc/controller/turboacc.lua

sed -i 's/_("udpxy")/_("IPTV单播"), 99/' openwrt/feeds/luci/applications/luci-app-udpxy/luasrc/controller/udpxy.lua
sed -i 's/"services"/"iptv"/g' openwrt/feeds/luci/applications/luci-app-udpxy/luasrc/controller/udpxy.lua

sed -i 's/_("uHTTPd")/_("WEB 管理"), 102/' openwrt/feeds/luci/applications/luci-app-uhttpd/luasrc/controller/uhttpd/uhttpd.lua

sed -i 's/_("Unblock Netease Music"), 50/_("网易歌曲"), 50/' openwrt/feeds/luci/applications/luci-app-unblockmusic/luasrc/controller/unblockmusic.lua

sed -i 's/_("UPnP")/_("UPnP转发"), 101/' openwrt/feeds/luci/applications/luci-app-upnp/luasrc/controller/upnp.lua

sed -i 's/_("USB Printer Server"), 50/_("USB 打印"), 100/' openwrt/feeds/luci/applications/luci-app-usb-printer/luasrc/controller/usb_printer.lua
sed -i 's/"网络存储"/"存储"/' openwrt/feeds/luci/applications/luci-app-usb-printer/po/zh-cn/usb-printer.po

sed -i 's/_("KMS Server"), 100/_("KMS 激活"), 110/' openwrt/feeds/luci/applications/luci-app-vlmcsd/luasrc/controller/vlmcsd.lua

sed -i 's/_("FTP Server")/_("FTP 服务"), 80/' openwrt/feeds/luci/applications/luci-app-vsftpd/luasrc/controller/vsftpd.lua

sed -i 's/"网络存储"/"存储"/' openwrt/feeds/luci/applications/luci-app-vsftpd/po/zh-cn/vsftpd.po

sed -i 's/"services"/"control"/g' openwrt/feeds/luci/applications/luci-app-wol/luasrc/controller/wol.lua

#sed -i 's/_("ZeroTier"), 99/_("ZeroTier"), 120/' openwrt/feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
#sed -i 's/"vpn", "zerotier"/"services", "zerotier"/g' openwrt/feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
#sed -i 's/vpn/services/g' openwrt/feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm
