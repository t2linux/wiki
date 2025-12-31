# Pre install steps

These steps are common to most distros. Please refer to both this page and this wiki's install page for your distro.

## Partition with Disk Utility

In macOS Disk Utility you need to create your Linux partition:

1. Open Disk Utility
2. Choose the volume you want to partition for Linux
3. Press the "Partition" button in the top-right
4. Under the blue pie chart press the "+" button
5. When prompted, be sure to select **"Add Partition"** and **NOT "Volume"** - you want a partition.
6. **Name:** choose a name for the partition, e.g. Linux
7. **Format:** choose whatever format there is - exFAT or another - it doesn't really matter (during the Linux installation you must erase your created partition anyway). However, it's best to avoid APFS because it may confuse you when differentiating between macOS and Linux partitions during Linux installation.
8. **Size:** pick the **desired amount of space** for Linux, because you will **not be able** to change it.
9. If you want separate partitions for `/home`, `/boot`, etc., create them as well. If you are a beginner and don't understand this point, you may skip it.

!!! Note "Triple booting with Linux and Windows"
    Refer to [this guide](https://wiki.t2linux.org/guides/windows/) to make sure you will be able to boot both Windows and Linux.

## Create Linux installation USB

### Selecting an ISO

Listed below are the currently available installer ISOs for download:

| Linux Distribution      | Download ISO with T2 support |
| ----------------------- | ---------------------------- |
| Arch Linux              | <https://github.com/t2linux/archiso-t2/releases/latest> |
| CachyOS                 | <https://cachyos.org> |
| EndeavourOS             | <https://github.com/t2linux/EndeavourOS-ISO-t2/releases/latest> |
| Fedora                  | <https://github.com/t2linux/fedora-iso/releases/latest> |
| Gentoo                  | Please refer to this [page](https://wiki.t2linux.org/distributions/gentoo/installation/) |
| NixOS                   | <https://github.com/t2linux/nixos-t2-iso> |
| Ubuntu & its flavours   | <https://github.com/t2linux/T2-Ubuntu/releases/latest> |
| Linux Mint              | <https://github.com/t2linux/T2-Mint/releases/latest> |

#### Other distributions

If you are a beginner, we **highly recommend** choosing one of the distributions above.

In case you wish to proceed manually, you can download the official ISO from the distro website, but you will have to use an external USB keyboard and mouse for the install process. Additionally, you may require a wired internet connection with a USB adapter. Note that if you later have issues installing the bootloader (e.g., GRUB), try booting the ISO with the `efi=noruntime` kernel parameter.

Please refer to this guide: [Basic setup](https://wiki.t2linux.org/guides/postinstall/).

You can also find detailed info for unsupported debian-based distros [here](https://wiki.t2linux.org/distributions/debian/installation/).

### Copying the ISO to the USB

User-friendly applications for copying the Linux install image to your USB include:

- [USBImager](https://gitlab.com/bztsrc/usbimager/)
- [balenaEtcher](https://www.balena.io/etcher/) (does collect analytics data)

Or you can use `dd` in macOS Terminal:

1. Insert your USB drive.
2. Open macOS Terminal.
3. Run `diskutil list` to list all the drives.
4. Look up for your USB thumb which appears as an **external, physical** drive labelled `/dev/diskX` where `X` is a single number (e.g. /dev/disk**2**).
5. Run `sudo diskutil unmountDisk /dev/diskX` to unmount the disk.
6. Run `sudo dd if=path/to/linux.iso of=/dev/rdiskX bs=1m` to start writing. To fetch the ISO path easily you can just drag and drop the .iso into the Terminal.
7. Now you may press `control-T` to make it show how many KBs it has written so far.

## Disable Secure Boot

Apple's Secure Boot implementation does not allow booting anything other than macOS or Windows when enabled (not even shim-signed GRUB).
We need to disable it:

1. Turn off your Mac
2. Turn it on and press and hold `Command-R` until the black screen flashes
3. Your Mac will boot in the macOS Recovery
4. Select your user and enter your password
5. Now, from the menu bar choose Utilities > Startup Security Utility
6. Enter your password again
7. Once in Startup Security Utility:

   - Set Secure Boot to **No Security**
   - Set Allow Boot Media to **Allow booting from external or removable media**

Now you are able to boot from a Linux install ISO.

!!! Note "Keeping your Mac secure while Secure Boot is off"
    If you are worried about the reduced security, in Startup Security Utility you can select "Turn On Firmware Password" to require a password for booting anything other than the default OS. Additionally, after installing Linux on the internal SSD, you will have the option to reselect "Disallow booting from external or removable media" in Startup Security Utility.

## Booting your Linux install USB

1. Ensure the Linux Installation USB you created is plugged into your Mac.
2. Reboot while holding down the option (⌥) key, this will put you in macOS Startup Manager.
3. Select the orange EFI option with arrow keys and press return/enter on it. If there are two, try the one to the very right first (the last one).
4. The installation may start right away or you may be put into a Bootloader Menu where it may select a default option e.g. "Try or Install Ubuntu", but you can use arrow keys to select a different option. If you are unsure, check if there is any additional advice on your distro's installation page on this wiki.

!!! Warning "A software update is required to use this startup disk"
    If you see this message when trying to boot Linux, Apple may be enforcing Secure Boot. Make sure you have [disabled Secure Boot](#disable-secure-boot). If there were two orange "EFI Boot" entries in Startup Manager, try selecting the other one. This may occur when booting Linux from a partition formatted as APFS or "macOS Extended" (also known as "hfs+"), even when Secure Boot is completely disabled.

## Follow distro specific steps

!!! Warning "Automatic Partitioning"
    The installers of many distros provide options like "Automatic Partitioning" when installing Linux. You must always select the option that allows "Manual Partitioning". **Do not** select "Automatic Partitioning" as it will remove macOS as well. During manual partitioning make sure that you mount `/dev/nvme0n1p1` or your [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-separate-efi-partitions) (whatever applies to your case) at `/boot/efi` and the partition you created for Linux at `/`. If you want separate partitions for `/home`, `/boot`, etc., make sure you have created them before as well and mount them accordingly during manual partitioning.

This wiki provides a set of [guides for different distributions](https://wiki.t2linux.org/distributions/overview/). If the distribution you want to use is present there, it's recommended to follow it instead of the official documentation by distribution vendor, as it considers T2 support.
