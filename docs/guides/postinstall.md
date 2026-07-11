# Introduction

This page explains how to perform a basic setup after installing Linux on a T2 Mac.

## Do you need to do this?

This guide is mainly relevant in the following cases:

1. If you have installed Linux using an official ISO, instead of a T2 ISO.
2. The [Make modules load on early boot](#make-modules-load-on-early-boot) section is relevant for those who wish to encrypt their disk drives using LUKS or some other similar software.
3. If some functionality related to T2 Macs is broken, then you can consider following this guide.

In other cases, you probably won't need to follow this guide.

If you have used a T2 ISO, **make sure you have followed the [distro specific guide](https://wiki.t2linux.org/distributions/overview/) for your distro before continuing**.

## Installing a kernel for T2 support

Installing a kernel with support for T2 Macs is required to get the **keyboard**, **trackpad**, **touch bar**, **audio**, **fan**, and **Wi-Fi** working.

Many distro maintainers provide compiled kernels which can be installed on your Linux installation. Following are the links to the repos providing such kernels:

| Linux Distribution   | Kernel with T2 support |
| -------------------- | ---------------------- |
| Arch based distros   | <https://github.com/NoaHimesaka1873/linux-t2-arch> |
| Fedora               | <https://github.com/t2linux/fedora-kernel> |
| Gentoo               | <https://github.com/t2linux/T2-Gentoo-Kernel> |
| Manjaro              | <https://github.com/NoaHimesaka1873/manjaro-kernel-t2> |
| NixOS                | <https://github.com/NixOS/nixos-hardware> |
| Ubuntu based distros | <https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel> |
| Debian based distros | <https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel> |
| Debian based distros | <https://github.com/andersfugmann/T2-Debian-Kernel> |

If compiled kernels for your distro are not available, then you will have to compile a kernel yourself. You can follow the [Kernel](https://wiki.t2linux.org/guides/kernel/) guide for help.

## Add necessary kernel parameters

Using your bootloader, add the `intel_iommu=on iommu=pt pm_async=off` kernel parameters. For example in GRUB:

  1. Edit `/etc/default/grub`.
  2. On the line with `GRUB_CMDLINE_LINUX="quiet splash"`, add the following kernel parameters: `intel_iommu=on iommu=pt pm_async=off`.
  3. Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` if you are on a non-Debian based distro. If using Debian or Ubuntu based distro, run `sudo update-grub`.

## Make modules load on boot

Simply run the following:

```sh
echo apple-bce | sudo tee /etc/modules-load.d/t2.conf
```

## Make modules load on early boot

Having the `apple-bce` module loaded early allows the use of the keyboard for decrypting encrypted volumes (LUKS).
It is also useful when boot doesn't work and the keyboard is required for debugging.
To do this, you must ensure the `apple-bce` module *as well as its dependent modules* are included in the initial ramdisk.
You can get the list of dependent modules by running `modinfo -F depends apple-bce`
The steps to be followed vary depending upon the initramfs module loading mechanism used by your distro. Some examples are given as follows:

- On systems with `initramfs-tools` (all Debian-based distros):

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

## Adding support for customisable Touch Bar

By default the Touch Bar works in the same mode which Windows Bootcamp uses on Linux. If you want to customize it, you can install `tiny-dfr` on your distro.

If you are using an Ubuntu or Debian based distro:

  1. Add the apt repo for T2 Macs from [here](https://github.com/AdityaGarg8/t2-ubuntu-repo#apt-repository-for-t2-macs).
  2. Install `tiny-dfr` by running `sudo apt install tiny-dfr`.
  3. Restart your Mac.

If you are using Arch Linux or EndeavourOS:

  1. Install `tiny-dfr` by running `sudo pacman -Syu tiny-dfr`.
  2. Restart your Mac.

If you are using Fedora:

  1. Install tiny-dfr with `sudo dnf install rust-tiny-dfr`.
  2. Restart your Mac

For other distros:

- Compile [`tiny-dfr`](https://github.com/AsahiLinux/tiny-dfr) yourself if your distro doesn't have that packaged yet.

In order to make changes to the config for `tiny-dfr`, copy `/usr/share/tiny-dfr/config.toml` to `/etc/tiny-dfr/config.toml` and edit `/etc/tiny-dfr/config.toml` by following the instructions given in that file.

## Change default touchbar mode without tiny-dfr

Run the following command, replacing `1` with the number corresponding to the desired touchbar mode.

|Number|Default   |Fn       |
|------|----------|---------|
|0     |Escape key|Ignore   |
|1     |Function  |Media    |
|2     |Media     |Function |

```bash
cat <<EOF | sudo tee /etc/modprobe.d/tb.conf
options hid-appletb-kbd mode=1
#         Change this number ^
EOF
sudo modprobe -r hid-appletb-kbd
sudo modprobe hid-appletb-kbd
```

!!! info "NixOS"

   If you use NixOS, instead of running the command, add the following to your configuration.
   Modify `mode=1` to your desired value.

   ```nix
   {...}: {
     boot.extraModprobeConfig = ''
       options hid-appletb-kbd mode=1
       #         Change this number ^
     '';
   }
   ```

# Wi-Fi and Bluetooth

The drivers for Wi-Fi and Bluetooth are included in a kernel with T2 support. But, we also need firmware to get Wifi working from macOS.

Instructions for the same are given in the [Wi-Fi and Bluetooth](https://wiki.t2linux.org/guides/wifi-bluetooth/) guide.

# Network Manager recurrent notifications

Some users have experienced recurrent notifications due to the internal USB ethernet interface connected to the T2 chip. To avoid those notifications we can disable the interface with the following command:

```sh
cat <<EOF | sudo tee /etc/udev/rules.d/99-network-t2-ncm.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ac:de:48:00:11:22", NAME="t2_ncm"
EOF

cat <<EOF | sudo tee /etc/NetworkManager/conf.d/99-network-t2-ncm.conf
[main]
no-auto-default=t2_ncm
EOF
```
