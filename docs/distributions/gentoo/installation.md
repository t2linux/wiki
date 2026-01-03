# Installing Gentoo Linux on a T2 Mac

## Install Procedure

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps.
    1. Since there is not yet a T2 Gentoo installation ISO, you will need to use a different ISO. We recommend the [T2-Ubuntu](https://github.com/t2linux/T2-Ubuntu/releases/latest) ISO if you want a graphical environment, or the [T2-Archiso](https://github.com/t2linux/archiso-t2/releases/latest) if you don't want to have to copy Wi-Fi firmware to the livecd.
    2. If you chose the Ubuntu ISO, follow the [Wi-Fi Guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) once booted.

2. Connect to the internet using NetworkManager in the Ubuntu ISO, or using `iwctl` in the Arch ISO.

3. You will need to reformat your partitions, except for the EFI partition. The other partitions will need to be reformatted as described in the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks). For the EFI system partition there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows or already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).

4. Follow the Gentoo Handbook from [Installing stage3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage) until [Kernel Configuration and Compilation](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Kernel_configuration_and_compilation).

5. Setup the T2 Gentoo overlay:

    1. Install `dev-vcs/git` and `app-eselect/eselect-repository`, then enable and sync the overlay:

        ```bash
        emerge -av app-eselect/eselect-repository dev-vcs/git
        eselect repository add t2 git https://codeberg.org/vimproved/t2-overlay.git
        emerge --sync t2
        echo "*/*::t2" >> /etc/portage/package.accept_keywords/t2
        ```

6. Install the T2 Gentoo kernel:

    1. The T2 overlay provides a [Distribution Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Distribution_kernels) for T2 Macs. To install it, run `emerge -av sys-kernel/t2gentoo-kernel`.

    2. Alternatively, you can use the kernel sources and manually compile. With this method, the update process is not automated, and manual configuration is necessary. However, `sys-kernel/t2gentoo-sources` tends to get new kernel versions faster than `sys-kernel/t2gentoo-kernel`. To install it, run: `emerge -av sys-kernel/t2gentoo-sources`. After installing the kernel sources, run `eselect kernel set 1` to point `/usr/src/linux` to the correct path, then follow the directions in the [Manual Configuration](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Alternative:_Manual_configuration) section of the handbook. If you decide to manually configure your kernel, make sure the following options are set:

        ```bash
        CONFIG_APPLE_BCE=m
        CONFIG_APPLE_GMUX=m
        CONFIG_IRQ_REMAP=y
        CONFIG_HID_APPLE_IBRIDGE=m
        CONFIG_HID_APPLE=m
        CONFIG_HID_APPLE_MAGIC_BACKLIGHT=m
        CONFIG_HID_APPLE_TOUCHBAR=m
        CONFIG_HID_SENSOR_ALS=m
        CONFIG_SND_PCM=m
        # For WiFi
        CONFIG_BRCMFMAC=m
        # For Bluetooth
        CONFIG_BT_BCM=m
        CONFIG_BT_HCIBCM4377=m
        CONFIG_BT_HCIUART_BCM=y
        CONFIG_BT_HCIUART=m
        ```

7. Install Wi-Fi firmware for T2 Macs:

    1. The T2 overlay provides a package for T2 Wi-Fi firmware. To install it, run:

        ```bash
        mkdir -p /etc/portage/package.license
        echo "sys-firmware/apple-bcm-firmware all-rights-reserved" >> /etc/portage/package.license/firmware
        emerge -av sys-firmware/apple-bcm-firmware
        ```

8. Follow the Gentoo Handbook from [Configuring the System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System) up to [Configuring the bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader)

9. Install the bootloader:
    1. Choose a bootloader (other than LILO) from the [Configuring the bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader) section of the Gentoo Handbook.
    2. Add `intel_iommu=on iommu=pt pcie_ports=compat` to the kernel parameters. Refer to the Gentoo Wiki article for your bootloader of choice for instructions on how to do this.

10. Exit the `chroot` (Control-d, or `exit`) and reboot. You should now be able to select Gentoo from the macOS startup manager by holding option at boot. Congratulations, you should now have a working Gentoo installation! For your next steps, read through the rest of the Gentoo Handbook and consider installing a desktop environment such as [GNOME](https://wiki.gentoo.org/wiki/GNOME), [KDE](https://wiki.gentoo.org/wiki/KDE), or [Xfce](https://wiki.gentoo.org/wiki/Xfce).
