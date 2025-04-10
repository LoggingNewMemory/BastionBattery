#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

if getprop ro.vendor.build.fingerprint | grep -iq -e tecno/lh7n; then
  setprop ro.vendor.transsion.backlight_hal.optimization 1
fi
