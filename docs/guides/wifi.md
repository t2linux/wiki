# Introduction

This page is a step by step guide to get wifi working on supported models.
If you need help with the instructions, visit the [Linux on T2 Macs (2018+) Discord Server](https://discord.com/invite/68MRhQu)

**Note that currently not all models have support, see [Is my model supported?](https://wiki.t2linux.org/guides/wifi/#is-my-model-supported).**

## Is my model supported?

You can get your model using `system_profiler SPHardwareDataType | grep "Model Identifier"` on macOS or using `cat /sys/devices/virtual/dmi/id/product_name` on Linux

- Did your device release with macOS Mojave or earlier initially?
    - If yes, is it a 15,4?
        - If yes, there is currently no support
        - If no, there is support
- If no, is it a 16,1 or 16,2?
    - If yes, there is support using a [self compiled kernel](https://wiki.t2linux.org/guides/wifi/#custom-kernel-for-161-162)
    - If no, there is currently no support

## On macOS

1. Run both `ioreg -l | grep RequestedFiles` (the names of the firmware files required by your model) and `system_profiler SPHardwareDataType | grep "Model Identifier"` (your model identifier) in a terminal and note down the output, you will need both values in the next steps.

## On any OS

1. Look at the ouput of the first command listed above, it will probably look something like this

    ```json
    "RequestedFiles" = ({
        "Firmware"="C-4364s-B2/kauai.trx",
        "TxCap"="C-4364s-B2/kauai-X3.txcb",
        "Regulatory"="C-4364s-B2/kauai-X3.clmb",
        "NVRAM"="C-4364s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt"
    })
    ```

    Navigate to [https://packages.aunali1.com/apple/wifi-fw/18G2022/](https://packages.aunali1.com/apple/wifi-fw/18G2022/). 

    > Note: In some cases, like when using the custom kernel for 16,1 models, you might need to use the firmware that came with your macOS installation. You will find it in `/usr/share/firmware/wifi`

    > Note: If you do not have the 4364 chipset, make sure to use your chipset's identifier in the firmware names

    - Look at the path of the file in the command output that ends in `.trx`. On the website, download that file and rename it to `brcmfmac4364-pcie.bin`.
    - Do the same for the `.clmb` file and rename it to `brcmfmac4364-pcie.clm_blob`.
    - In the end, download the `.txt` file and rename it to `brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt` but change the `15,1` in this string to model identifier was the output of the second command described [here](https://wiki.t2linux.org/guides/wifi/#on-macos).

## On Linux

1. Now that you got those 3 files, move them to `/lib/firmware/brcm/`.
2. Check that the files are in place with `ls -l /lib/firmware/brcm | grep 4364`. The output should look something like this

    ```
    -rw-r--r--. 1 root root   12860 Mar  1 12:44 brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt
    -rw-r--r--. 1 root root  922647 Mar  1 12:44 brcmfmac4364-pcie.bin
    -rw-r--r--. 1 root root   33226 Mar  1 12:44 brcmfmac4364-pcie.clm_blob
    ```

3. You can now test out if the files work by running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` and looking at the list of wifi access points nearby.

    > Note: From this point on the instructions might be different for a distribution that you are trying to install.

    > Note: Using iwd is technically not needed for using wifi, however wpa2 is unstable without it. 
    Running the command from step 3 would work for connecting to wpa2 networks as well but it would have to be
    run every time before connecting to a network.

4. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output shoud look similar to this

    ```
    May 09 11:55:54 hostname kernel: usbcore: registered new interface driver brcmfmac
    May 09 11:55:54 hostname kernel: brcmfmac 0000:03:00.0: enabling device (0000 -> 0002)
    May 09 11:55:54 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4364/3 wl0: Oct 23 2019 08:32:36 version 9.137.11.0.32.6.36 FWID 01-671ec60c
    ```

5. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).

    > Note: `iwd` version 1.14 is known to cause issues, although until now only on arch based distributions. If you have this version,
    please refer to your distribution's documentation for installing 1.13

6. Edit `/etc/NetworkManager/NetworkManager.conf` to look like the following:

    ```ini
    [device]
    wifi.backend=iwd
    ```

7. Set iwd to run on boot with the following commands (assuming that you are using systemd)

    ```bash
    sudo systemctl enable iwd
    sudo systemctl start iwd
    sudo systemctl restart NetworkManager
    ```

If you wifi disconnects or has issues otherwise its advises to restart iwd: `sudo systemctl restart iwd`

## Custom Kernel for 16,1 / 16,2

As mentioned in [Is my model supported?](https://wiki.t2linux.org/guides/wifi/#is-my-model-supported) there is wifi support for the
MacBook Pro 16,1 and 16,2. This is achived through a patchset for a custom kernel.

-   If you are on an arch based distribution use the following commands to compile the kernel:

    ```bash
    git clone https://github.com/jamlam/mbp-16.1-linux-wifi.git
    cd mbp-16.1-linux-wifi.git
    makepkg -si
    ```

-   For non arch distributions follow the [Ubuntu Building Guide](https://wiki.t2linux.org/distributions/ubuntu/building/). Make
    sure to use [mbp-16.1-linux-wifi](https://github.com/jamlam/mbp-16.1-linux-wifi)
    instead of [linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch) as the patchset in step 3 however.

Once you have verified that you booted into the correct kernel, follow the [Wifi Guide](https://wiki.t2linux.org/guides/wifi/) but
**use the firmware files from macOS** (as stated in a Note on the page) and not from a fileserver.