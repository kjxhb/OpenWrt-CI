git clone --depth 1 https://github.com/coolsnowwolf/lede openwrt
cd openwrt
sed -i 's/;openwrt-23.05//g' feeds.conf.default
sed -i 's/;openwrt-24.10//g' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a
