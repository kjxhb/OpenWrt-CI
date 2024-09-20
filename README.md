# Openwrt云编译
来自仓库 https://github.com/hackyes/OpenWrt-CI
编译版本：大雕仓库 https://github.com/coolsnowwolf/lede
## 四种方式触发编译
1、推送文件到main分支自动编译（需去掉前面的#）
```
#  push:
#    branches: 
#      - main
```
2、每天固定时间自动编译（需去掉前面的#）
```
#  schedule:
#    - cron: 0 0 1 * *
```
3、点击started自动编译（需去掉前面的#）
```
#  watch:
#    types: started
```
4、手动运行编译
```
  workflow_dispatch:
```

## 使用说明：
1、.config配置文件生成方式如下：

&ensp;&ensp;方式1：打开下面链接生成配置，把.config内容替换成链接生成的配置内容

&ensp;&ensp;[https://hackyes.github.io/openwrt-menuconfig/index.html](https://hackyes.github.io/openwrt-menuconfig/index.html)

&ensp;&ensp;方式2：如果自己熟悉插件名称，在.config里直接编辑

&ensp;&ensp;方式3：在.yml运行代码里生成：
```
          touch ./.config
          # 机型设置:
          cat >> .config <<EOF
          CONFIG_TARGET_ramips=y
          CONFIG_TARGET_ramips_mt7621=y
          CONFIG_TARGET_ramips_mt7621_DEVICE_hiwifi_hc5962=y
          EOF
          # 常用插件
          cat >> .config <<EOF
          CONFIG_PACKAGE_ipv6helper=y
          CONFIG_PACKAGE_autosamba=y
          CONFIG_PACKAGE_automount=y
          CONFIG_PACKAGE_ddns-scripts-cloudflare=y
          CONFIG_PACKAGE_xupnpd=y
          CONFIG_PACKAGE_luci-theme-argon=y
          CONFIG_PACKAGE_luci-app-argon-config=y
          EOF
```
2、 运行.yml时关于SSH

~~在Run Workflow时把SSH connection to Actions的值改为true，在 Actions 日志页面等待执行到SSH connection to Actions步骤，会出现类似下面的信息：~~
```
To connect to this session copy-n-paste the following into a terminal or browser:
ssh Y26QeagDtsPXp2mT6me5cnMRd@nyc1.tmate.io
https://tmate.io/t/Y26QeagDtsPXp2mT6me5cnMRd
```
~~复制 SSH 连接命令粘贴到终端内执行，或者复制链接在浏览器中打开使用网页终端。（网页终端可能会遇到黑屏的情况，按 Ctrl+C 即可），输入：~~
`cd openwrt && make menuconfig`
~~完成后按Ctrl+D组合键或执行exit命令退出，后续编译工作将自动进行。~~

等待编译成功后，到Actions里下载固件即可
