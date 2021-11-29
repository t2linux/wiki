# Introduction

This page is a step by step guide to get wifi working on supported models.

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
| MacBookPro16,3   | BCM4377 | 4        | Tahiti   | Big Sur              |
| MacBookPro16,4   | BCM4364 | 4        | Bali?    | Big Sur              |
| MacBookPro15,1   | BCM4364 | 3        | Kauai    | Mojave / Big Sur     |
| MacBookPro15,2   | BCM4364 | 3        | Maui     | Mojave / Big Sur     |
| MacBookPro15,3   | BCM4364 | 3        | Kauai    | Mojave / Big Sur     |
| MacBookPro15,4   | BCM4377 | 4        | Formosa  | Big Sur              |
| MacBookAir9,1    | BCM4377 | 4        | Fiji     | Big Sur              |
| MacBookAir8,1    | BCM4355 | ?        | Hawaii   | Mojave / Big Sur     |
| MacBookAir8,2    | BCM4355 | 0c       | Hawaii   | Mojave / Big Sur     |
| MacMini8,1       | BCM4364 | 3        | Lanai    | Mojave / Big Sur     |
| MacPro7,1        | BCM4364 | 4        | Kahana   | Big Sur              |
| iMac20,1         | BCM4364 | 4        | Hanauma  | Big Sur              |
| iMac20,2         | BCM4364 | 4        | Kure     | Big Sur              |
| iMac19,1*        | BCM4364 | 3?       | Nihau    | Mojave / Big Sur     |
| iMac19,2*        | BCM4364?| 3?       | Midway?  | Mojave / Big Sur?    |
| iMacPro1,1       | BCM4364 | ?        | Ekans?   | Mojave / Big Sur?    |

\*iMac19,x don't have the T2 chip, but they have the same type of wifi chip as T2 Macs.

*If there is missing/uncertain information for your model, please open a [pull request](https://github.com/t2linux/wiki/edit/master/docs/guides/wifi.md) or [issue](https://github.com/t2linux/wiki/issues/new) or mention it on the [discord](https://discord.com/invite/68MRhQu).*

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

You will next need to retrieve three of the four files listed by that command (the `.trx` "Firmware" file, the `.clmb` "Regulatory" file, and the `.txt` "NVRAM" file). The source of these files depends on which firmware type you will use. Copy them to somewhere that you can access them.

#### Mojave Firmware

The default kernels for **mbp-ubuntu**, **mbp-manjaro**, **mbp-arch** and **mbp15-fedora** use Mojave Firmware.

This older firmware is archived at [https://packages.aunali1.com/apple/wifi-fw/18G2022/](https://packages.aunali1.com/apple/wifi-fw/18G2022/).

#### Big Sur Firmware

The default kernels for **mbp16-fedora** and **mbp-nixos** use Big Sur firmware. Also, starting from **fedora 35**, all releases use Big Sur firmware.

For **Ubuntu**, the "t2-j-bigsur", "t2-hwe-bigsur" and "t2-big-sur" variant kernels use Big Sur firmware too. You can get them from [here](https://github.com/marcosfad/mbp-ubuntu-kernel/releases) or this [alternative link](https://github.com/AdityaGarg8/T2-Big-Sur-Ubuntu-Kernel#pre-installation-steps). If you are a 16,1 or 16,2 user and want support for both bluetooth and wifi, then you will have to install a kernel available on the **alternative link** given above. Make sure that your [DKMS Modules](https://wiki.t2linux.org/guides/dkms) are updated and you install **linux-headers** before **linux-image**.

There are also kernels available for [Arch based distros](https://github.com/jamlam/mbp-16.1-linux-wifi/releases) (like Arch Linux and Manjaro) but you can [compile it yourself](https://wiki.t2linux.org/guides/wifi/#compiling-a-kernel-for-using-big-sur-firmware) if you need/want to.

This firmware is available in `/usr/share/firmware/wifi` in macOS Big Sur installations, or online at [https://github.com/AdityaGarg8/macOS-Big-Sur-WiFi-Firmware](https://github.com/AdityaGarg8/macOS-Big-Sur-WiFi-Firmware). If you get firmware from macOS, make sure that if the files are aliases, that you right click on them, and select "Show Original" to get the actual files.

If your model identifier is 16,1 you can take a shortcut and get the firmware files from [https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware](https://github.com/AdityaGarg8/mbp-16.1-wifi-firmware) by following the instructions given there. If you unable to get working firmware files from there then follow the instructions given for other models.

##### Compiling a kernel for using Big Sur firmware

Follow the [kernel compiling guide](https://wiki.t2linux.org/guides/kernel/#compile),
but make sure to use [https://github.com/jamlam/mbp-16.1-linux-wifi](https://github.com/jamlam/mbp-16.1-linux-wifi)
instead of [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)
as the patchset repository.

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

4. You can optionally check the logs to confirm correct loading of the firmware using `sudo journalctl -k --grep=brcmfmac`, the output should look similar to this

    ```log
    May 09 11:55:54 hostname kernel: usbcore: registered new interface driver brcmfmac
    May 09 11:55:54 hostname kernel: brcmfmac 0000:03:00.0: enabling device (0000 -> 0002)
    May 09 11:55:54 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac4364-pcie for chip BCM4364/3
    May 09 11:55:55 hostname kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM4364/3 wl0: Oct 23 2019 08:32:36 version 9.137.11.0.32.6.36 FWID 01-671ec60c
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

### Fixing suspend on models with BCM4377

Models with BCM4377 may have WiFi stop working after suspending. It can be fixed but only when using the `s2idle` sleep state, which doen't save as much power as normal suspend. To use the `s2idle` sleep state, add this to `/etc/systemd/sleep.conf`:

```ini
[Sleep]
SuspendState=freeze
AllowHibernation=no
```

Then to make wifi work after resuming from `s2idle`, create `/lib/systemd/system-sleep/bcm4377-suspend.sh` with the following contents:

```sh
#!/bin/sh
PATH=/sbin:/usr/sbin:/bin:/usr/bin
case "$1" in
    pre)
        echo "Prevent D3cold on 'brcmfmac' devices for $2..." | tee -a /var/log/suspend-brcm.log
        find /sys/bus/pci/drivers/brcmfmac/ | awk -F/ '{print $NF}' | grep -P '^[0-9a-f:.]+$' | while read dev; do echo 0 > "/sys/bus/pci/devices/$dev/d3cold_allowed"; done
        echo "RF block on 'brcmfmac' devices for $2..." | tee -a /var/log/suspend-brcm.log
        find /sys/bus/pci/drivers/brcmfmac/ | awk -F/ '{print $NF}' | grep -P '^[0-9a-f:.]+$' | while read dev; do find "/sys/bus/pci/devices/$dev/ieee80211/" | grep -P '/phy\d+/rfkill\d+/soft$'; done | while read rfkillsoft; do echo 1 > "$rfkillsoft"; done
    ;;
    post)
        echo "RF unblock on 'brcmfmac' devices for $2..." | tee -a /var/log/suspend-brcm.log
        find /sys/bus/pci/drivers/brcmfmac/ | awk -F/ '{print $NF}' | grep -P '^[0-9a-f:.]+$' | while read dev; do find "/sys/bus/pci/devices/$dev/ieee80211/" | grep -P '/phy\d+/rfkill\d+/soft$'; done | while read rfkillsoft; do echo 0 > "$rfkillsoft"; done
    ;;
esac
exit 0
```

Make it executable with `sudo chmod +x /lib/systemd/system-sleep/bcm4377-suspend.sh`.
