#!/system/bin/sh
#
# This script configures LIFE in Kamui.txt using volume keys.
# It uses getevent to capture key presses.

MODULE_DIR="/data/adb/modules/BastionBattery"
CONFIG_FILE="$MODULE_DIR/Kamui.txt"

ui_print() {
  echo "$1"
}

ui_print " "
ui_print "Please use the volume keys to make a selection."
ui_print " "
ui_print "  Volume UP   = Set LIFE=1"
ui_print "  Volume DOWN = Set LIFE=0"
ui_print " "

# Ensure the module directory exists
mkdir -p "$MODULE_DIR"

# Wait for a volume key press using getevent
while true; do
  # Capture a single key press event. We look for 'DOWN' state to avoid double triggers.
  EVENT=$(getevent -lqc 1)

  if echo "$EVENT" | grep -q "KEY_VOLUMEUP.*DOWN"; then
    ui_print "Setting LIFE=1..."
    echo "LIFE=1" > "$CONFIG_FILE"
    ui_print "Done. Kamui.txt has been updated."
    break
  elif echo "$EVENT" | grep -q "KEY_VOLUMEDOWN.*DOWN"; then
    ui_print "Setting LIFE=0..."
    echo "LIFE=0" > "$CONFIG_FILE"
    ui_print "Done. Kamui.txt has been updated."
    break
  fi
done

exit 0

