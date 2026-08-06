#!/system/bin/sh
# Shared helpers for adb-root-enabler.
# Sourced by service.sh (on boot) and action.sh (manual trigger) — not run directly.
#
# Hardening strategy (resetprop-rs, https://github.com/Enginex0/resetprop-rs):
# every property write goes through the bundled binary BY FULL PATH with -st
# (stealth). Per resetprop-rs's own docs, a bare `resetprop` silently resolves to
# Magisk/KSU's build, which bumps the global serial + futex wake on every write —
# the exact signals a competing prop module (e.g. IntegrityBox) can watch for. A
# stealth write lands like init wrote it at boot (zeroed serial, no global bump,
# no futex wake): the value is still visible to readers, but it doesn't raise
# those signals. It does NOT stop another writer from overwriting us — the boot
# re-apply loop in service.sh handles that by brute-forcing us back to the front.

MODDIR="${MODDIR:-${0%/*}}"
RESETPROP="${MODDIR}/resetprop"

# stealth set in shared memory (read-only + volatile props)
rp_set() {
    "$RESETPROP" -st "$1" "$2"
}

# stealth set + write-through to /data/property so it survives reboot (persist.* props)
rp_set_persist() {
    "$RESETPROP" -st -p "$1" "$2"
}

apply_adb_root() {
    setenforce 0

    # sealed read-only props — resetprop-rs stealth is what lets these be overridden
    rp_set ro.secure 0
    rp_set ro.adb.secure 0
    rp_set ro.force.debuggable 1
    rp_set ro.debuggable 1

    # volatile runtime props
    rp_set service.adb.root 1
    rp_set service.adb.tcp.port 5555

    # persisted props — -p persists to disk (only persist.* are reloaded at boot)
    rp_set_persist persist.sys.adb.security 0
    rp_set_persist persist.adb.tcp.port 5555

    # framework-side toggles
    settings put global adb_enabled 1
    settings put global development_settings_enabled 1

    # control message: MUST go through property_service to fire, so it uses the
    # system resetprop — NOT resetprop-rs, which is direct-mmap and would no-op it.
    resetprop ctl.restart adbd

    # inject custom SELinux rules for the Settings app
    magiskpolicy --live "allow system_app logd_prop property_service set"
    magiskpolicy --live "allow system_app logd_prop file *"
    magiskpolicy --live "allow system_app logpersistd_logging_prop property_service set"
    magiskpolicy --live "allow system_app logpersistd_logging_prop file *"

    setenforce 1
}
