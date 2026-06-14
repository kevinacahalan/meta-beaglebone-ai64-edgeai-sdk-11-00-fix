# BBAI64 EdgeAI — development handoff

**Updated:** 2026-06-14  
**Goal:** Boot `tisdk-edgeai-image` on BeagleBone AI-64 with GStreamer EdgeAI demos working (A72 + C7x).

Build setup: see [README.md](README.md) (`MACHINE = "beaglebone-ai64"`, `ARAGO_BRAND = "edgeai"`). All fixes belong in this layer only — do not patch upstream layers in-tree.

---

## Status

**Working on board**

- SD boot without holding BOOT (`uEnv.txt`, `uenvcmd=run bootcmd_ti_mmc`)
- EdgeAI DT overlay, remoteproc firmware, `/dev/remoteproc0`
- TIDL models at `0x20250429` (`EDGEAI_SDK_VERSION=11_00_04_00`)
- GStreamer EdgeAI gallery visible after boot (display fix in `edgeai-init`)

**Known / acceptable**

- `getty@tty1` still running — gallery on top, but keyboard can hit tty login underneath (same as j721e-sk)
- U-Boot `boot_rprocs` error — harmless
- `j7-main-r5f1_0-fw` remoteproc fails — non-blocking for GStreamer path
- `vision_apps` / full R5 pipeline — not working on BBAI64

---
