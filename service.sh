#!/system/bin/sh

MODDIR="$(dirname $(readlink -fq $0))"
. "$MODDIR/enable_boot_service"

# only run if enable_boot_service is 1
if [ "${PATCH_ON_BOOT:-0}" -ne 1 ]; then
    exit 0
fi

# Wait for boot to complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

# check magiskpolicy exists and is executable
[ -z $MAGISKPOLICY ] && MAGISKPOLICY="${MODDIR}/system/bin/magiskpolicy"

if [ ! -x $MAGISKPOLICY ]; then 
    exit 1
fi

# check if resetprop exists
if ! command -v resetprop > /dev/null 2>&1; then
    exit 1
fi

# patching sepolicy rules to enable adb root
"$MAGISKPOLICY" --live "allow adbd adbd process setcurrent"
"$MAGISKPOLICY" --live "allow adbd su process dyntransition"
"$MAGISKPOLICY" --live "permissive { su }"

# resetting props to enable adb root
resetprop ro.secure 0
resetprop ro.adb.secure 0
resetprop ro.force.debuggable 1
resetprop ro.debuggable 1
resetprop service.adb.root 1
resetprop ctl.restart adbd
