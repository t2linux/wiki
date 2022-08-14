# Introduction

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

## Working

- Internal Drive / SSD: Support for the SSD has been upstreamed to the Linux Kernel
- Screen
- USB
- Keyboard
- Camera
- Wi-Fi (requires macOS firmware)
- Bluetooth (requires macOS firmware only for devices with BCM4377 chip. Also, Bluetooth glitches on devices with BCM4377 Chip if connected to a 2.4 Ghz Wi-Fi connection. Thus, in order to use Bluetooth either turn off your Wi-Fi or use a 5Ghz Wi-Fi connection.)
- Touch Bar: There is support for the "Touch Bar Keyboard" device configuration, where only the Function Keys or the Media/Brightness Control Keys can be shown. No other graphics can be shown on the Touchbar (this is what Windows with Bootcamp drivers uses).

## Partially Working

- Keyboard Backlight: Not working on MacBookAir9,1.
- Trackpad: Functions, but it is far from the experience on macOS (No force touch or palm rejection). Some models have deadzones on the edges of their trackpads where swipes along the trackpad that start in these deadzones will not be registered.
- Audio: With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and when using the microphone. Microphone volume is low in some Macs.
- Suspend (It works if [this guide](https://wiki.t2linux.org/guides/dkms/#fixing-suspend) is followed. Sometimes, its slow to resume (takes 5-15 sec).
- Hybrid Graphics: If the device has a dedicated AMD GPU (15 and 16 inch MacBookPro's) as well as an Intel iGPU, the iGPU can be used, but this breaks resume, see the [Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/) page.
- AMD GPUs: Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high | sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding `amdgpu.dpm=0` to the kernel commandline stops these crashes.
- MacPro7,1: Users have encountered PCIE Address Space issues, with auto remap breaking.

## Not working

- Custom graphics on Touchbar: There is currently no Linux driver for the Touchbar's "Touch Bar Display" device configuration, which is what macOS uses, and gives full control over the display to the Operating System.
- T2 Secure Enclave Processor (Touch ID, storing encryption keys on the T2)
- The T2's onboard Audio Video Encoder (used for Sidecar on macOS)
- Automatically changing between speakers and headphones when headphones are plugged and unplugged
- Graphics switching without rebooting (gmux)

## Other

- Linux using APFS filesystems: Linux cannot read the internal SSD's macOS APFS parition's Data and System volume (for other APFS volumes, [linux-apfs-rw](https://github.com/linux-apfs/linux-apfs-rw) can be used for reading data, but attempting to write is risky.
- macOS using Linux filesystems: There are FUSE implementations of some Linux Filesystems that can be used on macOS (but again, most only have experemental write support).
