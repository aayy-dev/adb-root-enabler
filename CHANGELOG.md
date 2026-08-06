# Changelog

## v2 (versionCode 2000)
First release of this fork. Changes from upstream v1:
- Replace the bundled `magiskpolicy` binaries with
  [resetprop-rs](https://github.com/Enginex0/resetprop-rs); adds `x86` / `x86_64`
  alongside `arm64-v8a` / `armeabi-v7a`, all auto-detected at install.
- Rewrite property patching to use resetprop-rs **stealth** writes (`-st`), with
  `-p` persist for `persist.*` props; also set TCP-ADB (`5555`) and the Settings
  "USB debugging" globals.
- Enable boot patching by default (`PATCH_ON_BOOT=1`; upstream defaults to off).
- Re-apply for up to 60s after boot to counter late-boot prop overrides.
- Factor the shared apply logic into `functions.sh` (used by both `service.sh`
  and `action.sh`).
- Add `updateJson` for in-app updates and a CI workflow that publishes the ZIP
  to GitHub Releases on `v*` tags.

## v1 (versionCode 1000)
- Upstream [ravindu644/adb-root-enabler](https://github.com/ravindu644/adb-root-enabler).
