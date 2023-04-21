# Installing Gentoo Linux on a T2 Mac

## Install Procedure

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps.
   1. Since there is not yet a T2 Gentoo Installation ISO, you will need to use a different ISO. We recommend the [T2-Ubuntu](https://github.com/t2linux/T2-Ubuntu/releases/latest) ISO if you want a graphical environment, or the [T2-Archiso](https://github.com/t2linux/archiso-t2/releases/latest) if you don't want to have to copy wifi firmware to the livecd.
   2. If you chose the Ubuntu ISO, follow the [WiFi Guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) once booted.

2. Connect to the internet using NetworkManager in the Ubuntu ISO, or using `iwctl` in the Arch ISO.

3. You will need to reformat your partitions, except for the EFI partition. The other partitions will need to reformatted as described in the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks). For the EFI system partition there will be one at `/dev/nvme0n1p1` and you can use this if you don't intend to install Windows or already have it installed. If you do intend to triple boot, refer to [this guide](https://wiki.t2linux.org/guides/windows/).

4. Follow the Gentoo Handbook from [Installing stage3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage) until [Kernel Configuration and Compilation](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Kernel_configuration_and_compilation).

5. Setup the T2 Gentoo overlay:

   ```bash
   emerge -av app-eselect/eselect-repository dev-vcs/git
   eselect repository add t2 git https://codeberg.org/vimproved/t2-overlay.git
   emerge --sync t2
   ```

6. Install the T2 Gentoo kernel:
   - The T2 overlay provides a [Distribution Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Distribution_kernels) for T2 macs. To install it, run:

   ```bash
   echo "sys-kernel/t2gentoo-kernel" >> /etc/portage/package.accept_keywords/t2gentoo-kernel
   echo "virtual/dist-kernel::t2" >> /etc/portage/package.accept_keywords/t2gentoo-kernel
   emerge -av sys-kernel/t2gentoo-kernel
   ```

7. Install WiFi firmware for T2 macs:

   ```bash
   mkdir -p /etc/portage/package.license
   echo "sys-firmware/apple-bcm-firmware all-rights-reserved" >> /etc/portage/package.license/firmware
   emerge -av sys-firmware/apple-bcm-firmware
   ```

8. Follow the Gentoo Handbook from [Configuring the System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System) up to [Configuring the bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader)

9. Install the bootloader:
    1. Choose a bootloader (other than LILO) from the [Configuring the bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader) section of the Gentoo Handbook.
    2. Add `intel_iommu=on iommu=pt pcie_ports=compat` to the kernel parameters. Refer to the Gentoo Wiki article for your bootloader of choice for instructions on how to do this.

10. Exit the `chroot` (Control-d, or `exit`) and reboot. You should now be able to select Gentoo from the MacOS startup manager by holding option at boot. Congratulations, you should now have a working Gentoo installation.
