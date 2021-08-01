# Installing Gentoo on a Mac with the T2 Chip

You will need:

- USB drive with at least 1GB
- A way to plug it into your Mac (USB-C isn't USB-A)
- A wired internet connection (i.e. USB-C to Enternet dongle) or wifi (not all models support it currently), check [the guide](https://wiki.t2linux.org/guides/wifi/) for compatibility and instructions. Its also technically possible to perform an offline installation, see [this](https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Installing_packages_from_a_CD/DVD_or_USB_stick) (retrieve the packages from an Arch virtual machine or Docker container)
- A usb keyboard (temporary)
- About a weekend and some patience.

---

1. Create bootable media

 * get the ubuntu live image to create a system used to chroot [https://github.com/marcosfad/mbp-ubuntu](https://github.com/marcosfad/mbp-ubuntu)
 * dd on usb stick

2. Boot into osx
 * disable secure boot. Follow [this article's](https://support.apple.com/en-us/HT208198) instructions.
 * resize osx disk to something that exposes at least 30gb of free space

3. Boot into ubuntu

 * verify basic stuff is working (touchpad, keyboard, terminal)
 * create partitions. use a external usb to create stage4 first, then enable follow full disk encryption guides and copy over stage4
 * (external usb hint: dd the bootable magic on the stick first, otherwise it will not be seen by the macbook)
 * unpack stage3 (x86_64) on the partition
 * chroot to the partition, setup build, install gentoo-kernel
 * clone [https://github.com/mbx162/gentoo-macbook-pro-16-2](https://github.com/mbx162/gentoo-macbook-pro-16-2)
 * modify to your environment (eg kernel version in 20-build-modules.sh)
 * build kernel, initrd setup grub

4. boot into usb gentoo

 * make sure apple-bce is loaded on boot (do-load apple-bce)
 * verify everything is working
 * create stage4

5. boot into ubuntu

 * install ubuntu (just for the boot partition) or you modify
   /dev/nvme0n1p0 with the appropriate files

6. boot into usb gentoo

 * create linux-lvm (pvm) partition where ubuntu placed its partitions
 * create lvm, cryptsetup luksCreate etc (follow guides)
 * install stage4

7. boot into macbook gentoo

 * cleanup /boot
 * continue setting up your system

8. make gentoo default os

 * press shift in the osx-boot select (small reload icon is displayed under the partition image)
   while you select the partition

enjoy!