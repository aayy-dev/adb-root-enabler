export ZIPFILE="$ZIPFILE"
export TMPDIR="$TMPDIR"

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

print_modname() {
    echo " "
    echo "  - ADB Root Enabler -  "
    echo "    by  @U-rTrDD-fyi    "
    echo " "
}

# map `uname -m` to the resetprop-rs release suffix
detect_arch(){
    arch=$(uname -m 2> /dev/null)
    case "$arch" in
        aarch64|arm64)              arch=arm64-v8a ;;
        armv7*|armv8l|arm|armeabi*) arch=armeabi-v7a ;;
        x86_64|amd64)               arch=x86_64 ;;
        i?86|x86)                   arch=x86 ;;
        *) echo "- Unsupported architecture: $arch"
           exit 1 ;;
    esac
    echo "- Detected architecture: $arch"
}

on_install() {
    # detect the architecture first
    detect_arch

    # install the matching resetprop binary as "resetprop"
    ( mkdir -p "$MODPATH" && \
        unzip -oj "$ZIPFILE" "resetprop/resetprop-${arch}" -d "$MODPATH" >&2 && \
        mv "$MODPATH/resetprop-${arch}" "$MODPATH/resetprop"
    ) || { echo "- Failed to install resetprop"; exit 1; }

    # install scripts
    unzip -oj "$ZIPFILE" 'service.sh' -d $MODPATH >&2
    unzip -oj "$ZIPFILE" 'action.sh' -d $MODPATH >&2
    unzip -oj "$ZIPFILE" 'functions.sh' -d $MODPATH >&2
    unzip -oj "$ZIPFILE" 'enable_boot_service' -d $MODPATH >&2

    # Clear package cache to avoid conflicts
    rm -rf /data/system/package_cache/*
}

set_permissions() {
    # Set permissions for module files
    set_perm_recursive $MODPATH 0 0 0755 0644

    # Set permissions for scripts and the resetprop binary
    set_perm "$MODPATH/service.sh"          0 0 0755
    set_perm "$MODPATH/action.sh"           0 0 0755
    set_perm "$MODPATH/functions.sh"        0 0 0755
    set_perm "$MODPATH/enable_boot_service" 0 0 0644
    set_perm "$MODPATH/resetprop"           0 0 0755
}
