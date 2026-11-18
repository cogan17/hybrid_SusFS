<h1 align="center">hybrid_susfs</h1>

<p align="center">
  SUSFS module for KernelSU &nbsp;·&nbsp; sister of <a href="https://github.com/cogan17/Cogan-Kernel">Cogan Kernel</a>
</p>

<p align="center">
  <a href="README.md"><img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> Bahasa Indonesia</a> &nbsp;·&nbsp; <b><img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> English</b>
</p>

<p align="center">
  <a href="https://github.com/cogan17/hybrid_SusFS/releases"><b>⬇️ Download</b></a>
  &nbsp;·&nbsp;
  <a href="docs/panduan.en.md"><b>📖 Guide</b></a>
  &nbsp;·&nbsp;
  <a href="CHANGELOG.md"><b>📝 Release notes</b></a>
  &nbsp;·&nbsp;
  <a href="https://t.me/coganTWRP"><b>💬 Telegram</b></a>
</p>

> [!WARNING]
> The maintainer/developer is not responsible for bootloops or bricks. Device owners are responsible for their own devices! Back up your data.

## What is hybrid_susfs?

If your phone is rooted (KernelSU) or runs a custom kernel, some apps can detect it and then refuse to run, limit features, or ban your account — banking apps, digital wallets, games, streaming, and so on.

**SUSFS** is a feature inside the kernel that hides those traces from apps: files, folders, *mount* points, and kernel info that apps normally use to guess the phone has been modified. **hybrid_susfs is the module that drives SUSFS** — it tells the kernel what to hide, through an easy WebUI. No typing commands; just flip toggles on and off.

**Why "hybrid"?** There are two popular SUSFS modules, **SideX** (sidex15) and **BRENE**, each with its own strengths but you can't install both — you have to pick one. hybrid_susfs merges all three sources into one module:
- 🔧 **Engine** from **simonpunk** — the SUSFS core, always pulled at its latest version on build.
- 🎨 **UI** from **SideX** — a clean, complete WebUI to configure everything.
- ✨ **Extra features** from **BRENE** — spoof system properties, hide custom-ROM, recovery and Xposed traces, and more.

You get the best of all three in one module, no picking and no conflicts.

**So you don't expect too much:**
- hybrid_susfs works at the **file, mount, and kernel** level. It does **not hide your installed-app list** — that's the job of a separate module like **HMA-OSS**, and the two are usually used together. hybrid_susfs has a *UID filter* as a companion to HMA-OSS, not a replacement.
- **No module guarantees passing every detector.** Root-detection apps keep evolving, so this is a cat-and-mouse that is never "done". hybrid_susfs closes the common file/mount/kernel vectors and is updated continuously — which is why every release stays a *pre-release*.
- It is **not** a tool to fool services that check via the phone's security chip (hardware/TEE-level Play Integrity); that is beyond SUSFS's reach.

Made and tested on [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel) (Xiaomi 14T Pro), but it should work on any other kernel with SUSFS v2.

<p align="center">
  <img src="docs/preview/index.png" width="45%" alt="Main page">
  &nbsp;
  <img src="docs/preview/brene.png" width="45%" alt="hybrid_susfs settings page">
</p>

## Install

You need KernelSU and a kernel with SUSFS v2. Without them, the module refuses to install.

1. Download the ZIP from [Releases](https://github.com/cogan17/hybrid_SusFS/releases).
2. Install it in the KernelSU manager, reboot.
3. Set it up from the module's WebUI. Each feature is explained in the [full guide](docs/panduan.en.md).

Later updates show up right in the manager.

Coming from another SUSFS module? No need to uninstall it first. sidex15's SUSFS, BRENE and susfs_manager are turned off automatically when hybrid_susfs is installed.

Something wrong? Tap **Send Logs** in the WebUI and send the log to the Telegram group.

<details>
<summary><b>What comes from where</b></summary>

| | From |
|---|---|
| `ksu_susfs` engine | [simonpunk](https://gitlab.com/simonpunk/susfs4ksu), recompiled on every build |
| WebUI and base scripts | [sidex15](https://github.com/sidex15/susfs4ksu-module) |
| *hybrid_susfs settings* page | [BRENE](https://github.com/rrr333nnn333/BRENE) |

Features that both sidex15 and BRENE have (uname, cmdline and AVC log spoofing, hide sus mounts, hide custom ROM) only run once, using the sidex15 version. Property spoofing from both is merged into one toggle.

There's also something extra: a UID filter to use alongside HMA-OSS, plus a **Check UID** button to see which app a UID belongs to.

</details>

<details>
<summary><b>Updates</b></summary>

The simonpunk engine always follows the latest version on every build. If simonpunk drops a command the module uses, the build stops until the module is adjusted.

Changes from sidex15 and BRENE don't come in automatically. They get checked first, and only the useful ones are taken.

</details>

<details>
<summary><b>Building it yourself</b></summary>

```
NDK=/path/android-ndk ./build.sh
```

Output goes to `out/`. The version in `module/module.prop`, `update.json` and `CHANGELOG.md` must match, otherwise the build stops.

In the Actions tab: **hybrid_susfs Builder** builds, **Rilis dari run** publishes a build that's been tested, **Cek pembaruan** shows what's new in sidex15, BRENE and simonpunk. **Validate** runs by itself on every PR. The Builder has an optional `engine_commit` field to fall back to a specific simonpunk engine commit (empty = latest).

</details>

<details>
<summary><b>Tested</b></summary>

| Version | Result |
|---|---|
| v0.9 | ⏳ v0.8 audit fixes (abort install on config failure, off-mode status, Check UID) |
| v0.8 | ✅ 18 Nov 2026, tested on the phone. /data/local/tmp inode diagnostic; Duck Native Root → INFO (inode 100) |
| v0.7 | ✅ 17 Nov 2026, tested on the phone. Audit fixes: add_sus_mount v2, literal UID filter, status save, release gate, engine_commit option |
| v0.6 | ✅ 17 Nov 2026, tested on the phone. SELinux overlap fix (Hide Vendor SEPolicy vs Hide LineageOS strings) |
| v0.5 | ✅ 17 Nov 2026, Cogan Kernel on the 14T Pro, SUSFS v2.4.0. Duck Detector: Danger 0, Warning 0 |
| v0.4 (withdrawn) | Replaced by v0.5 (same contents, now signed) |

</details>

---

<p align="center">
  <b>Cogan17</b> &nbsp;·&nbsp; thanks to <b>simonpunk</b>, <b>sidex15</b> and <b>rrr333nnn333</b>
  <br>AGPL-3.0 &nbsp;·&nbsp; <code>ksu_susfs</code> GPL-3.0 (simonpunk)
  <br><a href="docs/keaslian-dan-kredit.en.md">🔏 Full authenticity & credits</a>
</p>

<sub>Sister repos: [Cogan-Kernel](https://github.com/cogan17/Cogan-Kernel) · [CoganSU](https://github.com/cogan17/CoganSU) · [TWRP-14T-PRO](https://github.com/cogan17/TWRP-14T-PRO)</sub>
