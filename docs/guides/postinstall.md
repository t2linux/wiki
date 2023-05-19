# Introduction

This page explains how to perform a basic set up after installing Linux on a T2 Mac.

## Do you need to do this?

This guide is mainly relevent in the following cases :-

1. If you have installed Linux using an official ISO, instead of a T2 ISO.
2. The [Make modules load on early boot](#make-modules-load-on-early-boot) section is relevant for those who wish to encrypt their disk drives using LUKS or some other similar software.
3. If some functionality related to T2 Macs is broken, then you can consider following this guide.

In rest cases, you probably won't need to follow this guide.

## Installing a kernel for T2 support

Installing a kernel with support for T2 Macs is required in order to get the Keyboard, Trackpad, Touch Bar, Audio, Fan and Wi-Fi working.

Many distro maintainers provide compiled kernels which can be installed on your Linux installation. Following are the links to the repos providing such kernels :-

| Linux Distribution                  | Kernel with T2 support |
| ----------------------------------- | ---------------------- |
| Arch based distros                  | <https://github.com/Redecorating/linux-t2-arch> |
| Arch based distros (Xanmod kernels) | <https://github.com/NoaHimesaka1873/linux-xanmod-edge-t2> |
| Fedora                              | <https://github.com/mikeeq/mbp-fedora-kernel> |
| Fedora                              | <https://github.com/t2linux/t2linux-fedora-kernel> |
| Gentoo                              | <https://github.com/t2linux/T2-Gentoo-Kernel> |
| Manjaro                             | <https://github.com/NoaHimesaka1873/manjaro-kernel-t2> |
| NixOS                               | <https://github.com/kekrby/nixos-hardware> |
| Ubuntu based distros                | <https://github.com/t2linux/T2-Ubuntu-Kernel> |
| Debian based distros                | <https://github.com/andersfugmann/T2-Debian-Kernel> |

If compiled kernels for your distro are not available, then you shall have to compile a kernel on your own. You can follow the [Kernel](https://wiki.t2linux.org/guides/kernel/) guide for help.

## Add necessary kernel paramaters

Using your bootloader, add the `intel_iommu=on iommu=pt pcie_ports=compat` kernel parameters. For example in GRUB :-

  1. Edit `/etc/default/grub`.
  2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pcie_ports=compat`.
  3. Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` if you are on a non-debian based distro. If using Debian or Ubuntu based distro, run `sudo update-grub`.

## Make modules load on boot

Simply run the following :-

```sh
echo apple-bce | sudo tee /etc/modules-load.d/t2.conf
```

## Make modules load on early boot

Having the `apple-bce` module loaded early allows the use of the keyboard for decrypting encrypted volumes (LUKS).
It also is useful when boot doesn't work, and the keyboard is required for debugging.
To do this, one must ensure the `apple-bce` module *as well as its dependent modules* are included in the initial ram disk.
You can get the list of dependent modules by running `modinfo -F depends apple-bce`
The steps to be followed vary depending upon the initramfs module loading mechanism used by your distro. Some examples are given as follows :-

- On systems with `initramfs-tools` (all debian-based distros) :-

    1. Run `sudo su` to open a shell as root.

    2. Run the following over there :-

         ```sh
         cat <<EOF >> /etc/initramfs-tools/modules
         # Required modules for getting the built-in apple keyboard to work:
         snd
         snd_pcm
         apple-bce
         EOF
         update-initramfs -u
         ```

- On systems with mkinitcpio (Commonly used on Arch) :-

    1. Edit the `/etc/mkinitcpio.conf` file.

    2. Ensure that the file has the following :-

         ```sh
         MODULES="apple-bce"
         ```

    3. Run `sudo mkinitcpio -P`.

- On systems with other initramfs/initrd generation systems :-

    In this case, refer to the documentation of the same and ensure the kernel module `apple-bce` is loaded early.

## Setting up the Touch Bar

The Touch Bar can be set up by running [this script](../tools/touchbar.sh) **in Linux** using `bash /path/to/script`. Make sure your Linux kernel and macOS is updated before running this script.

If you want to try something new and you're using Arch Linux, EndeavourOS, or Manjaro, you could install `touchbard` package and use that instead. For more information, visit [touchbard repository](https://github.com/NoaHimesaka1873/touchbard).

After running this script, if you wish to change the default mode of the Touch Bar, run `sudo touchbar` and choose the mode you wish.

In case your Touch Bar is unable to change modes on pressing the fn key, you could try the following :-

- Try running the following and rebooting.
  
   ```sh
   echo -e "# delay loading of the touchbar driver\ninstall apple-touchbar /bin/sleep 7; /sbin/modprobe --ignore-install apple-touchbar" | sudo tee /etc/modprobe.d/delay-tb.conf >/dev/null
   ```
  
- Boot into the [macOS Recovery](https://support.apple.com/en-gb/HT201314) and then restart into Linux.
- Unplug all the external USB keyboards and mouse and then restart into Linux, keeping them unplugged.

If you still face an issue, mention it [here](https://github.com/t2linux/wiki/issues) or on the discord.

# Wi-Fi and Bluetooth

The drivers for Wi-Fi and Bluetooth are included in a kernel with T2 support. But, we also need firmware to get them working from macOS.

Instructions for the same are given in the [Wi-Fi and Bluetooth](https://wiki.t2linux.org/guides/wifi-bluetooth/) guide.

# Network Manager recurrent notifications

Some users have experienced recurrent notifications due the internal usb ethernet interface connected to the T2 chip. To avoid those notifications we can blacklist `cdc_ncm` and `cdc_mbim` modules with the following command:-

```sh
sudo sh -c 'echo "# Disable for now T2 chip internal usb ethernet
blacklist cdc_ncm
blacklist cdc_mbim" >> /etc/modprobe.d/blacklist.conf'
```

Please note that this internal ethernet interface is required for various services including touchid that there currently is no Linux support for. In the future, if any of these services are supported, you'll need to undo this.
