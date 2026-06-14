# meta-beaglebone-ai64-edgeai-sdk-11-00-fix

Meta layer to fix the Yocto `tisdk-edgeai-image` build for the **BeagleBone AI-64**.

The stock `tisdk-edgeai-image` targets TI EVMs such as the J721E SK. The BeagleBone AI-64 uses the same J721E SoC family but a different BSP (`meta-beagle`, `linux-bb.org` 6.6, BeagleBoard.org U-Boot). This layer adds the board-specific fixes needed for SD boot, remoteproc access, matching TIDL models, and the EdgeAI demo UI.

All customizations live in this layer; upstream TI and BeagleBoard layers stay untouched.

## What does not work

- `**vision_apps`-style EdgeAI** — the OpenVX stack with R5 cores handling data management (as used by some TI ADAS / vision demos) is not working on BBAI64 with this layer
- `**j7-main-r5f1_0-fw` remoteproc load** — fails at boot; non-blocking for the GStreamer demos below, but a sign the full R5 vision pipeline is not up

## What works

With this layer (`MACHINE = "beaglebone-ai64"`, `ARAGO_BRAND = "edgeai"`):

- SD-card boot without holding the BOOT button
- EdgeAI device-tree overlay applied at boot
- `/dev/remoteproc0` available for the EdgeAI/TIDL userspace path
- **GStreamer EdgeAI demo flow** — Linux userspace, `edgeai-gst-apps`, TIDL on the C7x DSP path (similar in spirit to EdgeAI on AM62A)... From my vague understanding, R5 cores are not used.
- EdgeAI gallery visible on screen after boot
- TIDL model network version `0x20250429`

## Build flow

Start with the normal TI Scarthgap-based Yocto build environment as described here:

- [https://github.com/TexasInstruments/ti-docker-images?tab=readme-ov-file#2-start-yocto-scarthgap-based-build](https://github.com/TexasInstruments/ti-docker-images?tab=readme-ov-file#2-start-yocto-scarthgap-based-build)

Inside your TI build container:

```bash
git clone https://git.ti.com/git/arago-project/oe-layersetup.git ~/tisdk
cd ~/tisdk
./oe-layertool-setup.sh -f configs/processor-sdk-analytics/processor-sdk-analytics-11.00.00-config.txt

cd ~/tisdk/build
. conf/setenv

echo 'ARAGO_BRAND = "edgeai"' >> conf/local.conf
echo 'MACHINE = "beaglebone-ai64"' >> conf/local.conf
```

Clone this layer into the Yocto sources directory:

```bash
cd ~/tisdk/sources
git clone https://github.com/kevinacahalan/meta-beaglebone-ai64-edgeai-sdk-11-00-fix.git
```

Add the layer:

```bash
cd ~/tisdk/build
. conf/setenv
bitbake-layers add-layer ../sources/meta-beaglebone-ai64-edgeai-sdk-11-00-fix
```

Build the Edge AI image:

```bash
bitbake -k tisdk-edgeai-image
```

Flash `tisdk-edgeai-image-beaglebone-ai64.rootfs.wic.xz` from `~/tisdk/build/deploy-ti/images/beaglebone-ai64/`.

## What this layer changes


| Area                                                    | Fix                                                           |
| ------------------------------------------------------- | ------------------------------------------------------------- |
| **SD boot** (`recipes-tisdk/tisdk-uenv/`)               | BBAI64 `uEnv.txt` — boots SD rootfs instead of eMMC           |
| **Kernel / DT** (`recipes-kernel/linux/`)               | `k3-j721e-edgeai-apps.dtbo` + `CONFIG_REMOTEPROC_CDEV`        |
| **TIDL models** (`recipes-tisdk/edgeai-components/`)    | Model zoo `11_00_04_00` (stock uses `11_00_00`)               |
| **EdgeAI GUI app** (`recipes-tisdk/edgeai-components/`) | Psplash handoff + framebuffer repaint before `edgeai-gui-app` |


## Notes

- `getty@tty1` stays enabled — gallery is on top after boot, but keyboard input stills reaches the tty login underneath. As you type, you'll see the tty overwrite the EdgeAI gallery. Somehow the J721-sk build has both the EdgeAI gallery, and tty1 enabled with no issue. 
- U-Boot may print `## Error: "boot_rprocs" not defined` — harmless.

## BBAI64 vs J721E SK

The [J721E SK fix layer](https://github.com/kevinacahalan/meta-j721e-sk-edgeai-sdk-11-00-fix) only needed the model-version override. BBAI64 also needs SD boot, device-tree, remoteproc cdev, and GUI launcher fixes.

## Related

- [HANDOFF.md](HANDOFF.md) — development notes and debugging reference

## License

MIT — see [LICENSE](LICENSE).