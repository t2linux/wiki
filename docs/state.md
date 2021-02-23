# Introduction

While Linux is usable on all T2 models, some features are limited by lack of drivers or similar. This page should give a general overview of what is working and what is not.

## Working

- Interal Drive / SSD: Support for the SSD has been upstreamed to the Linux Kernel
- Screen
- USB
- Keyboard
- Camera

## Partially Working

- Trackpad: While technically working, it is far from the experience on macOS
- Touchbar: There is support for the so called simple mode, the same that you would see on Bootcamp Windows for example. Either kunction keys from 1 to 12 or basic media / brightness control are shown. 
- Audio: With proper configuration audio can work, however it is not stable in some situations and switching speakers and the headphone jack only works manually
- Wifi: Only works on Models that shipped with macOS Mojave installed as that was the last version to ship with a standard format for firmware binaries

    > Note: There has been success in getting newer firmware to work with specific custom kernel patches,
    this is still in development.

- Suspend

## Not working

- Touch ID

## Other

- File Systems: Linux can't mount APFS partitions nor can macOS mount ext4.