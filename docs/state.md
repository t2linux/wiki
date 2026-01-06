# State

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

|Feature|Status|Upstream|Notes|Issues/links|
|-|-|-|-|-|
|Internal Drive / SSD|🟢 Working|🟢 Kernel 5.4||[Filesystem notes](#filesystem-notes)|
|Screen, iGPU|🟢 Working|🟡 Partial|||
|USB|🟢 Working|🟢 Yes|||
|Keyboard|🟢 Working|🔴 No||[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Trackpad|🟢 Working|🔴 No|Works, but isn't as great as on macOS (no force touch or palm rejection).|[apple-bce](https://github.com/t2linux/apple-bce-drv), [Trackpad tuning](https://wiki.t2linux.org/#trackpad-tuning)|
|Wi-Fi|🟢 Working|🟢 Yes|Requires macOS firmware|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Bluetooth|🟡 Partially working|🟢 Yes|Requires macOS firmware only for devices with BCM4377 chip. Also, Bluetooth glitches on devices with BCM4377 Chip if connected to a 2.4 GHz Wi-Fi connection. Thus, in order to use Bluetooth either turn off your Wi-Fi or use a 5 GHz Wi-Fi connection.|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Camera|🟢 Working|🔴 No||[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Thunderbolt|🟢 Working|🟢 Yes|If it doesn't work, try replacing `pcie_ports=compat` with `pcie_ports=native` in the kernel parameters via GRUB.||
|Touch Bar|🟢 Working|🔴 No|"Touch Bar Keyboard" mode works OOTB, where only the Function Keys or the Media/Brightness Control Keys are shown. Support for custom graphics on the Touch Bar is being actively developed. The drivers were upstreamed in kernel 6.15, but we still need apple-bce to make it work.|[apple-bce](https://github.com/t2linux/apple-bce-drv), [tiny-dfr](https://github.com/AsahiLinux/tiny-dfr), [apple-ib](https://github.com/t2linux/apple-ib-drv)|
|Suspend|🟡 Partially working|🟢 Yes|A firmware upgrade attached to macOS Sonoma broke suspend. Some users were having difficulty with it even before Sonoma. The issue has something to do with the apple-bce driver, because suspend works when it's disabled.|[#53](https://github.com/t2linux/T2-Ubuntu-Kernel/issues/53)|
|Audio|🟡 Partially working|🔴 No|With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and when using the microphone. Microphone volume is low in some Macs.|[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Hybrid Graphics|🟡 Partially working|🟡 Partial|Toggling dGPU power doesn't work.|[Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/)|
|AMD GPUs|🟡 Partially working||Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high \| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding `amdgpu.dpm=0` to the kernel commandline stops these crashes.||
|MacPro7,1|🟡 Partially working||Users have encountered PCIe Address Space issues, with auto remap breaking. A temporary solution may be possible by removing the Infinity Fabric Link (Bridge or Jumper) from the GPU(s).||
|T2 Secure Enclave|🔴 Not working||Used for Touch ID, storing encryption keys on macOS||
|T2 Audio Video Encoder|🔴 Not working||Used for Sidecar on macOS||

## Filesystem notes

- Linux using APFS filesystems: Linux cannot read the internal SSD's macOS APFS partition's Data and System volume (for other APFS volumes, [linux-apfs-rw](https://github.com/linux-apfs/linux-apfs-rw) can be used for reading data, but attempting to write is risky).

- macOS using Linux filesystems: There are FUSE implementations of some Linux Filesystems that can be used on macOS (but again, most only have experimental write support).
