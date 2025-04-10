#!/bin/bash

# Battery Modifications
resetprop -n persist.sys.shutdown.mode hibernate
resetprop -n persist.radio.add_power_save 1
resetprop -n wifi.supplicant_scan_interval 300 
resetprop -n ro.ril.disable.power.collapse 1
resetprop -n ro.config.hw_fast_dormancy 1
resetprop -n ro.semc.enable.fast_dormancy true
resetprop -n ro.config.hw_quickpoweron true
resetprop -n ro.mot.eri.losalert.delay 1000
resetprop -n ro.config.hw_power_saving true
resetprop -n pm.sleep_mode 1
resetprop -n ro.ril.sensor.sleep.control 1
resetprop -n power_supply.wakeup enable

# Additional Battery Optimizations
resetprop -n ro.ril.power.collapse 1
resetprop -n power.saving.enabled 1
resetprop -n battery.saver.low_level 30
resetprop -n power.saving.enable 1
resetprop -n persist.radio.apm_sim_not_pwdn 1
resetprop -n ro.ril.enable.amr.wideband 0
resetprop -n power.saving.low_screen_brightness 1
resetprop -n ro.config.hw_smart_battery 1
resetprop -n ro.config.hw_power_profile low

# Dalvik and Kernel Modifications
resetprop -n persist.android.strictmode 0
resetprop -n ro.kernel.android.checkjni 0
resetprop -n ro.kernel.checkjni 0
resetprop -n ro.config.nocheckin 1
resetprop -n ro.compcache.default 0
resetprop -n dalvik.vm.execution-mode int:jit
resetprop -n dalvik.vm.verify-bytecode true
resetprop -n dalvik.vm.jmiopts forcecopy
resetprop -n debug.kill_allocating_task 0
resetprop -n ro.ext4fs 1
resetprop -n ro.setupwizard.mode DISABLED
resetprop -n dalvik.vm.heaputilization 0.25
resetprop -n dalvik.vm.heaptargetutilization 0.75

# Disable USB Debugging Popup
resetprop -n persist.adb.notify 0

# Allow to free more RAM
resetprop -n persist.sys.purgeable_assets 1
resetprop -n ro.config.low_ram enable

# Smoother video playback
resetprop -n video.accelerate.hw 1
resetprop -n media.stagefright.enable-player true
resetprop -n media.stagefright.enable-meta true
resetprop -n media.stagefright.enable-scan false
resetprop -n media.stagefright.enable-http true

# UI Tweaks
resetprop -n persist.sys.ui.hw 1
resetprop -n view.scroll_friction 10
resetprop -n debug.composition.type gpu
resetprop -n debug.performance.tuning 1

# Miscellaneous
resetprop -n persist.sys.gmaps_hack 1
resetprop -n debug.sf.ddms 0
resetprop -n ro.warmboot.capability 1
resetprop -n logcat.live disable

# CPU Core Control
resetprop -n ro.vendor.qti.core_ctl_min_cpu 4
resetprop -n ro.vendor.qti.core_ctl_max_cpu 4