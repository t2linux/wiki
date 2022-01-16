# Installing Gentoo Linux on a T2 Mac

## Hardware Requirements

* USB-C to USB-A adapter
* USB Ethernet Adapter/USB Wi-Fi Adapter
    * This is not required, but if you're using a normal Gentoo Minimal Installation ISO, then it is required.
    * If you end up not using this, then you are required to use another distro's ISO in order to connect to the internet via Wi-Fi.
* USB Flash Drive

## Install Procedure

1. Partition your SSD

    1. Open the Bootcamp installer and follow along until it requests for you to input a Windows ISO. This should clear space for a Linux partition because of removed APFS snapshots.
    2. Now open up Disk Utility. Make a partition with any format. The amount of space you allocate for this Linux partition will be final, so choose wisely.
2. Download a Gentoo ISO and flash it to your USB Flash Drive via [Balena Etcher](https://www.balena.io/etcher/) (you can also use dd)
3. Ensure that Secure Boot is disabled
    1. Follow the instructions from [this article](https://support.apple.com/en-us/HT208198)
    2. Once in the Startup Security Utility, set secure boot to no security and enable external boot.
4. Boot into the Live USB enviornment
    1. Plug in the USB Flash Drive into your computer
    2. Startup while holding the Option key, this will put you in the macOS Startup Manager
    3. Select the orange EFI Boot option and press enter to boot into it. (If you're using a Ubuntu Live environment, then make sure to select the orange EFI Boot option all the way to the right)
5. Follow the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks)
    1. Instead of making a new EFI partition for Gentoo, you should instead mount `/dev/nvme0n1p1` to `/mnt/gentoo/boot/efi`
    2. Make sure that you have deleted the partition you made ahead of time, or else you'll lose important data
6. Continue through the Handbook until chapter "Configuring the kernel"
    1. In order to have the Linux Kernel support your device the most, you'll have to manually apply patches to the Linux Kernel.
    2. Run these commands in the Terminal:

    ```bash
    emerge sys-kernel/gentoo-sources
    eselect kernel list # there should be only one option that shows up
    eselect kernel set 1
    ls -l /usr/src/linux # to check if the symlink succeded
    ```

    1. Git clone [these patches](https://github.com/Redecorating/mbp-16.1-linux-wifi) to `/linux-patches`
    2. If needed, git checkout to an older tag with the current gentoo-sources kernel version
    3. Run these commands to grab apple-bce and apple-ibridge:

    ```bash
    git clone https://github.com/t2linux/apple-bce-drv /usr/src/apple-bce
    git clone https://github.com/t2linux/apple-ib-drv /usr/src/apple-ibridge
    for i in apple-bce apple-ibridge; do
    mkdir /usr/src/linux/drivers/staging/$i 
    cp -r /usr/src/$i/* /usr/src/linux/drivers/staging/$i/
    ```

    1. Apply all patches from `/linux-patches` to `/usr/src/linux` with this:

    ```bash
    cd /usr/src/linux
    for i in /linux-patches/*.patch; do; echo $i; patch -Np1 < /linux-patches/$i; done
    ```

    1. It's recommended to use the config from the patches repo instead of the default config from `gentoo-sources`. If you do this, please make sure to set any filesystem drivers you want to use (like for ext4) to be built-in instead of being a module
    2. If you're using kernel version 5.15 or older, than you
    3. Build with `make all`. If you want to speed up the build process, add `-j$(nproc)`
7. Before finishing, if you want to connect to the internet later, now is a good time to install `NetworkManager` and optionally `iwd`.
8. Continue through the Handbook until chapter "Configuring the bootloader"
    1. Install grub by using `emerge --ask --verbose sys-boot/grub`
    2. Edit the config file `/etc/default/grub` with your favorite text editor of choice (i.e. vim or nano)
    3. On the line with `GRUB_CMDLINE_LINUX`, append the following parameters: `intel_iommu=on iommu=pt pcie_ports=compat`
    4. Run `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram --removable` to insall Grub.
    5. Run `grub-mkconfig -o /boot/grub/grub.cfg` to make the config files for Grub
    6. Make nvram/efivars automatically remount as readonly, since writing to them causes a kernel panic: `echo efivarfs /sys/firmware/efi/efivars efivarfs ro,remount,nofail 0 0 >> /etc/fstab`. If this for some reason does not work, then add `efi=noruntime` to the kernel paramters in `/etc/default/grub`
9. You're done! You should now be able to boot into Gentoo via the macOS Startup Manager
10. If you confirmed that Gentoo does bootup no problem, then you can boot into macOS and follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi/)
