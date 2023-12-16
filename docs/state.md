# State

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

|Feature|Status|Upstream|Notes|Issues/links|
|-|-|-|-|-|
|Internal Drive / SSD|🟢 Working|🟢 Kernel 5.4||[Filesystem notes](#filesystem-notes)|
|Screen|🟢 Working|🟢 Yes|||
|USB|🟢 Working|🟢 Yes|||
|Keyboard|🟢 Working|🔴 No||[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Camera|🟢 Working|🟢 Yes|||
|Wi-Fi|🟢 Working|🔴 No|Requires macOS firmware|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Bluetooth|🟢 Working|🔴 No|Requires macOS firmware only for devices with BCM4377 chip. Also, Bluetooth glitches on devices with BCM4377 Chip if connected to a 2.4 Ghz Wi-Fi connection. Thus, in order to use Bluetooth either turn off your Wi-Fi or use a 5Ghz Wi-Fi connection.|[Setup guide](https://wiki.t2linux.org/guides/wifi-bluetooth/)|
|Touch Bar|🟢 Working|🔴 No|There is support for the "Touch Bar Keyboard" device configuration, where only the Function Keys or the Media/Brightness Control Keys can be shown. There is work in progress support for custom graphics on the Touch Bar.|[tiny-dfr](https://github.com/kekrby/tiny-dfr)<br>[apple-ib](https://github.com/t2linux/apple-ib-drv)|
|Suspend|🟡 Partially working|🟢 Yes|A firmware upgrade attached to macOS Sonoma broke suspend. Some users were having difficulty with it even before Sonoma.|[#53](https://github.com/t2linux/T2-Ubuntu-Kernel/issues/53)|
|Trackpad|🟡 Partially working|🔴 No|Functions, but it is far from the experience on macOS (No force touch or palm rejection). Some models have deadzones on the edges of their trackpads where swipes along the trackpad that start in these deadzones will not be registered.|[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Audio|🟡 Partially working|🔴 No|With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and when using the microphone. Microphone volume is low in some Macs.|[apple-bce](https://github.com/t2linux/apple-bce-drv)|
|Hybrid Graphics|🟡 Partially working|🟡 Partial|If the device has a dedicated AMD GPU (15 and 16 inch MacBookPro's) as well as an Intel iGPU, the iGPU can be used, but this breaks resume.|[Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/)|
|AMD GPUs|🟡 Partially working||Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high \| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding `amdgpu.dpm=0` to the kernel commandline stops these crashes.||
|MacPro7,1|🟡 Partially working||Users have encountered PCIE Address Space issues, with auto remap breaking.||
|T2 Secure Enclave|🔴 Not working||Used for Touch ID, storing encryption keys on macOS||
|T2 Audio Video Encoder|🔴 Not working||Used for Sidecar on macOS||

<!-- ||🟡 Partially working|🔴 No||| -->

## Filesystem notes
- Linux using APFS filesystems: Linux cannot read the internal SSD's macOS APFS parition's Data and System volume (for other APFS volumes, [linux-apfs-rw](https://github.com/linux-apfs/linux-apfs-rw) can be used for reading data, but attempting to write is risky).
- macOS using Linux filesystems: There are FUSE implementations of some Linux Filesystems that can be used on macOS (but again, most only have experemental write support).
