# Installing Arch Linux on a Mac with the T2 Chip

!!! hint
    If you wish to use archinstall, there is a profile based on this guide which can be found on [https://github.com/Redecorating/archinstall-mbp](https://github.com/Redecorating/archinstall-mbp)

You will need:

- USB drive with at least 1GB
- A way to plug it into your Mac (USB-C isn't USB-A)
- A wired internet connection (i.e. USB-C to Enternet dongle) or wifi. If you need to install via wifi, you may use [this iso](https://github.com/NoaHimesaka1873/archiso-t2/releases), which has everything needed to follow this guide and use wifi in the live environment. (There's some difference in installation process with this iso which will be described later on)
  It's also possible to perform an offline installation, see [this](https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Installing_packages_from_a_CD/DVD_or_USB_stick) (retrieve the packages from an Arch virtual machine or Docker container)

---

1. Making a partition for Linux.

    1. Open the Bootcamp installer and follow it until it asks for a Windows ISO, this will clear space for a Linux partition (by removing APFS snapshots).
    2. In macOS Disk Utility, make a partition, format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from the installer, so you must make space now.

2. Creating bootable media

    1. Download an installer ISO from [here](https://dl.t2linux.org/archlinux/iso/index.html).
    2. Put this image onto a USB stick, follow these instructions on the [Arch Wiki](https://wiki.archlinux.org/index.php/USB_flash_installation_medium#In_macOS).

3. Disabling secure boot

    1. Follow [this article's](https://support.apple.com/en-us/HT208198) instructions.
    2. Once in startup security utility, turn secure boot to no security and enable external boot.

4. Booting the live environment.

    1. Plug the USB in to your computer.
    2. Boot while holding the option key, this will put you in macOS Startup Manager.
    3. Select the orange EFI option with arrow keys and press return/enter on it.

5. Follow the Arch Wiki guide from [here](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_console_keyboard_layout) up to "Format the partitions".

    1. The note on the Arch Wiki mentions the EFI system partition, there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows or already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).
    2. Mount the EFI partition that you intend to use for your bootloader on `/mnt/boot/efi`, and your other partitions on `/mnt`, etc.

6. Continue following the Arch Wiki's guide until "Install essential packages".

    1. Getting the signing key:

        1. Run `curl -o key.asc https://dl.t2linux.org/archlinux/key.asc` to obtain the signing key for t2 linux specific packages.
        2. If you're using wifi-enabled iso, don't run the above command and jump straight to d.

    2. Add the key to pacman using `pacman-key --add key.asc` and `pacman-key --lsign 7F9B8FC29F78B339` to allow the key
    3. Update your pacman repositories with `pacman -Syy`

        !!! note
            If this command errors you are either not using the correct iso (see step 3) or don't have internet (see "You will need" at the top of this document)

    4. Getting the required packages:

        1. Install the required packages into your new system with: `pacstrap /mnt base linux-mbp linux-mbp-headers apple-bce-dkms-git dkms linux-firmware grub efibootmgr` (omit the `grub efibootmgr` packages from this if you intend to use systemd-boot as your bootloader).
        2. If you're using wifi-enabled iso, install the required packages into your new system with: `pacstrap /mnt base linux-t2 linux-t2-headers linux-t2-docs apple-bcm-wifi-firmware dkms linux-firmware iwd grub efibootmgr` (omit the `grub efibootmgr` packages from this if you intend to use systemd-boot as your bootloader).

    5. Continue following the Arch Wiki's guide until you get to installing a bootloader.

7. In your `chroot`, unless you're using aforementioned wifi-enabled iso, install the DKMS modules for Keyboard, Trackpad, Audio and the Touchbar with [this guide](https://wiki.t2linux.org/guides/dkms/#installing-modules). Follow the [Audio Config Guide](https://wiki.t2linux.org/guides/audio-config/) too. If you're using wifi-enabled iso, only follow [Audio Config Guide](https://wiki.t2linux.org/guides/audio-config/) and jump straight to 10 and skip step 12.
8. Add Aunali1's repository to `/etc/pacman.conf`, by adding this:

   ```ini
   [mbp]
   Server = https://dl.t2linux.org/archlinux/$repo/$arch
   ```

9. Install a bootloader, probably Grub, but you can also use systemd-boot. Don't do both.

    1. Installing Grub:

        1. Edit `/etc/default/grub`, you'll need to install a text editor (i.e. `vim` or `nano`) with `pacman -S PACKAGE_NAME` for this step.
        2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pcie_ports=compat`
        3. Run `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram --removable`.
        4. `grub-mkconfig -o /boot/grub/grub.cfg`

    2. Installing systemd-boot:

        1. `bootctl --path=/boot/efi --no-variables install`
        2. You may need to mask the `systemd-boot-system-token` service, as it writes to nvram and can cause panics at boot: `systemctl mask systemd-boot-system-token`.
        3. Install a text editor (i.e. `pacman -S vim` or `pacman -S nano`), and make the following edit for both `/boot/efi/loader/entries/arch.conf` and `/boot/efi/loader/entries/arch-fallback.conf`.
        4. Add `intel_iommu=on iommu=pt pcie_ports=compat` to the `options` line to add those kernel parameters.

10. Make nvram/efivars automatically remount as readonly, as writing to them causes a panic (deleting and reading variables, however, does not): `echo efivarfs /sys/firmware/efi/efivars efivarfs ro,remount,nofail 0 0 >> /etc/fstab`. If this doesn't work, you can instead add the `efi=noruntime` kernel parameter as described when installing your bootloader (but don't use both of these fixes at the same time).
11. You can follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi/) after rebooting into your install, if Wi-Fi isn't working after the install.
12. You now will be able to select your Arch install in the macOS Startup Manager by holding option at boot.
