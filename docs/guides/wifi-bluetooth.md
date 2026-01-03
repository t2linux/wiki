<!-- markdownlint-disable MD046 -->

# Introduction

This page is a step by step guide to get Wi-Fi and Bluetooth working on T2 Macs, as well as **iMac19,1** and **iMac19,2**, which are not T2 Macs. This guide does not apply to other Intel-based Macs.

!!! Bug "Unable to connect to Wi-Fi even after entering correct password"
    Due to a [regression](https://lists.infradead.org/pipermail/hostap/2024-August/042893.html) since **wpa_supplicant 2.11**, Wi-Fi on broadcom chips is broken, thus affecting the T2 Macs as well. Please use [iwd](https://wiki.archlinux.org/title/NetworkManager#Using_iwd_as_the_Wi-Fi_backend) as a backend or **disable offloading** by adding `brcmfmac.feature_disable=0x82000` to your kernel parameters until the issue is resolved. Currently, only Arch Linux and EndeavourOS are affected.

!!! Warning "Do not use `broadcom-wl`"
    We have received a lot of complaints about Wi-Fi not working, and such users have been found to be using `broadcom-wl` driver instead of the stock `brcmfmac` driver. We would like to clarify that `broadcom-wl` is NOT the driver to be used for the Macs supported by us. `brcmfmac` is the only driver that supports these Macs and it is a part of the Linux kernel.

!!! Warning "Arch/EndeavourOS"
    If you're running Arch or EndeavourOS and have `apple-bcm-firmware` installed, you do not need to follow this guide further. The only exception here is if you are using iMac 19,1, iMac 19,2 or iMacPro1,1. If you have one of these Macs, you have to follow this guide.

!!! Warning "NixOS"
    NixOS users please first read the [distribution specific guide on firmware](../distributions/nixos/installation.md#wi-fi-and-bluetooth-setup) before following instructions on this page.

## Setting up

We now use a script which can help you set up Wi-Fi and Bluetooth. Click [here](../tools/firmware.sh) to download the script.

There are 5 methods supported by this script to get firmware for Linux, named as **Method 1-5** in this guide. Details of each method are given in the [On macOS](#on-macos) and [On Linux](#on-linux) section. **You have to choose any one of the five methods to get firmware as per your choice.**

**Method 1-3** require macOS installed on your Mac. The initial steps of these methods are to be followed on macOS, and later steps have to be followed on Linux. Thus, if you choose one of these methods, you first need to follow the [On macOS](#on-macos) section and then proceed to the [On Linux](#on-linux) section.

**Method 4** also requires macOS, but doesn't have any step to be followed on macOS. So you can directly follow the [On Linux](#on-linux) section if you choose it.

**Method 5** does not require macOS, so you can directly follow the [On Linux](#on-linux) section if you choose it.

!!! Tip "macOS Removed after installing Linux"
    In case you have removed macOS after installing Linux, and need the firmware, **Method 5** is the only option for you.

!!! Warning "iMac 19,1, iMac 19,2 and iMacPro1,1"
    If you are a user of **iMac 19,1**, **iMac 19,2** or **iMacPro1,1**, Method 4 and 5 will not work for your model. So, you must choose a method out of Method 1-3 only.

### On macOS

Run the script on the macOS terminal. After you run the script, it will ask you to choose between 3 methods to move firmware to Linux:

=== ":fontawesome-brands-apple: Method 1"
    **Method 1: Copy the firmware to the EFI partition and run the same script on Linux to retrieve it**

    If you choose this method, unlike **Method 2** and **Method 3**, you need not have any specific dependency already installed on your Mac. So if you don't want to install any additional software on macOS, this method is the only option for you.

    In this method, the script will copy the firmware to your **EFI** partition.

    To retrieve the firmware from **EFI** partition in Linux, you shall have to run the same script on Linux. You have 2 options do so, described in detail in [On Linux](#on-linux) section.

=== ":fontawesome-brands-apple: Method 2"
    **Method 2: Create a tarball of the firmware and extract it to Linux**

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Renames the firmware and creates the tarball.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about having missing dependencies.

    Once the script confirms that you have the necessary dependencies installed, it shall create a tarball of the firmware by the name of `firmware.tar` in your **Downloads** folder.

    Now you have to extract the firmware in the tarball to Linux. The procedure has been described in detail in [On Linux](#on-linux) section.

=== ":fontawesome-brands-apple: Method 3"
    **Method 3: Create a Linux specific package which can be installed using a package manager**

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Renames the firmware.
    2. **dpkg** - Creates a package that can be installed on Linux using `apt`.
    3. **rpm** - Creates a package that can be installed on Linux using `dnf`.
    4. **makepkg** - Creates a package that can be installed on Linux using `pacman`.
    5. **coreutils** - Additional requirement of **makepkg**.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about having missing dependencies.

    Once the script confirms that you have the necessary dependencies installed, it shall create a package of the firmware which can be installed by `apt`, `dnf` or `pacman`, depending on the option you chose while running the script. The package shall be saved in your **Downloads** folder.

    Now you have to install the package in Linux using your package manager. The procedure has been described in detail in [On Linux](#on-linux) section.

### On Linux

Once you have run the script on macOS, depending on the method you chose, the steps to be followed on Linux are described below:

=== ":fontawesome-brands-linux: Method 1"
    **Method 1: Copy the firmware to the EFI partition and run the same script on Linux to retrieve it**

    Now we need to retrieve the firmware from the **EFI** partition. You further have 2 options to do so:

    === "Option 1"

        In this option, you have to run the firmware script on Linux. You run it with:

        ```bash
        bash /path/to/firmware.sh
        ```

        After you run the script, you have to choose the **"Retrieve the firmware from the EFI partition"** option. After choosing that option, the script will install the firmware on Linux.

        !!! note

            Replace `/path/to/firmware.sh` with the actual path of the script. For example, if the script is in the Downloads folder in Linux, command to be run would be `bash $HOME/Downloads/firmware.sh`

    === "Option 2"

        In this option, you simply have to run the following commands in Linux:

        ```bash
        sudo mkdir -p /tmp/apple-wifi-efi
        sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
        bash /tmp/apple-wifi-efi/firmware.sh
        sudo umount /tmp/apple-wifi-efi
        ```

        After you run the above commands, you have to choose the **"Retrieve the firmware from the EFI partition"** option. After choosing that option, the script will install the firmware on Linux.

        This option shall be useful if you are unable to copy the script to Linux.

=== ":fontawesome-brands-linux: Method 2"
    **Method 2: Create a tarball of the firmware and extract it to Linux**

    Now we shall extract the tarball of the firmware which was saved in the **Downloads** folder in macOS as `firmware.tar`. In order to do so, copy `firmware.tar` to Linux and extract the firmware to `/lib/firmware/brcm` by running:

    ```bash
    sudo tar -v -xC /lib/firmware/brcm -f /path/to/firmware.tar
    ```

    !!! note

        Replace `/path/to/firmware.tar` with the actual path of the tarball. For example, if `firmware.tar` is copied to the Downloads folder in Linux, command to be run would be `sudo tar -v -xC /lib/firmware/brcm -f $HOME/Downloads/firmware.tar`

    Then reload the Wi-Fi and Bluetooth drivers by running:

    ```bash
    sudo modprobe -r brcmfmac_wcc
    sudo modprobe -r brcmfmac
    sudo modprobe brcmfmac
    sudo modprobe -r hci_bcm4377
    sudo modprobe hci_bcm4377
    ```

=== ":fontawesome-brands-linux: Method 3"
    **Method 3: Create a Linux specific package which can be installed using a package manager**

    Now we have to install the firmware package which was saved in the **Downloads** folder in macOS. Copy the package to Linux and follow the instructions below, depending on whether you use `apt`, `dnf` or `rpm`:

    === "apt"

        This package manager is found in Ubuntu, Debian and other similar distros.

        To install using `apt`, run:

        ```bash
        sudo apt install /path/to/firmware_package.deb
        ```

        !!! note

            Replace `/path/to/firmware_package.deb` with the actual path of the package. For example, if `apple-firmware_14.5-1_all.deb` was created in macOS and has been copied to the Downloads folder in Linux, command to be run would be `sudo apt install $HOME/Downloads/apple-firmware_14.5-1_all.deb`

    === "dnf"

        This package manager is found in Fedora.

        To install using `dnf`, run:

        ```bash
        sudo dnf install --disablerepo=* /path/to/firmware_package.rpm
        ```

        !!! note

            Replace `/path/to/firmware_package.rpm` with the actual path of the package. For example, if `apple-firmware-14.5-1.noarch.rpm` was created in macOS and has been copied to the Downloads folder in Linux, command to be run would be `sudo dnf install --disablerepo=* $HOME/Downloads/apple-firmware-14.5-1.noarch.rpm`

    === "pacman"

        This package manager is found in Arch Linux, EndeavourOS, Manjaro and other similar distros.

        To install using `pacman`, run:

        ```bash
        sudo pacman -U /path/to/firmware_package.pkg.tar.zst
        ```

        !!! note

            Replace `/path/to/firmware_package.pkg.tar.zst` with the actual path of the package. For example, if `apple-firmware-14.5-1-any.pkg.tar.zst` was created in macOS and has been copied to the Downloads folder in Linux, command to be run would be `sudo pacman -U $HOME/Downloads/apple-firmware-14.5-1-any.pkg.tar.zst`

=== ":fontawesome-brands-linux: Method 4"
    **Method 4: Retrieve the firmware directly from macOS**

    !!! warning "Internet connection may be required for **Method 4**"

        **Method 4** needs certain dependencies to work. If they are missing, you need to have an active internet connection on Linux to download and install them. You can use Ethernet, USB tethering or an external Wi-Fi adapter to get internet. If you are using a customized ISO made for T2 Macs, then most likely those dependencies shall be shipped alongwith the ISO, so in that case internet shall not be required.

    This method does not have any steps to be followed on macOS. So, you have to run the script directly on Linux. After you run the script on Linux, you have to choose the **"Retrieve the firmware directly from macOS**" option.

    If you choose this method, the script will install the following dependencies, if missing, on Linux:

    1. **APFS driver for Linux** - Enables mounting and reading of the partition which has macOS to obtain firmware from there. The source code of the driver which shall be installed by the script is obtained from [here](https://github.com/linux-apfs/linux-apfs-rw).

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about having missing dependencies.

    Once the script confirms that you have the necessary dependencies installed, it shall automatically install the firmware.

=== ":fontawesome-brands-linux: Method 5"
    **Method 5: Download a macOS Recovery Image from Apple and extract the firmware from there**

    !!! warning "Internet connection is required for **Method 5**"

        **Method 5** downloads a macOS Recovery image from Apple. So you need to have an active internet connection on Linux. You can use Ethernet, USB tethering or an external Wi-Fi adapter to get internet.
        
    This method does not have any steps to be followed on macOS. So, you have to run the script directly on Linux. After you run the script on Linux, you have to choose the **"Download a macOS Recovery Image from Apple and extract the firmware from there**" option.

    If you choose this method, the script will install the following dependencies, if missing, on Linux: 

    1. **curl** - Downloads a [python script](https://github.com/kholia/OSX-KVM/blob/master/fetch-macOS-v2.py) which is used to download the macOS Recovery image from Apple. **You do not need to manually download the python script. It's link has been shared solely for the purpose of sharing the source code being used.**
    2. **dmg2img** - Converts the downloaded macOS Recovery Image to a Linux readable format.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about having missing dependencies.

    Once the script confirms that you have the necessary dependencies installed, it shall give you the option to choose which macOS version you wish to download. You must choose a version between **macOS Monterey and macOS Sonoma** in order to get complete firmware files. After you choose the desired macOS version, the script should do the rest of the work itself.

## Testing Firmware

You can check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this:

```log
Dec 24 22:34:19 hostname kernel: usbcore: registered new interface driver brcmfmac
Dec 24 22:34:19 hostname kernel: brcmfmac 0000:01:00.0: enabling device (0000 -> 0002)
Dec 24 22:34:20 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4377b3-pcie for chip BCM4377/4
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m-3.1-X0.bin failed with error -2
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m-3.1.bin failed with error -2
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m.bin failed with error -2
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR.bin failed with error -2
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-X0.bin failed with error -2
Dec 24 22:34:20 hostname kernel: brcmfmac: brcmf_c_process_txcap_blob: TxCap blob found, loading
Dec 24 22:34:20 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4377/4 wl0: Jul 16 2021 18:25:13 version 16.20.328.0.3.6.105 FWID 01-30be2b3a
Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0 wlp1s0f0: renamed from wlan0
```
