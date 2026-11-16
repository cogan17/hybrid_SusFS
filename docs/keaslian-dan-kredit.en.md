# 🔏 Authenticity & Credits

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](keaslian-dan-kredit.md)

hybrid_susfs is built automatically by GitHub Actions in **[cogan17/hybrid_SusFS](https://github.com/cogan17/hybrid_SusFS)**, a sister repo of [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel). For builds after v0.4, the module ZIP is **digitally signed** (artifact attestation) by this repo's Builder workflow, so anyone can prove where it came from.

> What this proves is that **this hybrid_susfs ZIP** was made by Cogan17. The SUSFS engine, the WebUI and the features inside are the work of the contributors in [Credits](#-credits).

---

## How to check authenticity

1. **Proof page:** [github.com/cogan17/hybrid_SusFS/attestations](https://github.com/cogan17/hybrid_SusFS/attestations).
2. **With GitHub CLI:**
   ```
   gh attestation verify hybrid_susfs_vX.Y.zip --repo cogan17/hybrid_SusFS
   ```
   Only the original ZIP passes.
3. **SHA256 in the release notes:** every release lists its ZIP's SHA256 and a link to the build run. Compare it with `sha256sum hybrid_susfs_vX.Y.zip`. This is the only check for **v0.4**, which came out before signing was added.
4. **The run page in [Actions](https://github.com/cogan17/hybrid_SusFS/actions):** every build shows the simonpunk SUSFS version used and the ZIP's SHA256.
5. **On the phone:** the module's action button shows a **Build** line (the repo commit it was built from). The full details are in `/data/adb/modules/hybrid_susfs/MANIFEST.txt`: version, repo commit, SUSFS commit, and the SHA256 of every file in the module. This file is also included in **Send Logs**.

## What is proven, and what is not

| If someone… | Result |
|---|---|
| redistributes the ZIP and claims they made it | ✅ disproved: its fingerprint matches the Cogan17 repo's signature |
| changes the ZIP slightly (e.g. the name in `module.prop`) | ✅ caught: it becomes a different file and fails verification; the SHA256 in `MANIFEST.txt` no longer matches either |
| forks the repo and builds it themselves | ✅ their signature names **their repo**; the dated commit history here shows who came first |
| copies the code | not prevented (AGPL-3.0, open project), but the origin can still be proven |

---

## 🙏 Credits

| Who | Contribution |
|---|---|
| **[Cogan17](https://github.com/cogan17)** | Maintainer: the merge, the *hybrid_susfs settings* page, the UID filter, safe install/uninstall, build, CI and releases |
| **[SUSFS](https://gitlab.com/simonpunk/susfs4ksu)** ([simonpunk](https://gitlab.com/simonpunk)) | Engine: the SUSFS kernel patches and the `ksu_susfs` tool, compiled from source on every build (GPL-3.0) |
| **[susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module)** ([sidex15](https://github.com/sidex15)) | WebUI and base module scripts (AGPL-3.0) |
| susfs4ksu-module contributors and translators | Included in the WebUI (*Credits* page): backslashxx, chisewaguri, 0x11DFE, cvnertnc, rifsxd, mehu3dhokia, and the translators |
| **[BRENE](https://github.com/rrr333nnn333/BRENE)** ([rrr333nnn333](https://github.com/rrr333nnn333)) | Extra features on the *hybrid_susfs settings* page (AGPL-3.0) |
| **[KernelSU](https://github.com/tiann/KernelSU)** ([tiann](https://github.com/tiann)) | The module system and WebUI hybrid_susfs runs on |
| **[HMA-OSS](https://github.com/frknkrc44/HMA-OSS)** ([frknkrc44](https://github.com/frknkrc44)) | Partner of the UID filter; the app list is still managed in HMA-OSS |
| **[Android NDK](https://developer.android.com/ndk)** (Google) | Compiler for `ksu_susfs` |
| **[Cogan Kernel](https://github.com/cogan17/Cogan-Kernel)** | The kernel the module is tested on; workflow style (Builder, Rilis dari run, Validate) and README |

Sister projects: **[Cogan Kernel](https://github.com/cogan17/Cogan-Kernel)** · **[CoganSU](https://github.com/cogan17/CoganSU)** · **[TWRP Xiaomi 14T Pro](https://github.com/cogan17/TWRP-14T-PRO)**.
