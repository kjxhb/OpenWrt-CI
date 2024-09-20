#!/bin/sh
#chmod +x compile-lede.sh && sh compile-lede.sh

# 下载LEDE源码
#git clone https://github.com/kjxhb/OpenWrt-CI
git clone --depth 1 https://github.com/coolsnowwolf/lede openwrt
cd openwrt

# 升级feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 添加插件
git clone --depth 1 https://github.com/vernesong/OpenClash package/OpenClash
cp -r ../OpenWrt-CI/files/luci-app-advancedsetting package
cp -r ../OpenWrt-CI/files/luci-app-cloudflared package
cp -r ../OpenWrt-CI/files/luci-app-fileassistant package
cp -r ../OpenWrt-CI/files/luci-app-msd_lite package
cp -r ../OpenWrt-CI/files/luci-theme-argon-lede package
#cp -r ../OpenWrt-CI/files/istore package
git clone https://github.com/linkease/istore package/istore
git clone https://github.com/linkease/nas-packages-luci package/nas-packages-luci
git clone https://github.com/linkease/nas-packages package/nas-packages
find package -path '*/quickstart/index.js' -exec sed -i 's#system/mounts#system/fstab#g' {} \;
find package -path '*/quickstart/index.js' -exec sed -i 's#services/samba4#nas/samba4#g' {} \;
find package -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "网络向导"/msgstr "向导"/' {} \;
find package -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "易有云文件管理器"/msgstr "易有云"/' {} \;
find package -path '*/linkease.lua' -exec sed -i 's/LinkEase"), 20/LinkEase"), 1/' {} \;
find package -path '*/quickstart.lua' -exec sed -i 's/NetworkPort"), 11/NetworkPort"), 41/' {} \;
# 替换cpuinfo
rm -rf package/lean/autocore/files/arm/sbin/cpuinfo
cp -r ../OpenWrt-CI/files/cpuinfo package/lean/autocore/files/arm/sbin
# 替换msd_lite
rm -rf feeds/packages/net/msd_lite
cp -r ../OpenWrt-CI/files/msd_lite feeds/packages/net
# 替换tailscale
rm -rf feeds/packages/net/tailscale
cp -r ../OpenWrt-CI/files/tailscale feeds/packages/net
# 替换update_cloudflare_com_v4.sh
rm -rf feeds/packages/net/ddns-scripts/files/update_cloudflare_com_v4.sh
cp ../OpenWrt-CI/files/update_cloudflare_com_v4.sh feeds/packages/net/ddns-scripts/files
# 修改cloudflared
sed -i 's/2023.2.2/2024.3.0/g' feeds/packages/net/cloudflared/Makefile
sed -i 's/b0abaff125d29c517894f6ea74dcc7044c92500670463595ba9ff4950a1d2fc2/6e5fda072d81b2d40208a0d244b44aaf607f26709711e157e23f44f812594e93/g' feeds/packages/net/cloudflared/Makefile
sed -i '/init.d/d' feeds/packages/net/cloudflared/Makefile
sed -i '/cloudflared.config $(1)/d' feeds/packages/net/cloudflared/Makefile
rm -rf feeds/packages/net/cloudflared/files/cloudflared.init
rm -rf feeds/packages/net/cloudflared/files/cloudflared.config
# 修改autosamba共享0777权限
sed -i 's/0666/0777/' package/lean/autosamba/files/20-smb
# 修改硬盘休眠配置文件
sed -i 's#sda#/mnt/sda1#g' feeds/packages/utils/hd-idle/files/hd-idle.config
# 修改插件顺序
find feeds/luci -path '*/network.lua' -exec sed -i 's/page.order  = 30/page.order  = 42/' {} \;
find feeds/luci -path '*/network.lua' -exec sed -i 's/page.order  = 60/page.order  = 41/' {} \;
find feeds/luci -path '*/network.lua' -exec sed -i '134s/page.order  = 50/page.order  = 43/' {} \;
find feeds/luci -path '*/firewall.lua' -exec sed -i 's/_("Firewall"), 60/_("Firewall"), 35/' {} \;
find feeds/luci -path '*/system.lua' -exec sed -i 's/Scheduled Tasks"), 46/Scheduled Tasks"), 51/' {} \;
find feeds/luci -path '*/arpbind.lua' -exec sed -i 's/MAC Binding"), 45/MAC Binding"), 65/' {} \;
find feeds/luci -path '*/ddns.lua' -exec sed -i 's/"Dynamic DNS"), 59/"Dynamic DNS"), 105/' {} \;
find feeds/luci -path '*/easymesh.lua' -exec sed -i 's/"EASY MESH"), 60/"EASY MESH"), 80/' {} \;
find feeds/luci -path '*/hd_idle.lua' -exec sed -i 's/("HDD Idle"), 60/("HDD Idle"), 70/' {} \;
find feeds/luci -path '*/terminal.lua' -exec sed -i 's/"TTYD Terminal"), 10/"TTYD Terminal"), 55/' {} \;
# 修改插件名称
find package -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "OpenClash"/msgstr "科学上网"/' {} \;
find feeds -path '*/zh-cn/base.po' -exec sed -i '2692s/msgstr "重启"/msgstr "系统重启"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's#msgstr "备份/升级"#msgstr "备份升级"#' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "上网时间控制"/msgstr "时间控制"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Argon 主题设置"/msgstr "主题设置"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's#msgstr "IP/MAC 绑定"#msgstr "MAC绑定"#' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "广告屏蔽大师 Plus+"/msgstr "广告屏蔽"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "动态 DNS(DDNS)"/msgstr "动态 DNS"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "easymesh"/msgstr "简单MESH"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Frp 内网穿透"/msgstr "FRP 穿透"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "诊断"/msgstr "网络诊断"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "带宽监控"/msgstr "带宽"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Socat"/msgstr "端口转发"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "TTYD 终端"/msgstr "命令终端"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "Turbo ACC 网络加速"/msgstr "网络加速"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "uHTTPd"/msgstr "WEB 管理"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "UPnP"/msgstr "UPnP转发"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "USB 打印服务器"/msgstr "USB 打印"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "KMS 服务器"/msgstr "KMS 激活"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "网络存储"/msgstr "存储"/' {} \;
find feeds -path '*/zh-cn/*.po' -exec sed -i 's/msgstr "FTP 服务器"/msgstr "FTP 服务"/' {} \;

