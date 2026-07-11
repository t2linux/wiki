# State

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

|Feature|Status|Upstream|Notes|Issues/links|
|-|-|-|-|-|
|Internal Drive / SSD|🟢 Working|🟢 Kernel 5.4||[Filesystem notes](#filesystem-notes)|
|Screen, iGPU|🟢 Working|🟡 Partial|||
|USB|🟢 Working|🟢 Yes|||
|Keyboard|🟢 Working|🔴 No|||
|Trackpad|🟢 Working|🔴 No||[Trackpad tuning](https://wiki.t2linux.org/#trackpad-tuning)|
|Wi-Fi|🟢 Working|🟢 Yes|Requires macOS firmware|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Bluetooth|🟡 Partially working|🟢 Yes| 5 GHz Wi-Fi connection is recommended to prevent Bluetooth interferences.|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Camera|🟢 Working|🔴 No|||
|Thunderbolt|🟢 Working|🟢 Yes|Needs`pcie_ports=native` in kernel parameters||
|Touch Bar|🟢 Working|🟢 Yes|Touchbar works in native mode and can be customized using tiny-dfr or react-drm||
|Suspend|🟢 Working|🟡 Prepared|Generally working but requires hardware-specific adjustments until further notice.|[guide](guides/suspend.md)|
|Audio|🟢 Working|🟡 Prepared| Microphone volume is low, what is factory intended state. Gain needs to be turned up in userland||
|Hybrid Graphics|🟡 Partially working|🟡 Partial|Toggling dGPU power doesn't work.|[Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/)|
|AMD GPUs|🟡 Partially working||Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high \| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding `amdgpu.dpm=0` to the kernel commandline stops these crashes.||
|MacPro7,1|🟡 Partially working||Users have encountered PCIe Address Space issues, with auto remap breaking. A temporary solution may be possible by removing the Infinity Fabric Link (Bridge or Jumper) from the GPU(s).||
|T2 Secure Enclave|🔴 Not working||Used for Touch ID, storing encryption keys on macOS||
|T2 Audio Video Encoder|🔴 Not working||Used for Sidecar on macOS||

## Filesystem notes

- Linux using APFS filesystems: Linux cannot read the internal SSD's macOS APFS partition's Data and System volume (for other APFS volumes, [linux-apfs-rw](https://github.com/linux-apfs/linux-apfs-rw) can be used for reading data, but attempting to write is risky).

- macOS using Linux filesystems: There are FUSE implementations of some Linux Filesystems that can be used on macOS (but again, most only have experimental write support).
