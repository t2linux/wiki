# Introduction

This page explains how to perform a basic set up after installing Linux on a T2 Mac.

## Do you need to do this?

This guide is mainly relevent in the following cases :

1. If you have installed Linux using an official ISO, instead of a T2 ISO.
2. The [Make modules load on early boot](#make-modules-load-on-early-boot) section is relevant for those who wish to encrypt their disk drives using LUKS or some other similar software.
3. If some functionality related to T2 Macs is broken, then you can consider following this guide.

In rest cases, you probably won't need to follow this guide.

If you have used a T2 ISO, **make sure you have followed the [distro specific guide](https://wiki.t2linux.org/distributions/overview/) for your distro before continuing further.**

## Installing a kernel for T2 support

Installing a kernel with support for T2 Macs is required in order to get the Keyboard, Trackpad, Touch Bar, Audio, Fan and Wi-Fi working.

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

## Adding support for customisable Touch Bar

By default the Touch Bar works in the same mode which Windows Bootcamp uses on Linux. If you want to customise it, you can install `tiny-dfr` on your distro.

If you are using an Ubuntu or Debian based distro:

  1. Add the apt repo for T2 Macs from [here](https://github.com/AdityaGarg8/t2-ubuntu-repo#apt-repository-for-t2-macs).
  2. Install `tiny-dfr` by running `sudo apt install tiny-dfr`.
  3. Restart your Mac.

If you are using Arch Linux or EndeavourOS:

  1. Install `tiny-dfr` by running `sudo pacman -Syu tiny-dfr`.
  2. Restart your Mac.

If you are using Fedora:

  1. Install tiny-dfr with `sudo dnf install rust-tiny-dfr`.
  2. Restart your mac

For other distros:

- Compile [`tiny-dfr`](https://github.com/AsahiLinux/tiny-dfr) yourself if your distro don't have that packaged yet.

In order to make changes to the config for `tiny-dfr`, copy `/usr/share/tiny-dfr/config.toml` to `/etc/tiny-dfr/config.toml` and edit `/etc/tiny-dfr/config.toml` by following the instructions given in that file.

## Change default touchbar mode without tiny-dfr

Run the following command, replacing `1` with the number corresponding to the desired touchbar mode.

|Number|Default   |Fn      |
|------|----------|--------|
|0     |Escape key|Ignore  |
|1     |Function  |Media   |
|2     |Media     |Functin |

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

The drivers for Wi-Fi and Bluetooth are included in a kernel with T2 support. But, we also need firmware to get them working from macOS.

Instructions for the same are given in the [Wi-Fi and Bluetooth](https://wiki.t2linux.org/guides/wifi-bluetooth/) guide.

# Network Manager recurrent notifications

Some users have experienced recurrent notifications due the internal usb ethernet interface connected to the T2 chip. To avoid those notifications we can disable the interface with the following command:

```sh
cat <<EOF | sudo tee /etc/udev/rules.d/99-network-t2-ncm.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ac:de:48:00:11:22", NAME="t2_ncm"
EOF

cat <<EOF | sudo tee /etc/NetworkManager/conf.d/99-network-t2-ncm.conf
[main]
no-auto-default=t2_ncm
EOF
```

# Suspend Workaround

## Fedora and Arch based distros

S3 suspend has been broken since macOS Sonoma, it has never been fixed, but this workaround will make deep suspend work. Currently this workaround works only on Arch based distros and Fedora.

1. Create and edit this file: `/etc/systemd/system/suspend-fix-t2.service`

2. Check your `modprobe` and `rmmod` location by running:

     ```bash
     which modprobe
     which rmmod
     ```

3. Taking the example as `/usr/bin` for location of `modprobe` and `rmmod`, copy the following to `/etc/systemd/system/suspend-fix-t2.service`. If the location is different, do the changes accordingly.

     ```service
     [Unit]
     Description=Disable and Re-Enable Apple BCE Module (and Wi-Fi)
     Before=sleep.target
     StopWhenUnneeded=yes

     [Service]
     User=root
     Type=oneshot
     RemainAfterExit=yes

     #ExecStart=/usr/bin/modprobe -r brcmfmac_wcc
     #ExecStart=/usr/bin/modprobe -r brcmfmac
     ExecStart=/usr/bin/rmmod -f apple-bce

     ExecStop=/usr/bin/modprobe apple-bce
     #ExecStop=/usr/bin/modprobe brcmfmac
     #ExecStop=/usr/bin/modprobe brcmfmac_wcc

     [Install]
     WantedBy=sleep.target
     ```

4. Enable the service by running: `sudo systemctl enable suspend-fix-t2.service`

5. If you are facing issues with Wi-Fi on resume, uncomment the lines having `brcmfmac` and `brcmfmac_wcc` in the above file.

!!! note
    Make sure you have `CONFIG_MODULE_FORCE_UNLOAD=y` in the kernel config.
    To check, run: `zcat /proc/config.gz | grep "CONFIG_MODULE_FORCE_UNLOAD"` on Arch based distros, or `grep "CONFIG_MODULE_FORCE_UNLOAD" /boot/config-$(uname -r)` on Fedora.

## Gentoo/OpenRC

S3 suspend has been broken since macOS Sonoma, it has never been fixed, but this workaround will make deep suspend work on Gentoo Linux using OpenRC and elogind.

Prerequisites:

1. Make sure elogind is installed and running:

     ```bash
     rc-update add elogind boot
     rc-service elogind start
     ```

For T2 MacBooks, while unloading only the apple-bce module is sufficient for basic suspend functionality, additional module handling may be required depending on your model:

- All T2 models require the apple-bce module handling.
- For models with Touch Bar, a specific module sequence (apple_bce -> hid_appletb_bl -> hid_appletb_kbd) is required to properly reinitialize the Touch Bar device after resume.
- If you use tiny-dfr for Touch Bar customization, the tiny-dfr service needs to be stopped before suspend and started after resume, and appletbdrm module is required.

The script below includes all cases with commented sections. Uncomment the relevant sections based on your model and requirements. The loading order of modules is important for proper device initialization after resume.

1. Create and edit this file: `/etc/elogind/system-sleep/apple-bce-handler`

     ```bash
     #!/bin/bash
     case $1/$2 in
       pre/*)
         # Required for all T2 models
         rmmod -f apple_bce

         # Uncomment the following if using tiny dfr for touchbar
         #/etc/init.d/tiny-dfr stop
         #modprobe -r appletbdrm
     
         # Uncomment the following for models with touchbar, irrespective of whether using tiny-dfr
         #modprobe -r hid_appletb_kbd
         #modprobe -r hid_appletb_bl
         ;;
       
       post/*)
         # Required for all T2 models
         sleep 4 
         modprobe apple_bce
         
         # Uncomment the following for models with touchbar, irrespective of whether using tiny-dfr
         #sleep 4
         #modprobe hid_appletb_bl
         #sleep 2
         #modprobe hid_appletb_kbd
         
         # Uncomment the following if using tiny dfr for touchbar
         #sleep 2
         #modprobe appletbdrm
         #sleep 3
         #/etc/init.d/tiny-dfr start
         ;;
     esac
     ```

2. Make the script executable:

     ```bash
     chmod +x /etc/elogind/system-sleep/apple-bce-handler
     ```

!!! note
    Make sure you have CONFIG_MODULE_FORCE_UNLOAD=y in the kernel config.
