cd openwrt
make -j$(($(nproc) + 1))
