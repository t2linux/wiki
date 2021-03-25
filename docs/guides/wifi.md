# Introduction

This page is a step by step guide to get wifi working on supported models.

**Note that currently not all models have support, see [Is my model supported?](https://wiki.t2linux.org/guides/wifi/#is-my-model-supported).**

## Is my model supported?

- Did your device release with macOS Mojave or earlier initially?
    - If yes, is it a 15,4?
        - If yes, there is currently no support
        - If no, there is support
- If no, is it a 16,1?
    - If yes, there is support using a self compiled kernel
        - If no, there is currently no support

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

## Custom Kernel for 16,1

As mentioned in [Device Support and State of Features](https://wiki.t2linux.org/state/) there is wifi support for the
MacBook Pro 16,1. This is achived through a patchset for a custom kernel.

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
use the firmware files from macOS (as stated in a Note on the page) and not from a fileserver.