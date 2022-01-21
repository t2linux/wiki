# Introduction

While Linux is usable on all T2 models, some features are limited due to the lack of drivers or similar. This page should give a general overview of what is working and what is not.

## Working

- Internal Drive / SSD
- Screen
- USB
- Keyboard
- Camera
- Wifi (It's working on all the devices we have data about. There are still some devices of whom we don't have data on. Refer to the [wifi guide](https://wiki.t2linux.org/guides/wifi/) for more details.)

## Partially Working

- Bluetooth: Not working on models with the BRCM4377 WiFi chip (MacBookPro15,4, MacBookPro16,3, MacBookAir9,1), and models with the BRCM4355 WiFi chip (MacBookAir8,1, MacBookAir8,2).
- Trackpad: Though it is technically working, it is far from the experience on macOS. No force touch or palm rejection. Some models have deadzones on the edges of their trackpads.
- Touchbar: There is support for the so called simple mode, the same that you would see on Bootcamp Windows for example. Either function keys from 1 to 12 or basic media / brightness control are shown. Sometimes it is unable to change between function keys and media / brightness keys.
- Audio: With proper configuration audio can work, however it is not stable in some older kernels and switching between speakers and when using the microphone. Microphone volume is low in some Macs.
- Suspend is very slow to resume (20-40 seconds), and the Touchbar sometimes does not work after resume.
- Hybrid Graphics: In case the device has a dedicated AMD GPU (15 and 16 inch models) as well as an Intel iGPU, the iGPU can be used, but this breaks resume. See the [Hybrid Graphics](https://wiki.t2linux.org/guides/hybrid-graphics/) page for more details.

## Not working

- Touch ID, storing encryption keys on the T2
- The T2's onboard Audio Video Encoder (used for Sidecar on macOS)
- Keyboard Backlight on MacBook Air 9,1
- Automatically changing between speakers and headphones when headphones are plugged in and unplugged
- Volume buttons on headphones connected to the 3.5mm jack
- Graphics switching without rebooting (gmux)

## Other

- File Systems: Linux can't mount APFS partitions.
