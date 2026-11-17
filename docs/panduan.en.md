# 📖 hybrid_susfs Guide

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](panduan.md)

A full guide: install, configure, back up and restore hybrid_susfs. For credits and how to verify the ZIP, see [Authenticity & Credits](keaslian-dan-kredit.en.md).

---

## Before you start

- **KernelSU root** (arm64) installed and working.
- **A kernel patched with SUSFS v2.** Otherwise the module refuses to install with a "Kernel Not Supported" message.
- Made and tested on [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel) (Xiaomi 14T Pro), but works on any SUSFS v2 kernel.

Keep only one SUSFS module active. hybrid_susfs disables `susfs4ksu` (sidex15), `brene` and `susfs_manager` on install, so you don't need to uninstall them first.

## 1. Install

1. Download `hybrid_susfs_vX.Y.zip` from [Releases](https://github.com/cogan17/hybrid_SusFS/releases).
2. KernelSU manager → **Modules** → **Install from storage** → pick the ZIP.
3. **Reboot.**
4. Open the module's WebUI (button on the module card) to configure it.

Later updates show up as a button in the KernelSU manager (`updateJson`). Install as usual, then reboot.

> ⚠️ Install one module at a time, reboot, check the phone is fine, then install the next. If it bootloops, you know which module did it. Bootloop recovery is [below](#bootloop-recovery).

## 2. WebUI home page

| What you see | Meaning |
|---|---|
| **Kernel Version** + **Kernel Status** | The kernel's SUSFS version and whether the engine is active |
| **SUS PATH / SUS MAPS / SUS MOUNT / TRY UMOUNT** | How many traces are currently hidden (from kernel logs) |
| **Kernel Uname** | Spoof the kernel `uname`. Enter your stock kernel values so apps don't see a custom kernel name |
| **auto try umount (userspace)** | Force-unmount suspicious mounts from userspace |
| **Send Logs** | Collect logs to share when something is wrong (see [Problems](#problems)) |
| **Custom hybrid_susfs settings** | Open the extra-features page (section 3) |

> `uname` spoof: ordinary apps can usually only read `uname`. Enter exactly your phone's stock kernel values. On Cogan Kernel they're in the [kernel install guide](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/pasang.en.md).

## 3. The *hybrid_susfs settings* page

Extra features, grouped. Turn on what you need; hiding more is not automatically safer — it can create an obvious pattern. Test after each change.

**Hide Paths**
- Hide /data/local/tmp items, Hide non-standard Android/ & sdcard folders
- Hide custom recovery folders, Hide root manager app folders
- Hide /system/addon.d, Hide suspicious PTYs
- Hide framework-res.apk maps, Hide Vector (Xposed) injection
- Hide SELinux Modification, Kernel Umount

**App UID Filter** (HMA-OSS companion)
- **Main-user app UID filter (10000–19999)**: limit priority syscalls to main-user apps.
- **Refresh UID filter**: run it again after installing a new app so its UID is included.
- **Check UID**: enter a UID, see which package owns it.
- Extra packages can be listed in `priority_extra_packages.txt`.
- **Which apps are hidden** is still configured in **HMA-OSS**, not here. This filter is only about priority syscalls.

**Spoofing**
- **Spoof system properties** (SideX + Brene merged into one toggle)
- Spoof OS / vendor security patch, Spoof /system/etc/hosts
- Remove custom ROM props, Logcat buffer 64K

## 4. Back up & restore config

- **Export Config**: save all settings to one backup file.
- **Import Config**: restore from a backup file (including backups from an older version). The file is strictly checked; if it's broken, the import rolls back and changes nothing.
- **Reset All Config**: back to defaults.

Config lives in `/data/adb/hybrid_susfs/config.sh`. Don't edit it by hand unless you know it; the WebUI reads config as data with a schema, not as a script.

## 5. Uninstall

KernelSU manager → **Modules** → hybrid_susfs → **Remove** → **Reboot**.

The previous `ksu_susfs` tool is only restored to empty paths, so it never overwrites another SUSFS module you might install afterwards.

---

## Problems

- **Buttons don't work / blank WebUI**: close and reopen the WebUI. If it persists, send logs.
- **Send Logs**: the button on the home page. Logs include the build identity (`MANIFEST.txt`) so they can be matched to the ZIP. **Redact personal data before sharing a log.**
- Send logs to the [Telegram group](https://t.me/coganTWRP).

### Bootloop recovery

hybrid_susfs never touches data and never changes the boot partition, so a module bootloop can be recovered without a wipe:

1. Use the root manager's recovery mode, or the volume-key prompt of a bootloop protector (e.g. AshReXcue) if installed.
2. Or, over ADB/recovery, create a disable marker: `/data/adb/modules/hybrid_susfs/disable`, then reboot. The module won't run that boot.
3. Still bootlooping? Then it's not this module. See [back to stock on Cogan Kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/kembali-ke-stok.en.md) or restore the stock `boot`.
