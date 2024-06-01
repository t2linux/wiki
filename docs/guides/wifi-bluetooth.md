<!-- markdownlint-disable MD046 -->

# Introduction

This page is a step by step guide to get Wi-Fi and Bluetooth working on T2 Macs. This guide is also applicable to **iMac19,1** and **iMac19,2**, which are T1 Intel Macs. This guide is NOT applicable for rest T1 and older Intel Macs.

!!! Warning "Arch/EndeavourOS"
    If you're running Arch or EndeavourOS and have `apple-bcm-firmware` installed, you do not need to follow this guide.

## Ensure Kernel Supports OTP Firmware Selection

Check if this command outputs any lines: `modinfo brcmfmac | grep 4387` If it doesn't output anything, then upgrade your kernel.

Refer to the "Updating Kernel" section on your distro's FAQ for instructions if you need to update your kernel:

- [Arch](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel)
- [Fedora](https://github.com/t2linux/fedora?tab=readme-ov-file#instalation)
- [Manjaro](https://wiki.t2linux.org/distributions/manjaro/faq/#updating-kernel)
- [Ubuntu](https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel?tab=readme-ov-file#using-the-apt-repo)

## Setting up

We now use a script which can help you set up Wi-Fi and Bluetooth. Follow the instructions below to use this script :-

### On macOS

1. Click [here](../tools/firmware.sh) to download the script.
2. Boot into macOS.
3. Run this script there.

When you run the script in macOS, it will ask you to choose between 3 methods to move firmware to Linux:

=== "Method 1"
    **Method 1: Run the same script on Linux**

    If you choose this method, unlike **Method 2** and **Method 3**, you need not have any specific dependency already installed on your Mac. So if you don't want to install any additional software on macOS, this method is the only option for you.

    In this method, the script will copy the firmware to your **EFI** partition.

    To retrieve the firmware from **EFI** partition in Linux, you shall have to run the same script on Linux. You have 2 options do so, described in detail in [On Linux](#on-linux) section.

=== "Method 2"
    **Method 2: Create a tarball of the firmware and extract it to Linux**

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Renames the firmware and creates the tarball.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependencies installed, it shall create a tarball of the firmware by the name of `firmware.tar` in your **Downloads** folder.

    Now you have to extract the firmware in the tarball to Linux. The procedure has been described in detail in [On Linux](#on-linux) section.

=== "Method 3"
    **Method 3: Create a Linux specific package which can be installed using a package manager**

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Renames the firmware.
    2. **dpkg** - Creates a package that can be installed on Linux using `apt`.
    3. **rpm** - Creates a package that can be installed on Linux using `dnf`.
    4. **makepkg** - Creates a package that can be installed on Linux using `pacman`.
    5. **coreutils** - Additional requirement of **makepkg**.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependencies installed, it shall create a package of the firmware which can be installed by `apt`, `dnf` or `pacman`, depending on the option you chose while running the script. The package shall be saved in your **Downloads** folder.

    Now you have to install the package in Linux using your package manager. The procedure has been described in detail in [On Linux](#on-linux) section.

### On Linux

Once you have run the script on macOS, depending on the method you chose, the steps to be followed on Linux are described below:

!!! Warning "Running script directly on Linux"
    We have noticed a lot of users directly running the script on Linux and without running it first on macOS. Please ensure that you have run the script on macOS first. If you have removed macOS, this script won't be very helpful.

=== "Method 1"
    **Method 1: Run the same script on Linux**

    Now we need to retrieve the firmware from the **EFI** partition. You further have 2 options to do so:

    === "Option 1"

        In this option, you simply have to copy the same script to Linux, and run it with:

        ```bash
        bash /path/to/firmware.sh
        ```

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

        This option shall be useful if you are unable to copy the script to Linux.

=== "Method 2"
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

=== "Method 3"
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

=== "Method 4"
    **Method 3: Create a Linux specific package which can be installed using a package manager**

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Renames the firmware.
    2. **dpkg** - Creates a package that can be installed on Linux using `apt`.
    3. **rpm** - Creates a package that can be installed on Linux using `dnf`.
    4. **makepkg** - Creates a package that can be installed on Linux using `pacman`.
    5. **coreutils** - Additional requirement of **makepkg**.

    The script shall automatically detect if any dependency is missing, and if required, will give you the option of installing it. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependencies installed, it shall create a package of the firmware which can be installed by `apt`, `dnf` or `pacman`, depending on the option you chose while running the script. The package shall be saved in your **Downloads** folder.

    Now you have to install the package in Linux using your package manager. The procedure has been described in detail in [On Linux](#on-linux) section.

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

## Fixing unstable WPA2 using iwd

Using iwd is technically not needed for using Wi-Fi. But if you are facing unstable WPA2 issues and have to reload the Wi-Fi driver every time you connect to a WPA2 network, you will have to follow this section. If your connection is stable, you needn't follow this section.

Instructions in this section might be different for the distribution that you are trying to install.

1. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).

2. Edit `/etc/NetworkManager/NetworkManager.conf` to look like the following:

    ```ini
    [device]
    wifi.backend=iwd
    ```

3. Set iwd to run on boot with the following commands (assuming that you are using systemd).

    ```sh
    sudo systemctl enable --now iwd
    sudo systemctl restart NetworkManager
    ```

If you Wi-Fi disconnects or has issues otherwise its advised to restart iwd: `sudo systemctl restart iwd`, or reprobe the Wi-Fi kernel module: `sudo modprobe -r brcmfmac_wcc && sudo modprobe -r brcmfmac && sudo modprobe brcmfmac`.
