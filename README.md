## ADB Root Enabler

This Magisk / KernelSU / Apatch module enables `adb root` on production Android builds.

### How to use
- **Install** the ZIP through Magisk or KernelSU and reboot the device.
- **Tap the action button** to enable ADB root immediately.
- Optionally enable the boot service by editing `/data/adb/modules/adb-root-enabler/enable_boot_service` file and setting `PATCH_ON_BOOT=1`.

### Screenshot
![ADB Root Enabler UI](screenshots/1.png)

#### Credit: [I found this method after reading this xda forum comment](https://xdaforums.com/t/enable-adb-root-from-shell.4298567/post-90167637)
