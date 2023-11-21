# Installing Arch Linux on a Mac with the T2 Chip

You will need:

- USB drive with at least 1GB
- A way to plug it into your Mac (USB-C isn't USB-A)

---

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps.

2. Boot into the live ISO.

3. Follow the Arch Wiki guide from [here](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_console_keyboard_layout) up to "Format the partitions".

    1. You will need to reformat your partitions, except for the EFI partition. The other partitions will need to reformatted as described in the Arch Wiki Installation guide. For the EFI system partition (mentioned in a note on the Arch Wiki), there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows or already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).
    2. Mount the EFI partition that you intend to use for your bootloader on `/mnt/boot/efi`, and your other partitions on `/mnt`, etc.

4. Continue following the Arch Wiki's guide until "Install essential packages".

5. Install the required packages into your new system.

    -    Using pacstrap (more vanilla Arch experience)

         1. Run `pacstrap -K /mnt base linux-t2 apple-t2-audio-config apple-bcm-firmware linux-firmware iwd grub efibootmgr tiny-dfr t2fand` (omit the `grub efibootmgr` packages from this if you intend to use systemd-boot as your bootloader). You can choose to use Xanmod kernel instead. In this case, replace `linux-t2` with `linux-xanmod-t2`.

         2. Add repository to `/mnt/etc/pacman.conf`, by adding this:

         ```ini
         [arch-mact2]
         Server = https://mirror.funami.tech/arch-mact2/os/x86_64
         SigLevel = Never
         ```

    -    Using t2strap (easier)

         1. Run `t2strap /mnt base linux-firmware iwd grub efibootmgr` (omit the `grub efibootmgr` packages from this if you intend to use systemd-boot as your bootloader). You can choose to use Xanmod kernel instead. In this case, append `-k xanmod` (or `-k xanmod-lts` for Xanmod LTS) to `t2strap` command.

6. Continue following the Arch Wiki's guide until you get to installing a bootloader.

7. Add `apple-bce` to the `MODULES` list in `/etc/mkinitcpio.conf`, and then run `mkinitcpio -P`

8. Enable `t2fand` and `tiny-dfr` by running:

   ```bash
   sudo systemctl enable t2fand
   sudo systemctl enable tiny-dfr
   ```

9. Install a bootloader, GRUB is easier, but you can also use systemd-boot. Don't do both.

    -   Installing Grub:

        1. Edit `/etc/default/grub`, you'll need to install a text editor (i.e. `vim` or `nano`) with `pacman -S PACKAGE_NAME` for this step.
        2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pcie_ports=compat`
        3. Run `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable`.
        4. Run `grub-mkconfig -o /boot/grub/grub.cfg` to generate configuration file.

    -   Installing systemd-boot:

        1. Follow the Arch wiki's [instructions](https://wiki.archlinux.org/title/Systemd-boot#Installation). You will want `--path=/boot/efi` as an argument to `bootctl` if you mounted your EFI partition there. Also make sure you configure it to boot the `linux-t2` kernel.
        2. Install a text editor (i.e. `pacman -S vim` or `pacman -S nano`), and make the following edit for `.conf` files in `/boot/efi/loader/entries/`.
        3. Add `intel_iommu=on iommu=pt pcie_ports=compat` to the `options` line to add those kernel parameters.

10. Exit the `chroot` (Control-d, or `exit`) and reboot. You now will be able to select your Arch install in the macOS Startup Manager by holding option at boot.
