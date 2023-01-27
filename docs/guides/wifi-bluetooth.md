# Introduction

This page is a step by step guide to get Wi-Fi and Bluetooth working on T2 Macs. This guide is also applicable to **iMac19,1** and **iMac19,2**, which are non T2 Intel Macs, and the newer **Apple Silicon Macs**. Although, Wi-Fi should have been set up already in case of **Apple Silicon Macs** by Asahi's installer.

## Ensure Kernel Supports OTP Firmware Selection

Check if this command outputs any lines: `modinfo brcmfmac | grep 4387` If it doesn't output anything, then upgrade your kernel (better option), or follow this [older Wi-Fi guide](https://github.com/t2linux/wiki/blob/a4b46a7cfbe7efcbb6a0b6111e22172b0f5c4a77/docs/guides/wifi.md).

Refer to the "Updating Kernel" section on your distro's FAQ for instructions if you need to update your kernel:

- [Arch](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel)
- [Fedora](https://github.com/mikeeq/mbp-fedora-kernel#how-to-update-mbp-fedora-kernel)
- [Manjaro](https://wiki.t2linux.org/distributions/manjaro/faq/#updating-kernel)
- [Ubuntu](https://wiki.t2linux.org/distributions/ubuntu/faq/#updating-kernel)

## Setting up

We now use a script which can help you set up Wi-Fi and Bluetooth. Follow the instructions below to use this script :-

### On macOS

1. Click [here](../tools/firmware.sh) to download the script.
2. Boot into macOS.
3. Run this script there.
4. When the script shall run successfully, it shall ask you to follow either of the two options mentioned in the [On Linux](#on-linux) section, on Linux.
5. Boot into Linux.

### On Linux

You have two options here. You can follow either of the two, its purely based on your choice. If your distro installer requires internet to install, you can also follow these steps on a Live ISO environment:

**Note :- We have noticed a lot of users directly running the script on Linux and without running it first on macOS. Please ensure that you have run the script on macOS first. In case you have removed macOS, this script won't be much helpful to you.**

- The first is to either copy this script to Linux via a USB, download it if you have a wired internet connection, or use some other method to get it to Linux. You can then run the script again from Linux and it will finish setting up Wi-Fi and Bluetooth.

- The second method is to simply run the following commands on Linux :-

  ```sh
  sudo umount /dev/nvme0n1p1
  sudo mkdir /tmp/apple-wifi-efi
  sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
  bash /tmp/apple-wifi-efi/firmware.sh
  ```

#### For those who don’t know how to run a script

If you don’t know how to run a script, follow these instructions.

1. Boot into macOS, and download the script. Make sure the script is there in your **Downloads** folder.

2. Open the terminal and run :-
  
    ``` bash
    bash ~/Downloads/firmware.sh
    ```
  
3. Then boot into Linux and place the same script in the **Downloads** folder over there or simply run the commands the script asked you to run in Linux when you executed it in macOS.

4. If you placed the script in the **Downloads** folder instead of running the commands told by the script in macOS, run step 2 command on the terminal, this time in Linux. Else you needn't follow this step.

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
