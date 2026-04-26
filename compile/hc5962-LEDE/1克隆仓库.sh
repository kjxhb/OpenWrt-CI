git clone --depth 1 https://github.com/coolsnowwolf/lede openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
