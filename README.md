# ⚡ Kujang Kernel

[![Telegram](https://img.shields.io/badge/Telegram-Kujang%20Project-2AABEE?logo=telegram&logoColor=white)](https://t.me/kujang_project)
[![Build](https://github.com/Kujang-Kernel/Kujang_Kernel_Sweet/actions/workflows/Kujang_Beta.yml/badge.svg?branch=Kujang_Beta)](https://github.com/Kujang-Kernel/Kujang_Kernel_Sweet/actions/workflows/Kujang_Beta.yml)

Custom kernel for **Redmi Note 10 Pro** (`sweet` / `sweetin`) — Snapdragon 732G (SM7150), Android 11–17.

**Kujang Kernel** is based on **Strixotic-personal**, built on the Linux 4.14 tree. It keeps the clean and minimal philosophy of its base, with Kujang branding, a dedicated build pipeline, and device-specific tweaks.

> **Base:** Strixotic-personal · **Kernel:** `4.14.357-Kujang-Beta` · **Device:** sweet

## Highlights

- Based on **Strixotic-personal** (Linux 4.14.357)
- **Kprofiles** — four switchable profiles through `/sys/kernel/kprofiles/kp_mode`:

  | Mode | Profile |
  | ---- | ------- |
  | 0 | Disabled |
  | 1 | Battery Saver |
  | 2 | Balanced |
  | 3 | Performance |

  Auto profile switching on screen-off can be toggled at runtime via `/sys/module/kprofiles/parameters/auto_kp`.

- **90 Hz DTBO** selector inside the flashable ZIP (volume keys in recovery)
- **KernelSU / NoMount** support — CI builds both `KSU-AOSP` and `Non-KSU` variants
- AnyKernel3 packaging from [Kujang-Kernel/Anykernel3](https://github.com/Kujang-Kernel/Anykernel3) (branch `Kujang-Kernel`)
- Thermally aware charging and DVFS — mitigation tables are kept intentionally for safety

## Build

GitHub Actions workflow: `.github/workflows/Kujang_Beta.yml` (manual `workflow_dispatch`).

- **Toolchain:** Clang 17.0.0 (ZyCromerZ) + GCC from greenforce-project
- **Defconfig:** `arch/arm64/configs/vendor/sweet_defconfig`
- **Output:** `Kujang-Beta_<build_type>-<branch>-<timestamp>.zip`

For local builds, run `./build.sh`.

## Flash

Flash the AnyKernel3 ZIP from recovery. Wipe cache before the first boot after flashing.

## Community

Join the discussion, ask questions, and get build updates:

- Telegram: [@kujang_project](https://t.me/kujang_project)

## Credits

- **Strixotic-personal** — base kernel
- **osm0sis** — AnyKernel3
- **Dakkshesh** — Kprofiles
- **Qualcomm / Xiaomi / LineageOS** — upstream kernel sources