# 配置.config
touch ./.config
# 机型设置:
cat >> .config <<EOF
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_cmcc_rax3000m-nand=y
EOF
# 常用插件
cat >> .config <<EOF
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_autosamba=y
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_cloudflared=y
CONFIG_PACKAGE_msd_lite=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-theme-argon-lede=y
CONFIG_PACKAGE_luci-app-accesscontrol=y
CONFIG_PACKAGE_luci-app-adbyby-plus=y
CONFIG_PACKAGE_luci-app-advancedsetting=y
CONFIG_PACKAGE_luci-app-arpbind=y
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-cloudflared=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-easymesh=y
CONFIG_PACKAGE_luci-app-fileassistant=y
CONFIG_PACKAGE_luci-app-filetransfer=n
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-hd-idle=y
CONFIG_PACKAGE_luci-app-linkease=y
CONFIG_PACKAGE_luci-app-msd_lite=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-nlbwmon=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-quickstart=y
CONFIG_PACKAGE_luci-app-ramfree=y
CONFIG_PACKAGE_luci-app-smartdns=y
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-turboacc=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-app-vsftpd=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-wrtbwmon=y
CONFIG_PACKAGE_luci-app-zerotier=n
CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-webui=n
CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-ng=n
CONFIG_PACKAGE_luci-app-unblockmusic_INCLUDE_UnblockNeteaseMusic_Go=n
EOF
make defconfig

# 下载软件包
make download -j8 V=s
find dl -size -1024c -exec rm -f {} \;

# 编译固件
make -j$(($(nproc) + 1)) V=s
