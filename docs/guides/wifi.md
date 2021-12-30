# Introduction

This page is a step by step guide to get wifi working on T2 Macs.

## Getting the right firmware

You may download the firmware from [here](https://github.com/AdityaGarg8/Apple-WiFi-Firmware/releases/download/Montery/firmware.tar.xz).

### Installing Firmware

1. Extract the firmware files from the .tar.xz and move them to `/lib/firmware/brcm/`.

2. Check that the files are in place with `ls -l /lib/firmware/brcm|grep -E "43(64|55|77)"`.

3. You can now test out if the files work by running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` and looking at the list of wifi access points nearby.

4. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this

    ```log
    Dec 24 22:34:19 hostname kernel: usbcore: registered new interface driver brcmfmac
    Dec 24 22:34:19 hostname kernel: brcmfmac 0000:01:00.0: enabling device (0000 -> 0002)
    Dec 24 22:34:20 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4377b3-pcie for chip BCM4377/4
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m-3.1-X0.bin failed with error -2
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m-3.1.bin failed with error -2
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR-m.bin failed with error -2
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-SPPR.bin failed with error -2
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac4377b3-pcie.apple,tahiti-X0.bin failed with error -2
    Dec 24 22:34:20 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4377/4 wl0: Jul 16 2021 18:25:13 version 16.20.328.0.3.6.105 FWID 01-30be2b3a
    Dec 24 22:34:20 hostname kernel: brcmfmac 0000:01:00.0 wlp1s0f0: renamed from wlan0
    ```

### Fixing unstable WPA2 using iwd

Using iwd is technically not needed for using wifi. But if your are facing unstable WPA2 issues and have to follow step 3 of the above section every time you connect to a WPA2 network, you will have to follow this section. If your connection is stable, you needn't follow this section.

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
