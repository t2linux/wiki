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

# How to use old touchbar driver

Some users want to use `apple-touchbar` driver instead of `tiny-dfr`, here's how to do so:

1. Create and edit the script file: `switch-touchbar-drv.sh`

2. Paste this content:

    ```bash
    #!/bin/bash
    
    # Switching to root
    sudo $0
    
    if [ "$EUID" -ne 0 ]; then
        exit 1
    fi
    
    # Detecting Package Manager
    PM_INSTALL=""
    PM_REMOVE="null"
    
    if apt --help >/dev/null 2>&1; then
        echo "Debian-based OS are not supported!"
        echo "Please use 'sudo touchbar --switch' instead."
        exit 1
    elif dnf >/dev/null 2>&1; then
        echo "Fedora-based OS are not supported!"
        exit 1
    elif pacman -h >/dev/null 2>&1; then
        PM_INSTALL="pacman -Sy"
        PM_REMOVE="pacman -Rnsu"
    else
        echo "No valid package manager has been found!"
        exit 1
    fi
    
    # Checking dependencies
    echo "Cheking dependencies..."
    
    if ! command -v git &>/dev/null; then # GIT
        echo "git could not be found! Installing..."
        $PM_INSTALL git
    fi
    
    if ! command -v dkms &>/dev/null; then # DKMS
        echo "dkms could not be found! Installing..."
        $PM_INSTALL dkms
    fi
    
    # SWITCH TO OLD DRIVER
    if [[ "$1" == "--old" ]]; then
    
        # Switching to old driver
        echo "Switching to old driver..."
    
        # Removing tiny-dfr
        $PM_REMOVE tiny-dfr
    
        # Blacklisting new driver
        echo "Blacklisting new touchbar driver..."
    
        cat <<- EOF > /etc/modprobe.d/touchbar.conf
        # Disable new Apple Touchbar driver
        blacklist appletbdrm
        blacklist hid_appletb_kbd
        blacklist hid_appletb_bl
        EOF
    
        # Installing old driver
        echo "Cloning driver repo..."
        git clone https://github.com/AdityaGarg8/apple-touchbar-drv /usr/src/apple-touchbar-0.1
        dkms install -m apple-touchbar -v 0.1
    
    # SWITCH TO NEW DRIVER
    elif [[ "$1" == "--new" ]]; then
    
        # Switching to new driver
        echo "Switching to new driver..."
    
        # Installing tiny-dfr
        $PM_INSTALL tiny-dfr
    
        # Removing blacklist conf
        rm /etc/modprobe.d/touchbar.conf
    
        # Removing old driver
        dkms unbuild -m apple-touchbar -v 0.1 -k all
        rm -r /usr/src/apple-touchbar-0.1
    
    else
    
        echo "Choose a valid option:"
        echo "--new (Switches to the new driver)"
        echo "--old (Switches to the old driver)"
        exit 1
    
    fi
    
    # DONE!
    echo "All done! You can now reboot..."
    read -p "Do you want to reboot now? [y/N]" -n 1 -r -s
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Rebooting..."
        reboot
    fi
    ```

3. Make the script executable: `chmod +x switch-touchbar-drv.sh`

4. Run the script `./switch-touchbar-drv.sh --old`

!!! note
    If you are on a Debian-based distro (e.g Ubuntu) just run `sudo touchbar --switch`

!!! note
    If you want to revert changes run `./switch-touchbar-drv.sh --new`

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

3. Enable the service by running: `sudo systemctl enable --now suspend-fix-t2.service`

!!! note
    This seems to be working only on Arch with `CONFIG_MODULE_FORCE_UNLOAD=y` in the kernel config.
    To check, run: `zcat /proc/config.gz | grep "CONFIG_MODULE_FORCE_UNLOAD"`
