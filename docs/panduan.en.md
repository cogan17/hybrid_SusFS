# 📖 hybrid_susfs Guide

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](panduan.md)

A full guide: install, and an explanation of **every button and toggle** in the WebUI and what it does. For credits and how to verify the ZIP, see [Authenticity & Credits](keaslian-dan-kredit.en.md).

**Contents**
1. [Before you start](#1-before-you-start)
2. [Install & update](#2-install--update)
3. [Home page](#3-home-page)
4. [Kernel Feature Status](#4-kernel-feature-status-read-only)
5. [Custom hybrid_susfs settings](#5-custom-hybrid_susfs-settings)
6. [Custom lists & advanced hiding](#6-custom-lists--advanced-hiding)
7. [The *hybrid_susfs settings* page](#7-the-hybrid_susfs-settings-page)
8. [Back up, import, reset config](#8-back-up-import-reset-config)
9. [Uninstall](#9-uninstall)
10. [Problems & bootloop](#10-problems--bootloop)

> Rule of thumb: hiding more is **not** automatically safer — it can create an obvious pattern. Turn on what you need, then **test after each change**. Many toggles take effect **after a reboot**.

---

## 1. Before you start

- **KernelSU root** (arm64) installed and working.
- **A kernel patched with SUSFS v2.** Otherwise the module refuses to install ("Kernel Not Supported").
- Made and tested on [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel), but works on any SUSFS v2 kernel.

Keep only one SUSFS module active. hybrid_susfs disables `susfs4ksu` (sidex15), `brene` and `susfs_manager` on install.

## 2. Install & update

1. Download `hybrid_susfs_vX.Y.zip` from [Releases](https://github.com/cogan17/hybrid_SusFS/releases).
2. KernelSU manager → **Modules** → **Install from storage** → pick the ZIP.
3. **Reboot.**
4. Open the module's WebUI to configure it.

Later updates show up as a button in the KernelSU manager (`updateJson`). Install as usual, reboot.

> ⚠️ Install one module at a time, reboot, check the phone is fine, then continue. If it bootloops, you know which module did it.

---

## 3. Home page

| Button / display | Function |
|---|---|
| **Kernel Version** | The SUSFS version in the kernel. Info only. |
| **hybrid_susfs Kernel Status** | Whether the SUSFS engine is active and seen by the module. |
| **SUS PATH / SUS MAPS / SUS MOUNT / TRY UMOUNT** | Counters of how many traces are currently hidden, read from kernel logs. Numbers, not the active rule list. |
| **Send Logs** | Collect module logs + build identity (`MANIFEST.txt`) to share when something is wrong. Redact personal data first. |
| **Export Config** | Save all settings to one backup file. |
| **Reset All Config** | Reset all settings to defaults (asks to confirm). |
| **Custom hybrid_susfs settings** | Open the core SUSFS settings page (section 5). |

---

## 4. Kernel Feature Status (read-only)

The status page shows which features **your kernel supports**. These are indicators, not toggles.

| Feature | Means, when active |
|---|---|
| **SUS Path** | The kernel can hide specific files from apps. |
| **SUS Maps** | The kernel can hide memory-map entries (`/proc/*/maps`). |
| **SUS Mount** | The kernel can hide suspicious mounts from the mount list. |
| **SUS Kstat** | The kernel can fake file stat (time/size/inode) so files look original. |
| **Try Umount** | The kernel can force-unmount from an app's view. |
| **Spoof Uname** | The kernel can spoof `uname`. |
| **Spoof Cmdline/Bootconfig** | The kernel can spoof boot cmdline/bootconfig. |
| **Open Redirect** | The kernel can redirect a path read to a replacement file. |
| **Logging** | The kernel can log SUSFS activity. |
| **Auto Default Mount / Auto Bind Mount / Auto Try Umount Bind** | The kernel handles default/bind mounts automatically. |
| **Hide KSU SUSFS Symbols** | The kernel hides KSU/SUSFS symbols from detection. |
| **Magic Mount** | Magic-mount support (a module-mount method). |
| **OverlayFS Auto Kstat** | OverlayFS stat is faked automatically. |

---

## 5. Custom hybrid_susfs settings

Core SUSFS settings (from SideX). **Changes take effect after reboot** unless noted.

| Toggle / button | Function |
|---|---|
| **hybrid_susfs Log** | Turn on SUSFS logging. Useful for diagnosis; turn off when not needed. |
| **SUS SU** | `su` hiding mode. |
| **SUS SU is on Mode 1** | Info: SUS SU uses Mode 1. |
| **SUS SU on boot** | Apply SUS SU automatically on boot. |
| **auto hide settings** | Open the auto-hide toggle group below. |
| **auto hide default mounts** | Hide default mounts automatically. |
| **auto hide bind mounts** | Hide bind mounts automatically. |
| **auto try umount bind mounts** | Force-unmount bind mounts automatically. |
| **auto try umount (userspace)** | Force-unmount suspicious mounts from userspace. |
| **Skip Legit Mounts** | Leave legitimate mounts alone so the system doesn't break. |
| **Hide sus_mounts for all/non-su processes** | Choose the hiding scope: all processes, or non-su only. |
| **Turn off after boot completed** | Stop some work after boot finishes, to save resources. |
| **try umount system zygote process** | Force-unmount from the system zygote process. |
| **try umount zygote isolation service** | Same, for the zygote isolation service. |

### Kernel Uname

Disguise the kernel identity so apps don't see a custom kernel.

| Toggle / field | Function |
|---|---|
| **Spoof Kernel Version** | Turn on kernel version spoofing (`uname -r`). |
| **Spoofed Kernel Version** | The version string to show. Enter your stock kernel exactly. |
| **Spoof Kernel Build** | Turn on build-string spoofing. |
| **Spoofed Kernel Build** | The build string to show. |
| **Set Stock Kernel Build Date** | Use the stock kernel's build date, not the custom one. |
| **Spoof on boot** | Apply the uname spoof on boot. |
| **Execute on post-fs-data (spoofs better)** | Run the spoof earlier (post-fs-data) for a stronger result. ⚠️ Can bootloop with wrong values; it asks to confirm. |

> Spoof values must match your phone's stock kernel exactly. On Cogan Kernel they're in the [kernel install guide](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/pasang.en.md).

---

## 6. Custom lists & advanced hiding

From the *Custom settings* page. For advanced users; wrong entries can break apps or boot.

| Toggle / button | Function |
|---|---|
| **Hide Custom Rom Path** | Hide custom-ROM file traces from apps. |
| **Hide Level** | How aggressive the custom-ROM hiding is: from excluding a few file types (.apk/.jar/.odex/.vdex/.so, `/vendor/bin/hw/`) up to **hide all paths** (⚠️ risky, can cause problems). |
| **Hide Vendor SEPolicy** | Hide vendor SELinux policy changes. |
| **Hide Compat Matrix** | Hide compatibility-matrix modifications. |
| **Spoof Service List** | Fake the system service list. |
| **Hide GApps** | Hide Google Apps modification traces. |
| **Hide Revanced (YT/YTM)** | Hide ReVanced YouTube/Music traces. |
| **Spoof Cmdline** | Fake the kernel cmdline. |
| **Hide KSU Loop** | Hide the KernelSU loop device. |
| **Force Hide Dex2oat Mount** | Force-hide the dex2oat mount. |
| **AVC Log Spoofing** | Fake AVC/SELinux denials in the log so they don't look suspicious. |
| **Emulate Vold App Data Isolation** | Mimic vold-style app data isolation. |
| **Use sus path loop** | Use a sus path loop for the emulation above. |
| **Custom SUS Path / Loop** | Manual list of paths to hide. |
| **Custom SUS Maps / Mount / TRY Umount / Open Redirect** | Manual list for each hiding type. |
| **Custom SUS_KSTAT** (Add/Edit entry, Path) | Manual list of files whose stat is faked. |
| **Import Configuration** | Restore settings from a backup file (see section 8). |
| **Back Up Current Configuration** | Make a backup before importing, so you can roll back. |

---

## 7. The *hybrid_susfs settings* page

Extra features from Brene. **Changes take effect after reboot.**

### Basics
| Toggle | Function |
|---|---|
| **KernelSU** | Mark the KernelSU root (behavior tuning). |
| **SU Compat** | `su` compatibility mode. |
| **Kernel Umount** | Unmount at the kernel level. |
| **Hide SELinux Modification** | Hide traces of SELinux changes. |

### Hide Paths
| Toggle | Function |
|---|---|
| **Hide /data/local/tmp items** | Hide files in `/data/local/tmp` (often used by root tools). |
| **Fix /data/local/tmp inconsistencies** | Fix that folder's permissions and disguise its inode number; kept in place until reboot. |
| **Hide /data/adb** | Hide the `/data/adb` root folder from apps (off by default). Exempts the manager first; if that fails, hiding is cancelled. Test the manager after enabling. |
| **Hide non-standard Android/ folders** | Hide unusual `Android/` folders on the sdcard. |
| **Hide non-standard sdcard folders** | Hide unusual sdcard folders. |
| **Hide custom recovery folders** | Hide TWRP/custom-recovery traces. |
| **Hide root manager app folders** | Hide the root manager's data folders. |
| **Hide /system/addon.d** | Hide the `addon.d` survival scripts. |
| **Hide suspicious PTYs** | Hide suspicious PTY terminals. |
| **Hide framework-res.apk maps** | Hide modified `framework-res.apk` map entries. |
| **Hide Vector (Xposed) injection** | Hide Vector/Xposed injection traces. |

### App UID Filter (HMA-OSS companion)
| Toggle / button | Function |
|---|---|
| **Third-party app UID filter** | Limit priority syscalls to third-party apps. |
| **Main-user app UID filter (10000–19999)** | Limit to main-user apps. If both toggles are on, the main-user mode is used. |
| **Refresh UID filter** | Run again after installing a new app so its UID is included. |
| **Check UID** | Enter a UID, see its owning package. |

> This filter **only** limits priority syscalls. **Which apps are hidden is still configured in HMA-OSS.** After the toggle is turned off, reboot to clear a filter already applied. Extra packages can be listed in `priority_extra_packages.txt`.

### Spoofing
| Toggle | Function |
|---|---|
| **Spoof system properties** | Fake system properties (SideX + Brene merged into one). |
| **Spoof OS security patch** | Fake the OS security-patch date. |
| **Spoof vendor security patch** | Fake the vendor security-patch date. |
| **Hide OEM unlocking toggle** | Hide the OEM-unlocking status. |
| **Remove custom ROM props** | Drop properties that leak a custom ROM. |
| **Remove Play Integrity Fix props (permanent)** | Drop PIF properties permanently. |
| **Hide LineageOS strings** | Hide LineageOS-specific strings. If **Hide Vendor SEPolicy** (section 6) is also on, the same 3 sepolicy/file_contexts files are handled by SideX only, not twice. |
| **Spoof /system/etc/hosts** | Fake the hosts file. |

### Android
| Toggle | Function |
|---|---|
| **Disable Developer options on boot** | Turn off Developer options every boot. |
| **Disable USB debugging on boot** | Turn off USB debugging every boot. |
| **Disable Wireless debugging on boot** | Turn off wireless debugging every boot. |
| **Disable child process restrictions** | Lift child-process restrictions (for some tools). |
| **Logcat buffer 64K** | Enlarge the logcat buffer to 64K. |
| **Max saturation** | Set maximum screen saturation (display). |
| **Show refresh rate** | Show the refresh rate on screen. |

---

## 8. Back up, import, reset config

- **Export Config**: save all settings to one backup file.
- **Import Configuration**: restore from a backup (including a previous version's). **Overwrites current settings** (it confirms). The file is strictly checked; if broken, the import rolls back and changes nothing. Use **Back Up Current Configuration** before importing, just in case.
- **Reset All Config**: back to defaults.

Config lives in `/data/adb/hybrid_susfs/config.sh`. Don't edit it by hand unless you know it; the WebUI reads config as data with a schema, not as a script.

## 9. Uninstall

KernelSU manager → **Modules** → hybrid_susfs → **Remove** → **Reboot**.

The previous `ksu_susfs` tool is only restored to empty paths, so it never overwrites another SUSFS module.

---

## 10. Problems & bootloop

- **Buttons don't work / blank WebUI**: close and reopen the WebUI. Still broken → send logs.
- **Send Logs**: the home-page button. Logs include `MANIFEST.txt` so they can be matched to the ZIP. **Redact personal data before sharing.** Send to the [Telegram group](https://t.me/coganTWRP).

### Bootloop recovery

hybrid_susfs never touches data and never changes the boot partition, so a module bootloop can be recovered without a wipe:

1. Use a bootloop protector (e.g. AshReXcue) if installed, or the root manager's recovery mode.
2. Or, over ADB/recovery, create a disable marker `/data/adb/modules/hybrid_susfs/disable`, then reboot. The module won't run that boot.
3. Still bootlooping? Then it's not this module. See [back to stock on Cogan Kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/kembali-ke-stok.en.md) or restore the stock `boot`.

> The most common bootloop cause here: **Execute on post-fs-data** with wrong uname spoof values. When in doubt, turn that toggle off first.
