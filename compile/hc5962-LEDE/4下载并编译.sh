cd openwrt
# 下载插件
make download -j8
find dl -size -1024c -exec rm -f {} \;
# 编译
make -j$(($(nproc) + 1))
