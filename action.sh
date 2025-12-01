#!/system/bin/sh

MODDIR="$(dirname $(readlink -fq $0))"

# check magiskpolicy exists and is executable
[ -z $MAGISKPOLICY ] && MAGISKPOLICY="${MODDIR}/system/bin/magiskpolicy"

if [ ! -x $MAGISKPOLICY ]; then 
    echo "- Magiskpolicy not found !"
    exit 1
fi

# check if resetprop exists
if ! command -v resetprop > /dev/null 2>&1; then
    echo "- Resetprop not found !"
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
( patch_rules && reset_props ) && \
echo -e "- ADB Root successfully enabled !\n-To undo the changes, reboot the device."
