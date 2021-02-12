# Installing Arch Linux on a Mac with the T2 Chip

You will need:

- USB drive with at least 1GB
- A way to plug it into your Mac (USB-C isn't USB-A)
- A wired internet connection (i.e. USB-C to Ethernet dongle), although if your Mac came with macOS Mojave, you can follow the [WiFi guide](https://wiki.t2linux.org/guides/wifi/#on-macos) and put the firmware files and any `pacman` packages you'll need to get WiFi working on the live environment in the partition you make in step 2.2.

1. If you are on a Mac that came with macOS Mojave, do the first step of the [WiFi guide](https://wiki.t2linux.org/guides/wifi/#on-macos) now. Make sure you will have the output of the command for later.
2. Making a partition for Linux.
	1. Open the Bootcamp installer and follow it until it asks for a windows ISO, this will clear space for a Linux partition (by removing APFS snapshots).
	2. In macOS Disk Utility, make a partition, format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from the installer, so you must make space now.
3. Creating bootable media
	1. Download an installer ISO from [here](https://dl.t2linux.org/archlinux/iso/index.html).
	2. Put this image onto a USB stick, follow these instructions on the [Arch Wiki](https://wiki.archlinux.org/index.php/USB_flash_installation_medium#In_macOS).
4. Disabling secure boot
	1. Follow [this article's](https://support.apple.com/en-us/HT208198) instructions.
	2. Once in startup security utility, turn secure boot to no security and enable external boot.
5. Booting the live environment.
	1. Plug the USB in to your computer.
	2. Boot while holding the option key, this will put you in macOS Startup Manager.
	3. Select the orange EFI option with arrow keys and press return/enter on it.
6. Follow the Arch Wiki guide from [here](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_keyboard_layout) up to "Format the partitions".
	1. The note on the Arch Wiki mentions the EFI system partition, there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows/already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).
	2. Mount the EFI partition that you intend to use for your bootloader on `/mnt/boot/efi`.
7. Continue following the Arch Wiki's guide until "Install essential packages".
	1. Install the required packages into your new system with: `pacstrap /mnt base linux-mbp linux-mbp-headers apple-bce-dkms-git dkms linux-firmware grub efibootmgr`.
	2. Continue following the Arch Wiki's guide until you get to installing a bootloader.
8. In your `chroot`, install the DKMS modules for Keyboard, Trackpad, Audio and the Touchbar with [this guide](https://wiki.t2linux.org/guides/dkms/#installing-modules). Follow the [Audio Config Guide](https://wiki.t2linux.org/guides/audio-config/) too.
9. Add Aunali1's repository to `/etc/pacman.conf`, with `echo [mbp]\nServer = http://dl.t2linux.org/archlinux/\$repo/\$arch >> /etc/pacman.conf`.
10. Edit `/etc/default/grub`, you'll need to install a text editor (i.e. `vim` or `nano`) with `pacman -S PACKAGE_NAME` for this step.
	1. On the line with `GRUB_CMDLINE_LINUX=`, add the following items: `efi=noruntime intel_iommu=on pcie_ports=compact`
11. Run `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram --removable`.
12. If your mac came with macOS Mojave, you can follow the rest of the [WiFi guide](https://wiki.t2linux.org/guides/wifi/#on-macos) now or after rebooting into your install.
13. You now will be able to select your Arch install in the macOS Startup Manager by holding option at boot.

If you have issues, feel free to ask on our [Discord Server](https://discord.gg/Jayz5f5).
