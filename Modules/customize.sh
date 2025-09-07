LATESTARTSERVICE=true

ui_print "------------------------------------"
ui_print "           Bastion Battery          "
ui_print "------------------------------------"
ui_print "         By: Kanagawa Yamada        "
ui_print "------------------------------------"
ui_print "    Thanks to: SRLIMIT3D & levv20   "
ui_print "------------------------------------"
ui_print " "
sleep 1.5

ui_print "------------------------------------"
ui_print "            DEVICE INFO             "
ui_print "------------------------------------"
ui_print "DEVICE : $(getprop ro.build.product) "
ui_print "MODEL : $(getprop ro.product.model) "
ui_print "MANUFACTURE : $(getprop ro.product.system.manufacturer) "
ui_print "PROC : $(getprop ro.product.board) "
ui_print "CPU : $(getprop ro.hardware) "
ui_print "ANDROID VER : $(getprop ro.build.version.release) "
ui_print "KERNEL : $(uname -r) "
ui_print "RAM : $(free | grep Mem |  awk '{print $2}') "
ui_print " "
sleep 1.5

ui_print "------------------------------------"
ui_print "            MODULE INFO             "
ui_print "------------------------------------"
ui_print "Name : Bastion Battery"
ui_print "Version : 4.0"
ui_print "Support Root : Magisk / KernelSU / APatch"
ui_print " "
sleep 1.5

# ==================================
# SOC Recognition Functions
# ==================================
soc_recognition_extra() {
	[ -d /sys/class/kgsl/kgsl-3d0/devfreq ] && { SOC=2; return 0; }
	[ -d /sys/devices/platform/kgsl-2d0.0/kgsl ] && { SOC=2; return 0; }
	[ -d /sys/kernel/ged/hal ] && { SOC=1; return 0; }
	[ -d /sys/kernel/tegra_gpu ] && { SOC=6; return 0; }
	return 1
}

get_soc_getprop() {
	local SOC_PROP="
ro.board.platform
ro.soc.model
ro.hardware
ro.chipname
ro.hardware.chipname
ro.vendor.soc.model.external_name
ro.vendor.qti.soc_name
ro.vendor.soc.model.part_name
ro.vendor.soc.model
"
	for prop in $SOC_PROP; do
		getprop "$prop"
	done
}

recognize_soc() {
	case "$1" in
	*mt*|*MT*) SOC=1 ;;
	*sm*|*qcom*|*SM*|*QCOM*|*Qualcomm*) SOC=2 ;;
	*exynos*|*Exynos*|*EXYNOS*|*universal*|*samsung*|*erd*|*s5e*) SOC=3 ;;
	*Unisoc*|*unisoc*|*ums*) SOC=4 ;;
	*gs*|*Tensor*|*tensor*) SOC=5 ;;
	*kirin*) SOC=7 ;;
	esac
	[ $SOC -eq 0 ] && return 1
}

# ==================================
# SOC Detection Logic
# ==================================
ui_print "------------------------------------"
ui_print "        RECOGNIZING CHIPSET         "
ui_print "------------------------------------"
# SOC CODE:
# 1 = MediaTek, 2 = Qualcomm Snapdragon, 3 = Exynos, 4 = Unisoc
# 5 = Google Tensor, 6 = Nvidia Tegra, 7 = Kirin
SOC=0

soc_recognition_extra
[ $SOC -eq 0 ] && recognize_soc "$(get_soc_getprop)"
[ $SOC -eq 0 ] && recognize_soc "$(grep -E "Hardware|Processor" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
[ $SOC -eq 0 ] && recognize_soc "$(grep "model\sname" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')"

# ==================================
# Validate SOC and Abort if Unsupported
# ==================================
case "$SOC" in
  1)
    ui_print "- Detected SoC: MediaTek"
    ui_print "- Device is supported. Continuing installation..."
    ;;
  2)
    ui_print "- Detected SoC: Qualcomm Snapdragon"
    ui_print "- Device is supported. Continuing installation..."
    ;;
  *)
    ui_print "! Unsupported device detected."
    ui_print "! This module is only for MediaTek and Snapdragon devices."
    abort "Aborting installation."
    ;;
