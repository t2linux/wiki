# Introduction

This page is a step by step guide to get wifi working on supported models.

**Note that currently some models may not have support
([testing wanted](https://wiki.t2linux.org/guides/wifi/#bcm4377)), see the table below**

## Getting the right firmware

There are two patchsets for the linux kernel that add wifi support, but they
each use wifi chipset firmware from different versions of macOS, and
support different wifi chipsets.

Please use the table below to check which patchsets will work for your model.

- You can check your Model Identifier like this:
    - On macOS: `system_profiler SPHardwareDataType | grep "Model Identifier"`
    - On Linux: `cat /sys/devices/virtual/dmi/id/product_name`
- If unknown, your Mac's wifi chipset number can be found like this:
    - On macOS: `ioreg -l | grep RequestedFiles`, the number will be
      within the folder names, i.e. "C-`4364`\_\_s-B3" (Your model's
      island will also be in this command's output).
    - On Linux: `lspci -d '14e4:*'`, this will also tell you the
      "Rev"/Revision.

| Model Identifier | Chipset | Revision | Island   | Firmware Options     |
|------------------|---------|----------|----------|----------------------|
| MacBookPro16,1   | BCM4364 | 4        | Bali     | Big Sur              |
| MacBookPro16,2   | BCM4364 | 4        | Trinidad | Big Sur              |
| MacBookPro16,3   | BCM4377 | 4?       | Tahiti?  | Big Sur[?](https://wiki.t2linux.org/guides/wifi/#bcm4377) |
| MacBookPro16,4   | BCM4364 | 4        | Bali?    | Big Sur              |
| MacBookPro15,1   | BCM4364 | 3        | Kauai    | Mojave / Big Sur     |
| MacBookPro15,2   | BCM4364 | 3        | Maui     | Mojave / Big Sur     |
| MacBookPro15,3   | BCM4364 | 3        | Kauai    | Mojave / Big Sur     |
| MacBookPro15,4   | BCM4377 | 4?       | Formosa  | Big Sur[?](https://wiki.t2linux.org/guides/wifi/#bcm4377) |
| MacBookAir9,1    | BCM4377 | 4        | Fiji     | Big Sur[?](https://wiki.t2linux.org/guides/wifi/#bcm4377) |
| MacBookAir8,1    | BCM4355 | ?        | Hawaii   | Mojave               |
| MacBookAir8,2    | BCM43?? | ?        | ?        | ?                    |
| MacMini8,1       | BCM4364 | 3?       | Lanai    | Mojave / Big Sur     |
| MacPro7,1        | BCM43?? | ?        | ?        | ?                    |
| iMac20,1         | BCM43?? | ?        | ?        | ?                    |
| iMac20,2         | BCM43?? | ?        | ?        | ?                    |
| iMacPro1,1       | BCM43?? | ?        | ?        | ?                    |

*if there is missing/uncertain information for your model, please make a
pr/issue to add it, or mention it on the discord*

### Retrieving Firmware

Run `ioreg -l | grep RequestedFiles` in macOS Terminal. Note down the output, and make sure you also know your Model Identifier. The output will be similar to this:

```json
"RequestedFiles" = ({
    "Firmware"="C-4364s-B2/kauai.trx",
    "TxCap"="C-4364s-B2/kauai-X3.txcb",
    "Regulatory"="C-4364s-B2/kauai-X3.clmb",
    "NVRAM"="C-4364s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt"
})
```

You will next need to retrieve three of the four files listed by that command (the `.trx` "Firmware" file, the `.txcb` "Regulatory" file, and the `.txt` "NVRAM" file). The source of these files depends on which firmware type you will use. Copy them to somewhere that you can access them.

#### Mojave Firmware

The default kernels for **mbp-ubuntu**, **mbp-manjaro** and **mbp-arch** use Mojave Firmware.

This older firmware is archived at [https://packages.aunali1.com/apple/wifi-fw/18G2022/](https://packages.aunali1.com/apple/wifi-fw/18G2022/).

#### Big Sur Firmware

The default kernels for **mbp-fedora** and **mbp-nixos** use Big Sur firmware.

For **Ubuntu**, the "mbp-16x-wifi" variant kernels (use `sudo apt install linux-headers-5.10.52-mbp-16x-wifi linux-image-5.10.52-mbp-16x-wifi` to install, but change 5.10.52 to the latest version) uses Big Sur firmware too. Alternatively you can also get a Debian kernel (used by Ubuntu, Pop!_OS, Linux Mint etc.), from [this repo](https://github.com/AdityaGarg8/mbp-16.x-ubuntu-kernel/releases), as the repo may be updated faster with newer kernels.

There are also kernels available for [Arch based distros](https://github.com/Redecorating/mbp-16.1-linux-wifi/releases)
but you can [compile it yourself](https://wiki.t2linux.org/guides/wifi/#compiling-with-corelliums-patchset) if you need/want to.
With additional patches [the BCM4377 Chipset](https://wiki.t2linux.org/guides/wifi/#bcm4377) should work too.

This firmware is available in `/usr/share/firmware/wifi` in macOS Big Sur installations, or online at [https://github.com/Redecorating/archinstall-mbp/tree/packages/apple-t2-wifi-firmware/bigSurFW](https://github.com/Redecorating/archinstall-mbp/tree/packages/apple-t2-wifi-firmware/bigSurFW). If you get firmware from macOS, make sure that if the files are aliases, that you right click on them, and select "Show Original" to get the actual files.

If your model identifier is 16,1 you can take a shortcut and get the firmware files from [https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware](https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware) by following the instructions given there. If you unable to get working firmware files from there then follow the instructions given for other models.

##### Compiling a kernel for using Big Sur firmware

Follow the [kernel compiling guide](https://wiki.t2linux.org/guides/kernel/#compile),
But make sure to use [https://github.com/jamlam/mbp-16.1-linux-wifi](https://github.com/jamlam/mbp-16.1-linux-wifi)
instead of [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)
as the patchset repository.

##### BCM4377

The BCM4377 chipset is Broadcom's "2.0" hardware, and requires changes to
the `brcmfmac` driver. The artifact from [this CI run](https://github.com/Redecorating/mbp-16.1-linux-wifi/actions/runs/1037316726)
has an Arch kernel with extra patches in addition to the
Corellium patch that should support the BCM4377. If you test this, you
will need Big Sur wifi firmware.

### Renaming Firmware

- Rename the `.trx` "Firmware" file to `brcmfmac4364-pcie.bin`, but change `4364` to your wifi chipset number.
- Do the same for the `.clmb` "Regulatory" file and rename it to `brcmfmac4364-pcie.clm_blob`. Again, change `4364` to your chipset number.
- Lastly, rename the `.txt` "NVRAM" file to `brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt` but in addition to changing `4364` to your chipset number, change `MacBookPro15,1` to your Model Identifier.

### Installing Firmware

1. Now that you got those 3 files, move them to `/lib/firmware/brcm/`.
2. Check that the files are in place with `ls -l /lib/firmware/brcm|grep -E "43(64|55|77)"`. The output should look something like this

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

4. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this

    ```log
    May 09 11:55:54 hostname kernel: usbcore: registered new interface driver brcmfmac
    May 09 11:55:54 hostname kernel: brcmfmac 0000:03:00.0: enabling device (0000 -> 0002)
    May 09 11:55:54 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4364/3 wl0: Oct 23 2019 08:32:36 version 9.137.11.0.32.6.36 FWID 01-671ec60c
    ```

5. To get WPA2 to work stably, install the `iwd` package (for example `sudo apt install iwd` on Ubuntu).

    > Note: `iwd` versions 1.14 and 1.15 do not work (unless you are using Big Sur Firmware patch). If you have one of those versions, please refer to your distribution's documentation for installing 1.13

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
