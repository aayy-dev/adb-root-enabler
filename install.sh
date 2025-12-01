export ZIPFILE="$ZIPFILE"
export TMPDIR="$TMPDIR"

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

print_modname() {
    echo " "
    echo " - ADB Root Enabler - "
    echo "    by @ravindu644    "
    echo " "
}

# function to detect whether the device is
# arm64 or arm32
detect_arch(){
    arch=$(uname -m 2> /dev/null)

    case "$arch" in
        aarch64) arch=arm64 ;;
        armeabi*) arch=arm32 ;;
        *) echo "- Unsupported architecture: $arch" && exit 1 ;;
    esac

    echo "- Detected architecture: $arch"
}

on_install() {

    # detect the architecture first
    detect_arch

    # install magiskpolicy
    ( mkdir -p "$MODPATH/system/bin" && \
        unzip -oj "$ZIPFILE" "magiskpolicy/${arch}/magiskpolicy" -d "$MODPATH/system/bin" >&2
    ) || { echo "- Failed to install magiskpolicy"; exit 1; }

    # install scripts
    unzip -oj "$ZIPFILE" 'service.sh' -d $MODPATH >&2
    unzip -oj "$ZIPFILE" 'action.sh' -d $MODPATH >&2
    unzip -oj "$ZIPFILE" 'enable_boot_service' -d $MODPATH >&2

    # Clear package cache to avoid conflicts
    rm -rf /data/system/package_cache/*
}

set_permissions() {
    # Set permissions for module files
    set_perm_recursive $MODPATH 0 0 0755 0644

    # Set permissions for module service script
    set_perm "$MODPATH/service.sh" 0 0 0755
    set_perm "$MODPATH/action.sh" 0 0 0755
    set_perm "$MODPATH/enable_boot_service" 0 0 0755
    set_perm "$MODPATH/system/bin/magiskpolicy" 0 0 0755
}
