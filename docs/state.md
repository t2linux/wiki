# Introduction

While Linux is usable on all T2 models, some features are limited by lack of drivers or similar. This page should give a general overview of what is working and what is not.

## Working

- Interal Drive / SSD: Support for the SSD has been upstreamed to the Linux Kernel
- Screen
- USB
- Keyboard
- Camera
- Wifi

## Partially Working

- Trackpad: Though it is technically working, it is far from the experience on macOS.
- Touchbar: There is support for the so called simple mode, the same that you would see on Bootcamp Windows for example. Either function keys from 1 to 12 or basic media / brightness control are shown.
- Audio: With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and the headphone jack only works manually.
- Suspend
- Hybrid Graphics: In case the device has a dedicated AMD GPU (15 and 16 inch models) as well as an Intel iGPU, the iGPU can be used, but this breaks resume, and may be unstable when running games, see the [Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/) page.

## Not working

- Touch ID

## Other

- File Systems: Linux can't mount APFS partitions nor can macOS mount ext4.