esac
ui_print " "
sleep 1.5


ui_print "      INSTALLING        "
ui_print " "
sleep 1.5

#######################################
# Extract Main Kamui Script
#######################################
ui_print "- Extracting main script files..."
unzip -o "$ZIPFILE" 'Kamui/*' -d $MODPATH >&2
set_perm_recursive $MODPATH/Kamui 0 0 0774 0774

#######################################
# Copy Kamui Hehe Emote to temp
#######################################
cp -r "$MODPATH"/KamuiHehe.png /data/local/tmp >/dev/null 2>&1

#######################################
# Install Binaries
#######################################

# --- Setup Paths and Environment ---
ui_print "- Preparing binary installation..."
BIN_PATH=$MODPATH/system/bin
TEMP_EXTRACT_DIR=$TMPDIR/bin_extract
ARCH=$(getprop ro.product.cpu.abi)

# Create necessary directories
mkdir -p $BIN_PATH
mkdir -p $TEMP_EXTRACT_DIR

# --- Install KamuiAuto ---
ui_print "- Processing KamuiAuto..."
TARGET_BIN_NAME=KamuiAuto
TARGET_BIN_PATH=$BIN_PATH/$TARGET_BIN_NAME

if [[ "$ARCH" == *"arm64"* ]]; then
  ui_print "  - Detected 64-bit ARM: $ARCH"
  # The unzip command below extracts the full path, so we adjust the source path check
  SOURCE_ZIP_PATH='Kamui/KamuiAuto/KamuiAuto_arm64'
  SOURCE_EXTRACTED_PATH=$TEMP_EXTRACT_DIR/$SOURCE_ZIP_PATH
else
  ui_print "  - Detected 32-bit ARM: $ARCH"
  SOURCE_ZIP_PATH='Kamui/KamuiAuto/KamuiAuto_arm32'
  SOURCE_EXTRACTED_PATH=$TEMP_EXTRACT_DIR/$SOURCE_ZIP_PATH
fi

unzip -o "$ZIPFILE" "$SOURCE_ZIP_PATH" -d $TEMP_EXTRACT_DIR >&2

if [ -f "$SOURCE_EXTRACTED_PATH" ]; then
  mv "$SOURCE_EXTRACTED_PATH" "$TARGET_BIN_PATH"
  set_perm $TARGET_BIN_PATH 0 0 0755
  ui_print "  - KamuiAuto installed successfully"
else
  ui_print "! ERROR: Failed to extract KamuiAuto from zip path '$SOURCE_ZIP_PATH'"
fi

# Clean up temporary extraction directory
rm -rf $TEMP_EXTRACT_DIR
ui_print "- Installation complete"

sleep 1.5
# Tribute to Kamui Bastion
ui_print " "
case "$((RANDOM % 15 + 1))" in
1) ui_print "A new weapon! No one can stop me now!" ;;
2) ui_print "Woah! I'm the leader now! Don't worry, I'll lead us to victory!" ;;
3) ui_print "That mission had bonus rewards! Hope it's a weapon!" ;;
4) ui_print "Heyo—! Mornin'! Y'all ready for the next battle?!" ;;
5) ui_print "Commandant! When are you going to take me on another mission—?!" ;;
6) ui_print "Let's go, let's go! Time for our next mission!" ;;
7) ui_print "Did you see that? My ultimate move!" ;;
8) ui_print "Can't we just smash our way through?" ;;
9) ui_print "It's pretty late. You trying to see the stars?" ;;
10) ui_print "I feel the power pouring in!" ;;
11) ui_print "My turn!" ;;
12) ui_print "No one understands weaponry better than me!" ;;
13) ui_print "You wanna spar? Let's go!" ;;
14) ui_print "Leave this to me. I'll take care of it!" ;;
15) ui_print "Haah Kimochi Yokatta" ;;
esac