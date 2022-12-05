# Pre install steps

These steps are common to most distros. Please refer to both this page and this wiki's install page for your distro.

## Make disk space with Bootcamp Assistant

Your macOS Disk partition may have all it's free space used by APFS Time Machine snapshots. This can lead to the macOS partition not being shrinkable, so we remove these snapshots:

Open the Boot Camp Assistant application and follow it until it asks for a Windows ISO. Then quit Boot Camp Assistant. This will have cleared space to allow resizing your macOS partition, so you can make a Linux partition (it removes APFS snapshots).

!!! note "If Windows has already been installed"
    If Windows has already been installed with Boot Camp Assistant, you won't be able to do this step, just skip it for now. If in the next section, you are unable to shrink the APFS partition, you might be able to instead use `tmutil` to manually remove snapshots.

## Partition with Disk Utility

In macOS Disk Utility, [create a partition](https://support.apple.com/guide/disk-utility/dskutl14027/mac). The file system format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from a Linux installer, so you must make space now. **When prompted to, do not create an APFS volume for Linux**, you want a partition.

!!! note "Triple booting with Linux and Windows"
    Refer to [this guide](https://wiki.t2linux.org/guides/windows/) to make sure you will be able to boot both Windows and Linux.

## Create Linux installation USB

### Selecting an ISO

If there is an ISO with T2 support for your distro, you can download it here:

| Linux Distribution | Install ISO with T2 support |
| ------------------ | --------------------------- |
| Arch Linux         | https://github.com/t2linux/archiso-t2/releases/latest |
| EndeavourOS        | https://github.com/t2linux/EndeavourOS-ISO-t2/releases/latest |
| Fedora Linux       | https://github.com/mikeeq/mbp-fedora |
| Gentoo             | Please refer to this [page](https://wiki.t2linux.org/distributions/gentoo/installation/) |
| Manjaro            | https://github.com/NoaHimesaka1873/manjaroiso-t2/releases/latest |
| NixOS              | https://github.com/kekrby/nixos-t2-iso/releases/latest TODO: Instructions for combining iso parts |
| Ubuntu             | https://github.com/AdityaGarg8/T2-Ubuntu/releases/latest |

For other distros, you can download the distro's normal install ISO, but you will have to use an external USB keyboard and mouse for this install process, and you may need a wired internet connection. Additionally, if you later have issues with installing the bootloader (Eg :- GRUB), try booting the ISO with the `efi=noruntime` kernel parameter.

### Copying the ISO to the USB

You can use [Belana Etcher](https://www.balena.io/etcher/) to copy the Linux install image to your USB.

!!! hint "`dd`"
    If you are familiar with the `dd` tool and the command line, you can use that instead. Use `diskutil list` to find the correct disk, then `sudo dd if=path/to/filename.iso of=/dev/rdiskX bs=1m`. Press `control-T` while it is running to make it show its current progress. **Make sure you select the correct disks.**

While the installation image is being written to the USB, you can copy Wi-Fi firmware, but don't follow the steps after that until it has finished writing the image.

## Copy Wi-Fi firmware

Linux's Wi-Fi driver uses the same Wi-Fi firmware files as macOS, so we copy these files from macOS to the EFI partition where Linux can access these files and then install them.

Follow the instructions in this section for on macOS [here](https://wiki.t2linux.org/guides/wifi/#on-macos). The sections of that page to be followed on Linux can be followed later, once you've successfully installed Linux.

## Disable Secure Boot

!!! note
    Wait until you have finished creating your install USB and you have copied Wi-Fi firmware before proceeding to this section.

Apple's Secure Boot implementation does not allow booting anything other than macOS and Windows when Secure Boot is enabled (not even shim signed GRUB).

1. Follow [this article's](https://support.apple.com/HT208198) instructions to boot into macOS Recovery and open Startup Security Utility.
2. Once in Startup Security Utility, set Secure Boot to "No Security" and select "Allow booting from external or removable media". This will allow you to boot from a Linux install ISO.

!!! Note "Keeping your Mac secure while Secure Boot is off"
    If you are worried about the reduced security, in Startup Security Utility you can select "Turn On Firmware Password" to require entering a password to boot anything other than the default OS (Currently that would be macOS). After installing Linux on the internal SSD, you have the option to reselect "Disallow booting from external or removable media" in Startup Security Utility.

## Booting your Linux install USB

1. Ensure the Linux Installation USB you created is plugged into your Mac.
2. Reboot while holding down the option (⌥) key, this will put you in macOS Startup Manager.
3. Select the orange EFI option with arrow keys and press return/enter on it. If there are two, try the one to the very right first.
4. You may be put into a Bootloader Menu, it may select a default option if no keys are pressed, but you can use arrow keys to select a different option if you want. They should be labeled, but if you are unsure, check if there is any additional advice on your distro's installation page on this wiki.

!!! Warning "A software update is required to use this startup disk"
    If you see this message when trying to boot Linux, Apple may be enforcing secure boot. Make sure you have it [turned off](#Disable-Secure-Boot), and if there were two Orange "EFI Boot" entries in Startup Manager, try selecting the other one. This occurs when booting Linux from a partition formatted as APFS or "macOS Extended" (also known as "hfs+") even when Secure Boot is completely disabled.

## Follow distro specific steps

Once you've selected your USB, it should boot your distro's install image. Now follow the installation guide of your specific distribution.

This wiki provides a set of [guides for different distributions](https://wiki.t2linux.org/distributions/overview/). If the distribution you want to use is present there, it's recommended to follow it instead of the official documentation by distribution vendor, as it considers T2 support.
