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
ui_print "Version : 1.0"
ui_print "Support Root : Magisk / KernelSU / APatch"
ui_print " "
sleep 1.5

ui_print "      INSTALLING        "
ui_print " "
sleep 1.5

unzip -o "$ZIPFILE" 'Kamui/*' -d $MODPATH >&2
set_perm_recursive $MODPATH/Kamui 0 0 0774 0774

# Define paths and target binary name
BIN_PATH=/data/adb/modules/BastionBattery/Kamui
TARGET_BIN_NAME=KamuiAuto
TARGET_BIN_PATH=$BIN_PATH/$TARGET_BIN_NAME
TEMP_EXTRACT_DIR=$TMPDIR/kamui_extract # Use a temporary directory for extraction

# Create necessary directories
mkdir -p $BIN_PATH
mkdir -p $TEMP_EXTRACT_DIR

# Detect architecture
ARCH=$(getprop ro.product.cpu.abi)

# Determine which binary to extract based on architecture
if [[ "$ARCH" == *"arm64"* ]]; then
  # 64-bit architecture
  ui_print "- Detected 64-bit ARM architecture ($ARCH)"
  SOURCE_BIN_ZIP_PATH='Kamui/KamuiAuto_arm64' # Path inside the zip file
  SOURCE_BIN_EXTRACTED_PATH=$TEMP_EXTRACT_DIR/Kamui/KamuiAuto_arm64 # Path after extraction to temp dir
  ui_print "- Extracting $SOURCE_BIN_ZIP_PATH..."
  unzip -o "$ZIPFILE" "$SOURCE_BIN_ZIP_PATH" -d $TEMP_EXTRACT_DIR >&2
else
  # Assume 32-bit architecture (or non-arm64)
  ui_print "- Detected 32-bit ARM architecture or other ($ARCH)"
  SOURCE_BIN_ZIP_PATH='Kamui/KamuiAuto_arm32' # Path inside the zip file
  SOURCE_BIN_EXTRACTED_PATH=$TEMP_EXTRACT_DIR/Kamui/KamuiAuto_arm32 # Path after extraction to temp dir
  ui_print "- Extracting $SOURCE_BIN_ZIP_PATH..."
  unzip -o "$ZIPFILE" "$SOURCE_BIN_ZIP_PATH" -d $TEMP_EXTRACT_DIR >&2
fi

# Check if extraction was successful and the source file exists
if [ -f "$SOURCE_BIN_EXTRACTED_PATH" ]; then
  ui_print "- Moving and renaming binary to $TARGET_BIN_PATH"
  # Move the extracted binary to the final destination and rename it
  mv "$SOURCE_BIN_EXTRACTED_PATH" "$TARGET_BIN_PATH"

  # Check if the final binary exists
  if [ -f "$TARGET_BIN_PATH" ]; then
    ui_print "- Setting permissions for $TARGET_BIN_NAME"
    set_perm $TARGET_BIN_PATH 0 0 0755 0755
  else
    ui_print "! ERROR: Failed to move binary to $TARGET_BIN_PATH"
  fi
else
  ui_print "! ERROR: Failed to extract binary from $SOURCE_BIN_ZIP_PATH"
fi

# Clean up temporary extraction directory
rm -rf $TEMP_EXTRACT_DIR

sleep 1.5
ui_print "Haah... Kimochi Yokata (Kamui)"