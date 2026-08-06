#!/system/bin/sh
MODDIR=${0%/*}

# read the boot toggle (PATCH_ON_BOOT)
. "$MODDIR/enable_boot_service"

# only auto-patch on boot when enabled
[ "${PATCH_ON_BOOT:-0}" -eq 1 ] || exit 0

. "$MODDIR/functions.sh"

{
    # wait for boot to complete
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1.5
    done
    sleep 1.5

    # (re)apply for up to 60s in case the props get reset late in boot
    END=$(($(date +%s) + 60))
    while [ "$(date +%s)" -lt "$END" ]; do
        if [ "$(getprop ro.secure)" != "0" ]; then
            apply_adb_root
        fi
        sleep 3
    done
} &
