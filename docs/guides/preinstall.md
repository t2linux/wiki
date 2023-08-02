# Pre install steps

These steps are common to most distros. Please refer to both this page and this wiki's install page for your distro.

## Partition with Disk Utility

In macOS Disk Utility you need to create your Linux partition:

1. Open Disk Utility
2. Choose "Macintosh HD *volumes*"
3. Press in the top-right "Partition"
4. Under the blue pie chart press "+" button
5. When prompted be sure to select **"Add Partition"** and **NOT "Volume"**, you want a partition.
6. **Name:** choose a name for the partition, e.g. Linux
7. **Format:** choose whatever format there is - APFS or another - it doesn't really matter (during the Linux installation you must erase your created partition anyway)
8. **Size:** pick the **desired amount of space** for Linux, because you will **not be able** to change it.
9. If you want separate partitions for `/home`, `/boot` etc., create them as well (if you are a beginner and you don't understand this point, you may just skip it).

!!! note "Triple booting with Linux and Windows"
    Refer to [this guide](https://wiki.t2linux.org/guides/windows/) to make sure you will be able to boot both Windows and Linux.

## Create Linux installation USB

### Selecting an ISO

Listed below are the currently available installer ISOs for download:

| Linux Distribution | Download ISO with T2 support |
| ------------------ | ---------------------------- |
| Arch Linux         | <https://github.com/t2linux/archiso-t2/releases/latest> |
| blendOS            | <https://docs.blendos.co/guides/installation-guide-for-macs-with-t2-chip> |
| EndeavourOS        | <https://github.com/t2linux/EndeavourOS-ISO-t2/releases/latest> |
| Fedora             | <https://github.com/mikeeq/mbp-fedora> |
| Fedora             | <https://github.com/t2linux/fedora-iso/releases/latest> |
| Gentoo             | Please refer to this [page](https://wiki.t2linux.org/distributions/gentoo/installation/) |
| Manjaro            | <https://github.com/NoaHimesaka1873/manjaroiso-t2/releases/latest> |
| NixOS              | <https://github.com/t2linux/nixos-t2-iso> |
| Ubuntu & Kubuntu   | <https://github.com/t2linux/T2-Ubuntu/releases/latest> |

#### Other distributions

If you are a beginner we **highly recommend** to choose one of the distros above.

In case you wish to proceed manually, you can download the official ISO from the distro website, but you will have to use an external USB keyboard and mouse for the install process. Additionally, may be required a wired internet connection with a USB adapter.

Please, refer to this guide: [Basic setup](https://wiki.t2linux.org/guides/postinstall/).

You can also find detailed info for unsupported debian-based distros [here](https://wiki.t2linux.org/distributions/debian/installation/).

### Copying the ISO to the USB

You can download user-friendly applications for copying the ISO to your USB:

- [USBImager](https://gitlab.com/bztsrc/usbimager/)
- [balenaEtcher](https://www.balena.io/etcher/) (does collect analytics data)

Or you can use the macOS terminal:

1. Insert your USB drive.
2. Open macOS Terminal.
3. Run `diskutil list` to list all the drives.
4. Look up for your USB thumb which appears as an **external, physical** drive labelled `/dev/diskX` where `X` is a single number (e.g. /dev/disk**2**).
5. Run `sudo diskutil unmountDisk /dev/diskX` to unmount the disk.
6. Run `sudo dd if=path/to/linux.iso of=/dev/rdiskX bs=1m` to start writing. To fetch the iso path easily you can just drag and drop the .iso into the Terminal.
7. Now you may press `control-T` to make it show how many KBs it has written so far.

While the installation image is being written to the USB, you can skip to [Copy Wi-Fi firmware](#copy-wi-fi-firmware); but don't follow the steps after it, wait until the ISO has been written to disk.

## Copy Wi-Fi firmware

Linux's Wi-Fi driver uses the same Wi-Fi firmware files as macOS, thereby we copy them from macOS to the EFI partition where Linux can access and install them.

[Follow here](https://wiki.t2linux.org/guides/wifi-bluetooth/#on-macos) the instructions for the **first part done in macOS** and come back to this page.

The **second part "On Linux"** must be followed **after** you have completed the Linux installation.

## Disable Secure Boot

Now that you have completed the first part of the Wi-Fi firmware in macOS, you can proceed with the disabling of the secure boot.
Apple's Secure Boot implementation does not allow booting anything other than macOS or Windows when it is enabled (not even shim signed GRUB).
We need to disable it:

1. Turn off your Mac
2. Turn it on and rapidly press and hold `Command-R` until the black screen flashes
3. Your Mac will boot in the macOS Recovery
4. Select your user and enter your password
5. Now, from the menu bar choose Utilities > Startup Security Utility
6. Enter again the password
7. Once in Startup Security Utility:

   - set Secure Boot to **No Security**
   - set Allow Boot  Media to **Allow booting from external or removable media**

Now you are able to boot from a Linux install ISO.

!!! Note "Keeping your Mac secure while Secure Boot is off"
    If you are worried about the reduced security, in Startup Security Utility you can select "Turn On Firmware Password" to require entering a password to boot anything other than the
    default OS. Additionally, after installing Linux on the internal SSD, you will have the option to reselect "Disallow booting from external or removable media" in the Startup Security
    Utility.

## Booting your Linux install USB

1. Ensure the Linux Installation USB you created is plugged into your Mac.
2. Reboot while holding down the option (⌥) key, this will put you in macOS Startup Manager.
3. Select the orange EFI option with arrow keys and press return/enter on it. If there are two, select the one to the very right (the last one).
4. The installation may start right away or you may be put into a Bootloader Menu where it may select a default option e.g. "Try or Install Ubuntu", but you can use arrow keys to select a different option if you want.

!!! Warning "A software update is required to use this startup disk"
If you see this message when trying to boot Linux, Apple may be enforcing Secure Boot.

- Make sure you have [disabled Secure Boot](#disable-secure-boot)
- If there were two orange "EFI Boot" entries in Startup Manager, try selecting the other one.

This may occur when booting Linux from a partition formatted as APFS or "macOS Extended" (also known as "hfs+"), even when Secure Boot is completely disabled.

## Follow distro specific steps

You can now follow the installation guide for your chosen distribution: [Guides for different distributions](https://wiki.t2linux.org/distributions/overview/)

### Before proceeding:

The installers of many distros will provide options like "Automatic Partitioning" when installing Linux:

- **Do not use** "Automatic Partitioning" as it may remove macOS as well.
- You **always** must select the option that allows **"Manual Partitioning"**.

**During manual partitioning make sure that:**

- you mount your EFI `/dev/nvme0n1p1`  at `/boot/efi` (or if you use a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions), at whatever applies to your case)
- you mount your partition for Linux at `/`
- if you created separate partitions for `/home`, `/boot`, etc.. you mount each of them correctly according to their mount points.
