# Introduction

This page is a step by step guide to get wifi working on supported models.

**Note that currently only Macs that came with macOS Mojave preinstalled are supported, see [Device Support and State of Features](https://wiki.t2linux.org/state/).**

## On macOS

1. Run both `ioreg -l | grep RequestedFiles` and `system_profiler SPHardwareDataType | grep "Model Identifier"` in a terminal and note down the output.

## On Linux

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

    > Note: Firmware that came with your macOS installation only works when using macOS Mojave, its recommended to use the web hosted version to ensure compatibility. Should you still need to get firmware from your macOS installation, you will find it in `/usr/share/firmware/wifi`

    > Note: If you do not have the 4364 chipset, make sure to use your chipset's identifier in the firmware names

    - Look at the path of the file in the command output that ends in `.trx`. On the website, download that file and rename it to `brcmfmac4364-pcie.bin`.
    - Do the same for the `.clmb` file and rename it to `brcmfmac4364-pcie.clm_blob`.
    - In the end, download the `.txt` file and rename it to `brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt` but change the `15,1` in this string to model identifier was the output of the second command described [here](https://wiki.t2linux.org/guides/wifi/#on-macos).

2. Now that you got those 3 files, move them to `/lib/firmware/brcm/`.
3. You can now test out if the files work by running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` and looking at the list of wifi access points nearby.

    > Note: From this point on the instructions might be different for a distribution that you are trying to install.
    
    > Note: Using iwd is technically not needed for using wifi, however wpa2 is unstable without it. 
    Running the command from step 3 would work for connecting to wpa2 networks as well but it would have to be
    run every time before connecting to a network.

4. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).
5. Edit `/etc/NetworkManager/NetworkManager.conf` to look like the following:

    ```ini
    [device]
    wifi.backend=iwd
    ```

6. Set iwd to run on boot with the following commands (assuming that you are using systemd)

    ```bash
    sudo systemctl enable iwd
    sudo systemctl start iwd
    sudo systemctl restart NetworkManager
    ```

If you wifi disconnects or has issues otherwise its advises to restart iwd: `sudo systemctl restart iwd`