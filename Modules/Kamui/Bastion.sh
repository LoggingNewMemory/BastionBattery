#!/bin/bash

# Battery Modifications
setprop persist.sys.shutdown.mode hibernate
setprop persist.radio.add_power_save 1
setprop wifi.supplicant_scan_interval 300 
setprop ro.ril.disable.power.collapse 1
setprop ro.config.hw_fast_dormancy 1
setprop ro.semc.enable.fast_dormancy true
setprop ro.config.hw_quickpoweron true
setprop ro.mot.eri.losalert.delay 1000
setprop ro.config.hw_power_saving true
setprop pm.sleep_mode 1
setprop ro.ril.sensor.sleep.control 1
setprop power_supply.wakeup enable

# Additional Battery Optimizations
setprop ro.ril.power.collapse 1
setprop power.saving.enabled 1
setprop battery.saver.low_level 30
setprop power.saving.enable 1
setprop persist.radio.apm_sim_not_pwdn 1
setprop ro.ril.enable.amr.wideband 0
setprop power.saving.low_screen_brightness 1
setprop ro.config.hw_smart_battery 1
setprop ro.config.hw_power_profile low

# Dalvik and Kernel Modifications
setprop persist.android.strictmode 0
setprop ro.kernel.android.checkjni 0
setprop ro.kernel.checkjni 0
setprop ro.config.nocheckin 1
setprop ro.compcache.default 0
setprop dalvik.vm.execution-mode int:jit
setprop dalvik.vm.verify-bytecode true
setprop dalvik.vm.jmiopts forcecopy
setprop debug.kill_allocating_task 0
setprop ro.ext4fs 1
setprop ro.setupwizard.mode DISABLED
setprop dalvik.vm.heaputilization 0.25
setprop dalvik.vm.heaptargetutilization 0.75

# Disable USB Debugging Popup
setprop persist.adb.notify 0

# Allow to free more RAM
setprop persist.sys.purgeable_assets 1
setprop ro.config.low_ram enable

# Smoother video playback
setprop video.accelerate.hw 1
setprop media.stagefright.enable-player true
setprop media.stagefright.enable-meta true
setprop media.stagefright.enable-scan false
setprop media.stagefright.enable-http true

# UI Tweaks
setprop persist.sys.ui.hw 1
setprop view.scroll_friction 10
setprop debug.composition.type gpu
setprop debug.performance.tuning 1

# Miscellaneous
setprop persist.sys.gmaps_hack 1
setprop debug.sf.ddms 0
setprop ro.warmboot.capability 1
setprop logcat.live disable

# CPU Core Control
setprop ro.vendor.qti.core_ctl_min_cpu 4
setprop ro.vendor.qti.core_ctl_max_cpu 4

# Start Kamui Auto
# By default. the Governor is sugov_ext (Yea Yamada use custom kernel)
# So I set this to set the Governor to Schedhorizon / Schedutil (hehe)
sh /data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh 
KamuiAuto

# Notification (Later)
