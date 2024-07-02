# Introduction

This page explains how to perform a basic set up after installing Linux on a T2 Mac.

## Do you need to do this?

This guide is mainly relevent in the following cases :

1. If you have installed Linux using an official ISO, instead of a T2 ISO.
2. The [Make modules load on early boot](#make-modules-load-on-early-boot) section is relevant for those who wish to encrypt their disk drives using LUKS or some other similar software.
3. If some functionality related to T2 Macs is broken, then you can consider following this guide.

In rest cases, you probably won't need to follow this guide.

## Installing a kernel for T2 support

Installing a kernel with support for T2 Macs is required in order to get the Keyboard, Trackpad, Touch Bar, Audio, Fan and Wi-Fi working.

Many distro maintainers provide compiled kernels which can be installed on your Linux installation. Following are the links to the repos providing such kernels:

| Linux Distribution                  | Kernel with T2 support |
| ----------------------------------- | ---------------------- |
| Arch based distros                  | <https://github.com/NoaHimesaka1873/linux-t2-arch> |
| Arch based distros (Xanmod kernels) | <https://github.com/NoaHimesaka1873/linux-xanmod-edge-t2> |
| Fedora                              | <https://github.com/mikeeq/mbp-fedora-kernel> |
| Fedora                              | <https://github.com/t2linux/fedora-kernel> |
| Gentoo                              | <https://github.com/t2linux/T2-Gentoo-Kernel> |
| Manjaro                             | <https://github.com/NoaHimesaka1873/manjaro-kernel-t2> |
| NixOS                               | <https://github.com/NixOS/nixos-hardware> |
| Ubuntu based distros                | <https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel> |
| Debian based distros                | <https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel> |
| Debian based distros                | <https://github.com/andersfugmann/T2-Debian-Kernel> |

If compiled kernels for your distro are not available, then you shall have to compile a kernel on your own. You can follow the [Kernel](https://wiki.t2linux.org/guides/kernel/) guide for help.

## Add necessary kernel paramaters

Using your bootloader, add the `intel_iommu=on iommu=pt pcie_ports=compat` kernel parameters. For example in GRUB:

  1. Edit `/etc/default/grub`.
  2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pcie_ports=compat`.
  3. Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` if you are on a non-debian based distro. If using Debian or Ubuntu based distro, run `sudo update-grub`.

## Make modules load on boot

Simply run the following:

```sh
echo apple-bce | sudo tee /etc/modules-load.d/t2.conf
```

## Make modules load on early boot

Having the `apple-bce` module loaded early allows the use of the keyboard for decrypting encrypted volumes (LUKS).
It also is useful when boot doesn't work, and the keyboard is required for debugging.
To do this, one must ensure the `apple-bce` module *as well as its dependent modules* are included in the initial ram disk.
You can get the list of dependent modules by running `modinfo -F depends apple-bce`
The steps to be followed vary depending upon the initramfs module loading mechanism used by your distro. Some examples are given as follows:

- On systems with `initramfs-tools` (all debian-based distros):

    1. Run `sudo su` to open a shell as root.

    2. Run the following over there:

         ```sh
         cat <<EOF >> /etc/initramfs-tools/modules
         # Required modules for getting the built-in apple keyboard to work:
         snd
         snd_pcm
         apple-bce
         EOF
         update-initramfs -u
         ```

- On systems with mkinitcpio (Commonly used on Arch):

    1. Edit the `/etc/mkinitcpio.conf` file.

    2. Ensure that the file has the following:

         ```sh
         MODULES="apple-bce"
         ```

    3. Run `sudo mkinitcpio -P`.

- On systems with `dracut` (Commonly used on EndeavourOS and Fedora):

    1. Run the following to create a dracut configuration file which loads the apple-bce module on early boot:

        ```sh
        echo "force_drivers+=\" apple-bce \"" | sudo tee /etc/dracut.conf.d/t2linux-modules.conf
        ```

    2. Run `sudo dracut --force` to regenerate the initramfs with this change.

- On systems with other initramfs/initrd generation systems:

    In this case, refer to the documentation of the same and ensure the kernel module `apple-bce` is loaded early.

## Setting up the Touch Bar

Setting up the Touch Bar is different for Ubuntu and Debian based distros.

If you are using an Ubuntu or Debian based distro:

  1. Add the apt repo for T2 Macs from [here](https://github.com/AdityaGarg8/t2-ubuntu-repo#apt-repository-for-t2-macs).
  2. Install `tiny-dfr` by running `sudo apt install tiny-dfr`.
  3. Restart your Mac.
  4. After restarting, you can run `sudo touchbar` to get a list of options that you can configure. Simply follow the on-screen instructions. Note that this command is only for Ubuntu or Debian based distros.

If you are using Arch Linux or EndeavourOS:

  1. Install `tiny-dfr` by running `sudo pacman -Syu tiny-dfr`.
  2. Restart your Mac.

If you are using Fedora:

  1. Install tiny-dfr with `sudo dnf install rust-tiny-dfr`.
  2. Restart your mac

For other distros:

- Compile [`tiny-dfr`](https://github.com/kekrby/tiny-dfr) yourself if your distro don't have that packaged yet.

# Wi-Fi and Bluetooth

The drivers for Wi-Fi and Bluetooth are included in a kernel with T2 support. But, we also need firmware to get them working from macOS.

Instructions for the same are given in the [Wi-Fi and Bluetooth](https://wiki.t2linux.org/guides/wifi-bluetooth/) guide.

# Network Manager recurrent notifications

Some users have experienced recurrent notifications due the internal usb ethernet interface connected to the T2 chip. To avoid those notifications we can blacklist `cdc_ncm` and `cdc_mbim` modules with the following command:

```sh
sudo sh -c 'echo "# Disable for now T2 chip internal usb ethernet
blacklist cdc_ncm
blacklist cdc_mbim" >> /etc/modprobe.d/blacklist.conf'
```

Please note that this internal ethernet interface is required for various services including touchid that there currently is no Linux support for. In the future, if any of these services are supported, you'll need to undo this.

# Suspend Workaround

S3 suspend has been broken since macOS Sonoma, it has never been fixed, but this workaround will make deep suspend work:

1. Create and edit this file: `/etc/systemd/system/suspend-fix-t2.service`

2. Paste this content:

     ```service
     [Unit]
     Description=Disable and Re-Enable Apple BCE Module (and Wi-Fi)
     Before=sleep.target
     StopWhenUnneeded=yes

     [Service]
     User=root
     Type=oneshot
     RemainAfterExit=yes

     ExecStart=/usr/bin/modprobe -r brcmfmac_wcc
     ExecStart=/usr/bin/modprobe -r brcmfmac
     ExecStart=/usr/bin/rmmod -f apple-bce

     ExecStop=/usr/bin/modprobe apple-bce
     ExecStop=/usr/bin/modprobe brcmfmac
     ExecStop=/usr/bin/modprobe brcmfmac_wcc

     [Install]
     WantedBy=sleep.target
     ```
3. Check your modprobe location
     ```bash
     which modprobe
     which rmmod
     ```
and fix the pathes in service script if they differ for your system

4. If you having problems with touchbar being dead after restoring state from suspend then you might as well try the following version of the script:
     ```service
     [Unit]
     Description=Disable and Re-Enable Apple BCE Module (and Wi-Fi)
     Before=sleep.target
     StopWhenUnneeded=yes
     
     [Service]
     User=root
     Type=oneshot
     RemainAfterExit=yes
     
     ExecStartPre=+/usr/sbin/modprobe -r hid_appletb_kbd
     ExecStart=+/usr/sbin/modprobe -r brcmfmac_wcc
     ExecStart=+/usr/sbin/modprobe -r brcmfmac
     ExecStart=+/usr/sbin/rmmod -f apple-bce
     
     ExecStop=+/usr/sbin/modprobe apple-bce
     ExecStop=+/usr/sbin/modprobe brcmfmac
     ExecStop=+/usr/sbin/modprobe brcmfmac_wcc
     
     
     [Install]
     WantedBy=sleep.target
     ```

This script was written specifically for Debian Bookworm tiny-dfr touchbar issue, but you will loose ability to control keyboard brightness with touchbar. For some reason unloading ```hid_appletb_kbd``` helps to maintain touchbar in alive state but then this module trips and doesnt work anymore.
You can still control keyboard brightness with just bash tho:
     
     sudo su
     echo 8192 | tee /sys/class/leds/\:white\:kbd_backlight/brightness

The path shown in this example is relevant for only MacBookPro16,x and MacBookAir9,1
     
Also you can add a udev rule to give a group write permissions for the brightness value
Add to a new `leds.rules` file in `/etc/udev/rules.d`:

     ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chgrp GROUP_NAME $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"

5. Enable the service by running: `sudo systemctl enable --now suspend-fix-t2.service`

!!! note
    This seems to be working only on Arch with `CONFIG_MODULE_FORCE_UNLOAD=y` in the kernel config or with Debian Bookworm if you followed exact steps from [kernel compilation instructions](https://wiki.t2linux.org/guides/kernel/).
    
To check, run: 
`zcat /proc/config.gz | grep "CONFIG_MODULE_FORCE_UNLOAD"` on arch
or
`cat /boot/config-$(uname -r) | grep "CONFIG_MODULE_FORCE_UNLOAD"` on Debian-based distros.

Without this config option you wont be able to unload the required modules, they will be busy.

6. If touchbar occasionally does not work on boot but works after suspend+restore then you can place this workaround somewhere late after boot
     ```bash
     modprobe -r hid_appletb_kbd
     modprobe -r brcmfmac_wcc
     modprobe -r brcmfmac
     rmmod -f apple-bce
     
     sleep 1
     
     modprobe apple-bce
     modprobe brcmfmac
     modprobe brcmfmac_wcc
     
     touchbar --restart
     ```
This literally just simulates the behaviour that is executed when `suspend-fix-t2.service` is triggered with one extra step at the end which helps to bring touchbar back.
Comment the first line (that kills keyboard brighntess control) if it works fine without that.

You can place this file in your desktop environment autorun folder, create rc.local script or create systemd service for running this script.
