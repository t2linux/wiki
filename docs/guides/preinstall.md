# Pre install steps

While the following steps are common to most distributions, it is recommended to check the [install page for your distro](https://wiki.t2linux.org/distributions/overview/) before following this guide.

## 1. Partition with Disk Utility

In macOS Disk Utility, [create a partition](https://support.apple.com/guide/disk-utility/dskutl14027/mac). The file system format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from a Linux installer, so you must make space now. **When prompted to, do not create an APFS volume for Linux**, you want a partition. If you want separate partitions for `/home`, `/boot` etc., create them as well.

!!! note "Triple booting with Linux and Windows"
    Refer to [this guide](https://wiki.t2linux.org/guides/windows/) to make sure you will be able to boot both Windows and Linux.

## 2. Create Linux installation USB

### Selecting an ISO

If there is an ISO with T2 support for your distro, you can download it here:

| Linux Distribution | Install ISO with T2 support |
| ------------------ | --------------------------- |
| Arch Linux         | <https://github.com/t2linux/archiso-t2/releases/latest> |
| blendOS            | <https://blendos.co/#t2linux> |
| EndeavourOS        | <https://github.com/t2linux/EndeavourOS-ISO-t2/releases/latest> |
| Fedora       | <https://github.com/mikeeq/mbp-fedora> |
| Fedora       | <https://github.com/t2linux/t2linux-fedora-iso/releases/latest> |
| Gentoo             | Please refer to this [page](https://wiki.t2linux.org/distributions/gentoo/installation/) |
| Manjaro            | <https://github.com/NoaHimesaka1873/manjaroiso-t2/releases/latest> |
| NixOS              | <https://github.com/t2linux/nixos-t2-iso> |
| Ubuntu             | <https://github.com/t2linux/T2-Ubuntu/releases/latest> |

For other distros, you can download the distro's normal install ISO, but you will have to use an external USB keyboard and mouse for this install process, and you may need a wired internet connection. Additionally, if you later have issues with installing the bootloader (Eg :- GRUB), try booting the ISO with the `efi=noruntime` kernel parameter.

### Copying the ISO to the USB

User friendly applications for copying the Linux install image to your USB include:

- [USBImager](https://gitlab.com/bztsrc/usbimager/)
- [balenaEtcher](https://www.balena.io/etcher/) (does collect analytics data).

!!! hint "`dd`"
    If you are familiar with the `dd` tool and the command line, you can use that instead. Use `diskutil list` to find the correct disk, then `sudo dd if=path/to/filename.iso of=/dev/rdiskX bs=1m`. Press `control-T` while it is running to make it show its current progress. **Make sure you select the correct disks.**

While the installation image is being written to the USB, you can [copy Wi-Fi firmware](#copy-wi-fi-firmware), but don't follow the steps after that until it has finished writing the image.

## 3. Copy Wi-Fi firmware

Linux's Wi-Fi driver uses the same Wi-Fi firmware files as macOS, so we copy these files from macOS to the EFI partition where Linux can access these files and then install them.

Follow the instructions in this section to be followed on macOS [here](https://wiki.t2linux.org/guides/wifi-bluetooth/#on-macos). The sections of that page to be followed on Linux can be followed later, once you've successfully installed Linux.

## 4. Disable Secure Boot

!!! note
    Wait until you have finished creating your install USB and you have copied Wi-Fi firmware before proceeding to this section.

Apple's Secure Boot implementation does not allow booting anything other than macOS and Windows when Secure Boot is enabled (not even shim signed GRUB).

1. Follow [this article's](https://support.apple.com/HT208198) instructions to boot into macOS Recovery and open Startup Security Utility.
2. Once in Startup Security Utility, set Secure Boot to "No Security" and select "Allow booting from external or removable media". This will allow you to boot from a Linux install ISO.

!!! Note "Keeping your Mac secure while Secure Boot is off"
    If you are worried about the reduced security, in Startup Security Utility you can select "Turn On Firmware Password" to require entering a password to boot anything other than the default OS (Currently that would be macOS). After installing Linux on the internal SSD, you have the option to reselect "Disallow booting from external or removable media" in Startup Security Utility.

## 5. Booting your Linux install USB

1. Ensure the Linux Installation USB you created is plugged into your Mac.
2. Reboot while holding down the option (⌥) key, this will put you in macOS Startup Manager.
3. Select the orange EFI option with arrow keys and press return/enter on it. If there are two, try the one to the very right first.
4. You may be put into a Bootloader Menu, it may select a default option if no keys are pressed, but you can use arrow keys to select a different option if you want. They should be labeled, but if you are unsure, check if there is any additional advice on your distro's installation page on this wiki.

!!! Warning "A software update is required to use this startup disk"
    If you see this message when trying to boot Linux, Apple may be enforcing secure boot. Make sure you have it [turned off](#disable-secure-boot), and if there were two Orange "EFI Boot" entries in Startup Manager, try selecting the other one. This occurs when booting Linux from a partition formatted as APFS or "macOS Extended" (also known as "hfs+") even when Secure Boot is completely disabled.

## 6. Follow distro specific steps

Once you've selected your USB, it should boot your distro's install image. Now follow the installation guide of your specific distribution.

!!! Warning "Automatic Partitioning"
    The installers of many distros provide options like "Automatic Partitioning" when installing Linux. You always have to select the option that allows "Manual Partitioning". **Do not** select "Automatic Partitioning" as it shall remove macOS as well. During manual partitioning make sure that you mount `/dev/nvme0n1p1` or your [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions) (whatever applies to your case) at `/boot/efi` and the partition you created for Linux at `/`. If you want separate partitions for `/home`, `/boot` etc., make sure you have created them before as well and mount them accordingly during manual partitioning.

This wiki provides a set of [guides for different distributions](https://wiki.t2linux.org/distributions/overview/). If the distribution you want to use is present there, it's recommended to follow it instead of the official documentation by distribution vendor, as it considers T2 support.
