git clone --depth 1 https://github.com/kjxhb/lede openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
