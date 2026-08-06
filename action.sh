#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/functions.sh"

echo "- Enabling ADB root..."
apply_adb_root
echo "- ADB root enabled !"
echo "- Reboot the device to undo the changes."
