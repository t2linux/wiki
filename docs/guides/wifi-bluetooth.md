<!-- markdownlint-disable MD046 -->

# Introduction

This page is a step by step guide to get Wi-Fi and Bluetooth working on T2 Macs. This guide is also applicable to **iMac19,1** and **iMac19,2**, which are non T2 Intel Macs.

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

When you run the script in macOS, it will give you to choose between 3 methods to move firmware to Linux:

=== "Method 1"
    #### Method 1: Run the same script on Linux

    If you choose this method, unlike **Method 2** and **Method 3**, you need not have any specific dependency already installed on your Mac. So if don't want to install any additional software on your Mac, this method is the only option for you.

    In this method, the script will copy the firmware to your **EFI** partition.

    To retrieve the firmware from **EFI** partition in Linux, you shall be asked to run the same script on Linux. You have 2 options do so, described in detail in [On Linux](#on-linux) section.

=== "Method 2"
    #### Method 2: Create a tar archive of the firmware in your Downloads folder and manually copy it to Linux

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Needed to rename the firmware and create the tar archive.

    The script shall automatically detect if they are missing, and if required, will give you the option of installing them. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependecies installed, it shall create a tar archive of the firmware by the name of `firmware.tar` in your **Downloads** folder.

    Now you have to extract the firmware in the tar archive to Linux. The procedure has been described in detail in [On Linux](#on-linux) section.

=== "Method 3"
    #### Method 3: Create a Linux distribution specific package which can be installed using a package manager

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Needed to rename the firmware.
    2. **dpkg** - Needed if you are creating package for installing on Linux using **apt** package manager.
    3. **rpm** - Needed if you are creating package for installing on Linux using **dnf** package manager.
    4. **makepkg** - Needed if you are creating package for installing on Linux using **pacman** package manager.
    5. **coreutils** - It is required for proper functioning of **makepkg**.

    The script shall automatically detect if they are missing, and if required, will give you the option of installing them. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependencies installed, it shall create a package of the firmware which can be installed by **apt**, **dnf** or **pacman**, depending on the option you chose while running the script. The package shall be saved in your **Downloads** folder.

    Now you have to install the package in Linux using your package manager. The procedure has been described in detail in [On Linux](#on-linux) section.

### On Linux

Once you have run the script on macOS, depending on the method you chose, the steps to be followed in Linux as described below:

!!! Warning "Running script directly on Linux"
    We have noticed a lot of users directly running the script on Linux and without running it first on macOS. Please ensure that you have run the script on macOS first. If you have removed macOS, this script won't be very helpful.

=== "Method 1"
    #### Method 1: Run the same script on Linux

    Now we need to retrieve the firmware from the **EFI** partition. You further have 2 options to do so:

    === "Option 1"

        In this option, you simply have to copy the script to

    === "Option 2"

        todo

=== "Method 2"
    #### Method 2: Create a tar archive of the firmware in your Downloads folder and manually copy it to Linux

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Needed to rename the firmware and create the tar archive.

    The script shall automatically detect if they are missing, and if required, will give you the option of installing them. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependecies installed, it shall create a tar archive of the firmware by the name of `firmware.tar` in your **Downloads** folder.

    Now you have to extract the firmware in the tar archive to Linux. The procedure has been described in detail in [On Linux](#on-linux) section.

=== "Method 3"
    #### Method 3: Create a Linux distribution specific package which can be installed using a package manager

    If you choose this method, the script will install the following dependencies, if missing, on macOS:

    1. **python3** - Needed to rename the firmware.
    2. **dpkg** - Needed if you are creating package for installing on Linux using **apt** package manager.
    3. **rpm** - Needed if you are creating package for installing on Linux using **dnf** package manager.
    4. **makepkg** - Needed if you are creating package for installing on Linux using **pacman** package manager.
    5. **coreutils** - It is required for proper functioning of **makepkg**.

    The script shall automatically detect if they are missing, and if required, will give you the option of installing them. So you need not worry about not having any dependency installed.

    Once the script confirms that you have the necessary dependencies installed, it shall create a package of the firmware which can be installed by **apt**, **dnf** or **pacman**, depending on the option you chose while running the script. The package shall be saved in your **Downloads** folder.

    Now you have to install the package in Linux using your package manager. The procedure has been described in detail in [On Linux](#on-linux) section.

## Testing Firmware

You can check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this

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

Using iwd is technically not needed for using wifi. But if you are facing unstable WPA2 issues and have to follow step 1 of the above section every time you connect to a WPA2 network, you will have to follow this section. If your connection is stable, you needn't follow this section.

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

If you wifi disconnects or has issues otherwise its advised to restart iwd: `sudo systemctl restart iwd`, or reprobe the wifi kernel module: `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac`.
