# Introduction

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

## Working

- Internal Drive / SSD: Support for the SSD has been upstreamed to the Linux Kernel
- Screen
- USB
- Keyboard
- Camera
- Wifi (For now its working for all the devices we have data about. There are still some devices of whom we don't have data. Refer to the [wifi guide](https://wiki.t2linux.org/guides/wifi/) for more details)

## Partially Working

- Bluetooth: Not working on MBP16,2.
- Trackpad: Though it is technically working, it is far from the experience on macOS. No force touch or palm rejection. Some models have deadzones on the edges of their trackpads.
- Touchbar: There is support for the so called simple mode, the same that you would see on Bootcamp Windows for example. Either function keys from 1 to 12 or basic media / brightness control are shown. Sometimes it is unable to change between function keys and media / brightness keys.
- Audio: With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and when using the microphone. Microphone volume is low in some Macs.
- Suspend is very slow to resume (20-40 seconds), and the Touchbar sometimes does not work after resume.
- Hybrid Graphics: In case the device has a dedicated AMD GPU (15 and 16 inch models) as well as an Intel iGPU, the iGPU can be used, but this breaks resume, see the [Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/) page.
- AMD GPUs: Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding the `amdgpu.dpm=0` to the kernel commandline stops these crashes.

## Not working

- Touch ID, storing encryption keys on the T2
- The T2's onboard Audio Video Encoder (used for Sidecar on macOS)
- Keyboard Backlight on 16,X models
- Automatically changing between speakers and headphones when headphones are plugged and unplugged
- Volume buttons on headphones connected to the 3.5mm jack
- Graphics switching without rebooting (gmux)

## Other

- File Systems: Linux can't mount APFS partitions nor can macOS mount ext4.
