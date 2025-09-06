#!/system/bin/sh
#
# This script configures LIFE in Kamui.txt using volume keys.
# It uses getevent to capture key presses.

MODULE_DIR="/data/adb/modules/BastionBattery"
CONFIG_FILE="$MODULE_DIR/Kamui.txt"

ui_print() {
  echo "$1"
}

# Read the current LIFE setting to display its status
if [ -f "$CONFIG_FILE" ]; then
    CURRENT_LIFE=$(grep '^LIFE=' "$CONFIG_FILE" | cut -d'=' -f2)
else
    # Default to 0 (Disabled) if the file doesn't exist yet
    CURRENT_LIFE=0
fi

# Set the status string for the UI based on the current value
if [ "$CURRENT_LIFE" -eq 1 ]; then
    STATUS_STRING="Enabled"
else
    STATUS_STRING="Disabled"
fi

ui_print " "
ui_print "LIFE Mode: Halfing Max CPU Freq for battery"
ui_print "Conservation in exchange of reduced performance"
ui_print " "
ui_print "Please use the volume keys to make a selection."
ui_print " "
ui_print "  Volume UP   = Set Enable LIFE Mode"
ui_print "  Volume DOWN = Set Disable LIFE Mode"
ui_print "  Current: LIFE Mode $STATUS_STRING"
ui_print " "
ui_print "Note: No need to reboot, effective immediately"
ui_print " "

# Ensure the module directory exists
mkdir -p "$MODULE_DIR"

# Wait for a volume key press using getevent
while true; do
  # Capture a single key press event. We look for 'DOWN' state to avoid double triggers.
  EVENT=$(getevent -lqc 1)

  if echo "$EVENT" | grep -q "KEY_VOLUMEUP.*DOWN"; then
    ui_print "LIFE Mode enabled"
    echo "LIFE=1" > "$CONFIG_FILE"
    break
  elif echo "$EVENT" | grep -q "KEY_VOLUMEDOWN.*DOWN"; then
    ui_print "LIFE Mode disabled"
    echo "LIFE=0" > "$CONFIG_FILE"
    break
  fi
done

exit 0