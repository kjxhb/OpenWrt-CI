#!/bin/sh
#chmod +x compile-immortalwrt.sh && sh compile-immortalwrt.sh

# 下载LEDE源码
#git clone https://github.com/kjxhb/OpenWrt-CI
git clone --depth 1 https://github.com/padavanonly/immortalwrt-mt798x immortalwrt
cd immortalwrt

# 升级feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 添加插件
cp -r ../OpenWrt-CI/files/luci-app-advanced package
cp -r ../OpenWrt-CI/files/luci-app-cloudflared package
cp -r ../OpenWrt-CI/files/luci-app-msd_lite package
#替换
rm -rf package/istore
cp -r ../OpenWrt-CI/files/istore package
rm -rf feeds/luci/applications/luci-app-fileassistant
cp -r ../OpenWrt-CI/files/luci-app-fileassistant feeds/luci/applications
# 替换msd_lite
rm -rf feeds/packages/net/msd_lite
cp -r ../OpenWrt-CI/files/msd_lite feeds/packages/net
# 替换tailscale
rm -rf feeds/packages/net/tailscale
cp -r ../OpenWrt-CI/files/tailscale feeds/packages/net
# 修改cloudflared
sed -i '/init.d/d' feeds/packages/net/cloudflared/Makefile
sed -i '/cloudflared.config $(1)/d' feeds/packages/net/cloudflared/Makefile
rm -rf feeds/packages/net/cloudflared/files/cloudflared.init
rm -rf feeds/packages/net/cloudflared/files/cloudflared.config

# 修改插件名称
find package -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "OpenClash"/msgstr "科学上网"/' {} \;
find feeds -path '*/zh_Hans/base.po' -exec sed -i '2692s/msgstr "重启"/msgstr "系统重启"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's#msgstr "备份/升级"#msgstr "备份升级"#' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "上网时间控制"/msgstr "时间控制"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Argon 主题设置"/msgstr "主题设置"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's#msgstr "IP/MAC 绑定"#msgstr "MAC绑定"#' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "广告屏蔽大师 Plus+"/msgstr "广告屏蔽"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "动态 DNS(DDNS)"/msgstr "动态 DNS"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "easymesh"/msgstr "简单MESH"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Frp 内网穿透"/msgstr "FRP 穿透"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "诊断"/msgstr "网络诊断"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "带宽监控"/msgstr "带宽"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Socat"/msgstr "端口转发"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "TTYD 终端"/msgstr "命令终端"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "Turbo ACC 网络加速"/msgstr "网络加速"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "uHTTPd"/msgstr "WEB 管理"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "UPnP"/msgstr "UPnP转发"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "USB 打印服务器"/msgstr "USB 打印"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "KMS 服务器"/msgstr "KMS 激活"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "网络存储"/msgstr "存储"/' {} \;
find feeds -path '*/zh_Hans/*.po' -exec sed -i 's/msgstr "FTP 服务器"/msgstr "FTP 服务"/' {} \;

# 配置.config
touch ./.config
# 机型设置:
cat >> .config <<EOF
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_mt7981=y
CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m=y
EOF
# 常用插件
cat >> .config <<EOF
CONFIG_PACKAGE_default-settings-chn=y
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_autosamba=y
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_cloudflared=y
CONFIG_PACKAGE_msd_lite=y
CONFIG_PACKAGE_tailscale=n
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-accesscontrol=y
CONFIG_PACKAGE_luci-app-adbyby-plus=y
CONFIG_PACKAGE_luci-app-advanced=y
CONFIG_PACKAGE_luci-app-arpbind=y
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-cloudflared=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-easymesh=y
CONFIG_PACKAGE_luci-app-eqos-mtk=y
CONFIG_PACKAGE_luci-app-fileassistant=y
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-hd-idle=y
CONFIG_PACKAGE_luci-app-linkease=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-msd_lite=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-nlbwmon=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-quickstart=y
CONFIG_PACKAGE_luci-app-ramfree=y
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-turboacc=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-app-vsftpd=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-wrtbwmon=y
CONFIG_PACKAGE_luci-app-filetransfer=n
CONFIG_PACKAGE_luci-app-ksmbd=n
CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-webui=n
CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-ng=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ChinaDNS_NG=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Simple_Obfs=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Client=n
CONFIG_PACKAGE_luci-app-usb-printer=n
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_ShadowsocksR_Libev_Server=n
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Trojan=n
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray=n
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray_plugin=n
EOF
make defconfig

# 下载软件包
make download -j8 V=s
find dl -size -1024c -exec rm -f {} \;

# 编译固件
make -j$(($(nproc) + 1)) V=s
