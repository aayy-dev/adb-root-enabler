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

on_install() {

    # install the boot script
    unzip -oj "$ZIPFILE" 'service.sh' -d $MODPATH >&2

    # Clear package cache to avoid conflicts
    rm -rf /data/system/package_cache/*
}

set_permissions() {
    # Set permissions for module files
    set_perm_recursive $MODPATH 0 0 0755 0644

    # Set permissions for module service script
    set_perm "$MODPATH/service.sh" 0 0 0755
}
