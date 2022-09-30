# Installing Arch Linux on a Mac with the T2 Chip

You will need:

- USB drive with at least 2GB
- A way to plug it into your Mac (USB-C isn't USB-A)

---

1. Making a partition for Linux.

    1. Open the Bootcamp installer and follow it until it asks for a Windows ISO, this will clear space for a Linux partition (by removing APFS snapshots).
    2. In macOS Disk Utility, make a partition, format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from the installer, so you must make space now.

2. Creating bootable media

    1. Download an installer ISO from [here](https://github.com/t2linux/archiso-t2/releases/latest).
    2. Put this image onto a USB stick, follow these instructions on the [Arch Wiki](https://wiki.archlinux.org/index.php/USB_flash_installation_medium#In_macOS).

3. Disabling secure boot

    1. Follow [this article's](https://support.apple.com/en-us/HT208198) instructions.
    2. Once in startup security utility, turn secure boot to no security and enable external boot.

4. Booting the live environment.

    1. Plug the USB in to your computer.
    2. Boot while holding the option key, this will put you in macOS Startup Manager.
    3. Select the orange EFI option with arrow keys and press return/enter on it.

5. Follow the Arch Wiki guide from [here](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_console_keyboard_layout) up to "Format the partitions".

    1. You will need to reformat your partitions, except for the EFI partition. The other partitions will need to reformatted as described in the Arch Wiki Installation guide. For the EFI system partition (mentioned in a note on the Arch Wiki), there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows or already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).
    2. Mount the EFI partition that you intend to use for your bootloader on `/mnt/boot/efi`, and your other partitions on `/mnt`, etc.

6. Continue following the Arch Wiki's guide until "Install essential packages".

7. Install the required packages into your new system with: `t2strap /mnt base linux-firmware iwd grub efibootmgr` (omit the `grub efibootmgr` packages from this if you intend to use systemd-boot as your bootloader).

8. Continue following the Arch Wiki's guide until you get to installing a bootloader.

9. Install a bootloader, GRUB is easier, but you can also use systemd-boot. Don't do both.

    -   Installing Grub:

        1. Edit `/etc/default/grub`, you'll need to install a text editor (i.e. `vim` or `nano`) with `pacman -S PACKAGE_NAME` for this step.
        2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pcie_ports=compat`
        3. Run `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable`.
        4. `grub-mkconfig -o /boot/grub/grub.cfg`

    -   Installing systemd-boot:

        1. Follow the Arch wiki's [instructions](https://wiki.archlinux.org/title/Systemd-boot#Installation). You will want `--path=/boot/efi` as an argument to `bootctl` if you mounted your EFI partition there. Also make sure you configure it to boot the `linux-t2` kernel.
        2. Install a text editor (i.e. `pacman -S vim` or `pacman -S nano`), and make the following edit for `.conf` files in `/boot/efi/loader/entries/`.
        3. Add `intel_iommu=on iommu=pt pcie_ports=compat` to the `options` line to add those kernel parameters.

10. Exit the `chroot` and reboot. You now will be able to select your Arch install in the macOS Startup Manager by holding option at boot.
