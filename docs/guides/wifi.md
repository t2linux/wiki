# Introduction

This page is a step by step guide to get wifi working on supported models.

**Note that currently some models may not have support
([testing wanted](#BCM4377)), see the table below**

## Is my model supported?

Please check which patchset is reccomended for your model by refering to
the table below, and take note of which firmware version you will need.
Be aware that mbp-nixos and mbp-fedora use the Corellium patchset, and
will need Big Sur firmware.

- You can check what model you have like this:
    - On macOS:
      `system_profiler SPHardwareDataType | grep "Model Identifier"`
    - On Linux: `cat /sys/devices/virtual/dmi/id/product_name`
- If unknown, your Mac's wifi chipset number can be found like this:
    - On macOS: `ioreg -l | grep RequestedFiles`, the number will be
      within the folder names, i.e. "C-`4364`\_\_s-B3" (Your model's
      island will also be in this command's output).
    - On Linux: `lspci -d '14e4:*'`, this will also tell you the
      "Rev"/Revision.

| Model        |Chipset|Revision| Island  | Patchset    |
|----------------|---------|---|----------|-------------|
| MacBookPro16,1 | BCM4364 | 4 | Bali     | Corellium   |
| MacBookPro16,2 | BCM4364 | 4 | Trinidad | Corellium   |
| MacBookPro16,3 | BCM4377 | 4?| Tahiti?  | Corellium[?](#bcm4377)|
| MacBookPro16,4 | BCM4364 | 4 | Bali?    | Corellium   |
| MacBookPro15,1 | BCM4364 | 3 | Kauai    | Aunali1     |
| MacBookPro15,2 | BCM4364 | 3 | Maui     | Aunali1     |
| MacBookPro15,3 | BCM4364 | 3 | Kauai    | Aunali1     |
| MacBookPro15,4 | BCM4377 | 4?| Formosa  | Corellium[?](#bcm4377)|
| MacBookAir9,1  | BCM4377 | 4 | Fiji     | Corellium[?](#bcm4377)|
| MacBookAir8,1  | BCM4355 | ? | Hawaii   | Aunali1     |
| MacBookAir8,2  | BCM43?? | ? | ?        | ?           |
| MacMini8,1     | BCM4364 | 3?| Lanai    | Aunali1     |
| MacPro7,1      | BCM43?? | ? | ?        | ?           |
| iMac20,1       | BCM43?? | ? | ?        | ?           |
| iMac20,2       | BCM43?? | ? | ?        | ?           |
| iMacPro1,1     | BCM43?? | ? | ?        | ?           |

*if there is missing/uncertain information for your model, please make a
pr/issue to add it, or mention it on the discord*

### Aunali1's Patchset

These patches are the default for mbp-ubuntu, mbp-manjaro and mbp-arch.
They requires wifi firmware in that macOS Mojave's format. Mac models
that shipped with Catalina never had Mojave firmware made, so this
patchset does not support wifi on those models (for now). It currently
supports the BCM4364 and BCM4355 chipsets.

### Corellium's Patchset

[This patch](https://github.com/corellium/linux-m1/commit/02ad06fbf2b35916ee329a9bb80d73840d6e2973)
was made by Corellium for M1 Macs and uses wifi firmware in Big Sur's
format. It is the default for mbp-fedora and mbp-nixos. Kernels with
this patch are available for [Ubuntu/Debian](https://github.com/Redecorating/mbp-ubuntu-kernel/releases)
and [Arch based distros](https://github.com/Redecorating/mbp-16.1-linux-wifi/releases),
but you can [compile it yourself](#compiling-with-corelliums-patchset)
if you need/want to. This supports the BCM4364 Chipset, and with
additional patches [should support the BCM4377 Chipset](#BCM4377).

#### Compiling with Corellium's Patchset

Follow the [kernel compiling guide](https://wiki.t2linux.org/guides/kernel/#compile),
But make sure to use [https://github.com/jamlam/mbp-16.1-linux-wifi](https://github.com/jamlam/mbp-16.1-linux-wifi)
instead of [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)
as the patchset repository.

#### BCM4377

The BCM4377 chipset is Broadcom's "2.0" hardware, and requires changes to
the `brcmfmac` driver. The artifact from [this CI run](https://github.com/Redecorating/mbp-16.1-linux-wifi/actions/runs/1037316726)
has an Arch kernel with extra patches in addition to the
Corellium patch that should support the BCM4377. If you test this, you
will need Big Sur wifi firmware.

## On macOS

1. Run both `ioreg -l | grep RequestedFiles` (the names of the firmware files required by your model) and `system_profiler SPHardwareDataType | grep "Model Identifier"` (your model identifier) in a terminal and note down the output, you will need both values in the next steps.
2. If your model identifier is 16,1 you may get the firmware files from [https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware](https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware) by following the instructions given there. On getting the correct files navigate to [On Linux](https://wiki.t2linux.org/guides/wifi/#on-linux) section. If you unable to get working firmware files from there then follow the instructions given for other models.
3. For other models go to [On any OS](https://wiki.t2linux.org/guides/wifi/#on-any-os) section.

> Note: If you are unable to get the firmware even after following guide for other models, you might need to extract firmware from macOS at this point. See the instructions in [On any OS](https://wiki.t2linux.org/guides/wifi/#on-any-os) section.

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

    - If you need Mojave firmware, it is available at [https://packages.aunali1.com/apple/wifi-fw/18G2022/](https://packages.aunali1.com/apple/wifi-fw/18G2022/).

    - If you need Big Sur firmware, then it is avaliable in `/usr/share/firmware/wifi` in macOS Big Sur installations, or online at [https://github.com/Redecorating/archinstall-mbp/tree/packages/apple-t2-wifi-firmware/bigSurFW](https://github.com/Redecorating/archinstall-mbp/tree/packages/apple-t2-wifi-firmware/bigSurFW).

    > Note: For many Mac models, the paths of firmware files shown in terminal (step 1) lead to aliases (shortcuts). In such cases while extracting from macOS, right click on the alias and choose show original. This will select the correct firmware file which you have to use and thus extract the selected file instead.

    > Note: If you do not have the 4364 chipset, make sure to use your wifi chipset's identifier in the firmware names (i.e. replace 4364 with 4355).

    - Look at the path of the file in the command output that ends in `.trx`. On the website, download that file and rename it to `brcmfmac4364-pcie.bin`.
    - Do the same for the `.clmb` file and rename it to `brcmfmac4364-pcie.clm_blob`.
    - In the end, download the `.txt` file and rename it to `brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt` but change the `15,1` in this string to model identifier was the output of the second command described [here](https://wiki.t2linux.org/guides/wifi/#on-macos).

## On Linux

1. Now that you got those 3 files, move them to `/lib/firmware/brcm/`.
2. Check that the files are in place with `ls -l /lib/firmware/brcm | grep 4364`. Replace 4364 with you wifi chipset's identifier. The output should look something like this

    ```plain
    -rw-r--r--. 1 root root   12860 Mar  1 12:44 brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt
    -rw-r--r--. 1 root root  922647 Mar  1 12:44 brcmfmac4364-pcie.bin
    -rw-r--r--. 1 root root   33226 Mar  1 12:44 brcmfmac4364-pcie.clm_blob
    ```

3. You can now test out if the files work by running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` and looking at the list of wifi access points nearby.

    > Note: From this point on the instructions might be different for a distribution that you are trying to install.

    > Note: Using iwd is technically not needed for using wifi, however WPA2 is unstable without it.
    Running the command from step 3 would work for connecting to WPA2 networks as well but it would have to be
    run every time before connecting to a network.

4. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output shoud look similar to this

    ```log
    May 09 11:55:54 hostname kernel: usbcore: registered new interface driver brcmfmac
    May 09 11:55:54 hostname kernel: brcmfmac 0000:03:00.0: enabling device (0000 -> 0002)
    May 09 11:55:54 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4364/3 wl0: Oct 23 2019 08:32:36 version 9.137.11.0.32.6.36 FWID 01-671ec60c
    ```

5. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).

    > Note: `iwd` versions 1.14 and 1.15 do not work (unless you are using the corellium wifi patch). If you have one of those versions, please refer to your distribution's documentation for installing 1.13

6. Edit `/etc/NetworkManager/NetworkManager.conf` to look like the following:

    ```ini
    [device]
    wifi.backend=iwd
    ```

7. Set iwd to run on boot with the following commands (assuming that you are using systemd).

    ```sh
    sudo systemctl enable --now iwd
    sudo systemctl restart NetworkManager
    ```

If you wifi disconnects or has issues otherwise its advised to restart iwd: `sudo systemctl restart iwd`, or reprobe the wifi kernel module: `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac`.
