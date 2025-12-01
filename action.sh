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

echo "- ADB Root successfully enabled !"
echo "- To undo the changes, reboot the device."
