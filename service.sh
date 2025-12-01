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

# selinux rules to enable adb root
RULES=(
    "allow adbd adbd process setcurrent"
    "allow adbd su process dyntransition"
    "permissive { su }"
)

# props needed to be resetted to enable adb root
PROPS=(
    "ro.secure 0"
    "ro.adb.secure 0"
    "ro.force.debuggable 1"
    "ro.debuggable 1"
    "service.adb.root 1"
    "ctl.restart adbd"
)

# patching sepolicy rules
patch_rules(){
    for rule in "${RULES[@]}"; do
        "$MAGISKPOLICY" --live $rule
    done
}

# resetting props
reset_props(){
    for prop in "${PROPS[@]}"; do
        resetprop $prop
    done
}

# main execution
( patch_rules && reset_props )
