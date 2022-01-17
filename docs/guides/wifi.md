# Introduction

This page is a step by step guide to get wifi working on T2 Macs.

!!! Info "Fedora"
    Fedora users are requested to follow the older version of this guide [here](https://github.com/t2linux/wiki/blob/a4b46a7cfbe7efcbb6a0b6111e22172b0f5c4a77/docs/guides/wifi.md).

!!! Info "Ubuntu"
    If you have used the [old but stable](https://github.com/marcosfad/mbp-ubuntu/releases/tag/v20.04-5.7.19-1) ISO, then you will have to upgrade your [DKMS drivers](https://wiki.t2linux.org/guides/dkms/) and your [kernel](https://github.com/AdityaGarg8/T2-Ubuntu-Kernel#pre-installation-steps) before following this guide.

## Getting the firmware

In order to get wifi running on Linux, we need to get the firmware from macOS and copy it to Linux with appropriate changes. Thanks to Asahi Linux, who has made the process much simpler. You may follow the steps below to get the firmware and copy it to Linux properly.

1. Boot into macOS.

2. Open the terminal and run :-

   ```sh
   cp -r /usr/share/firmware/wifi ~/Desktop
   curl -L https://github.com/AsahiLinux/asahi-installer/archive/refs/heads/main.tar.gz > ~/Desktop/asahi-installer-main.tar.gz
   ```

   This shall make a folder named **wifi** and a zip archive named **asahi-installer-main.tar.gz** on the macOS Desktop.

3. Copy the **wifi** folder and the **asahi-installer-main.tar.gz** archive to an external drive or a partition which is formatted to a file system readable by Linux. You can also use your EFI partition by mounting it using `sudo diskutil mount disk0s1`.

4. Boot into Linux.

5. Copy the **wifi** folder and the **asahi-installer-main.tar.gz** archive to the **Home** folder using your file manager.

6. Open the terminal and run :-

   ```sh
   tar xvf asahi-installer-main.tar.gz
   cd asahi-installer-main/src
   python3 -m firmware.wifi ~/wifi firmware.tar
   cd /lib/firmware
   sudo tar xvf ~/asahi-installer-main/src/firmware.tar
   sudo rm -r ~/asahi-installer-main* ~/wifi
   ```

## Testing Firmware

1. You can now test out if the files work by running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` and looking at the list of wifi access points nearby.

2. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this

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

Using iwd is technically not needed for using wifi. But if your are facing unstable WPA2 issues and have to follow step 1 of the above section every time you connect to a WPA2 network, you will have to follow this section. If your connection is stable, you needn't follow this section.

Instructions in this section might be different for the distribution that you are trying to install.

1. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).

    !!! warning "Some users have experienced issues with `iwd`"
        Refer to [warnings](https://wiki.t2linux.org/#warnings) for iwd version incompatibilities

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
