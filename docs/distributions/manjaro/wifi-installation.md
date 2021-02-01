# Step 1 - Installing WiFi firmware files

1. Boot into OSX and run the following in terminal: `ioreg -l | grep C-4364`

    It will show something like:

    ```
    "RequestedFiles" = ({"Firmware"="C-4364__s-B2/kauai.trx","TxCap"="C-4364__s-B2/kauai-X3.txcb","Regulatory"="C-4364__s-B2/kauai-X3.clmb","NVRAM"="C-4364__s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt"})

    | |   |         |       "images" = {"C-4364__s-B2/kauai-X3.txcb"={"imagetype"="TxCap","required"=No,"imagename"="C-4364__s-B2/kauai-X3.txcb"},"C-4364__s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt"={"imagetype"="NVRAM","required"=Yes,"imagename"="C-4364__s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt"},"C-4364__s-B2/kauai-X3.clmb"={"imagetype"="Regulatory","required"=Yes,"imagename"="C-4364__s-B2/kauai-X3.clmb"},"C-4364__s-B2/kauai.trx"={"imagetype"="Firmware","required"=Yes,"imagename"="C-4364__s-B2/kauai.trx"}}
    ```

    It'll be different depending on your exact model.

2. There are three files to note down. A `.trx` (for me: `C-4364__s-B2/kauai.trx`), a `.clmb` (for me: `C-4364__s-B2/kauai-X3.clmb` and a `.txt` (for me: `C-4364__s-B2/P-kauai-X3_M-HRPN_V-u__m-7.5.txt`
3. Look for the corrisponding files in this repository: https://packages.aunali1.com/apple/wifi-fw/18G2022/ (Thank you Aunali1)
4. Boot back into linux and place the files in the following locations:
5. Copy the trx to `/lib/firmware/brcm/brcmfmac4364-pcie.bin` (e.g. `sudo cp kauai.trx /lib/firmware/brcm/brcmfmac4364-pcie.bin`)
6. The clmb to `/lib/firmware/brcm/brcmfmac4364-pcie.clm_blob` (e.g. `sudo cp kauai-X3.clmb /lib/firmware/brcm/brcmfmac4364-pcie.clm_blob`)
7. The txt to something like `/lib/firmware/brcm/brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt`. You will need to replace `15,1` with your model number. (e.g. `sudo cp P-kauai-X3_M-HRPN_V-u__m-7.5.txt /lib/firmware/brcm/brcmfmac4364-pcie.Apple Inc.-MacBookPro15,1.txt`).

   a. [Identifying your MacBook Pro Model](https://support.apple.com/en-us/HT201300) or [Identifying your MacBook Air Model](https://support.apple.com/en-au/HT201862)

- Credit to [@mikeeq](https://github.com/mikeeq) for the write up.

# Step 2 - Installing IWD

```
sudo pacman -S iwd wifi-fix-mbp
systemctl stop wpa_supplicant
systemctl mask wpa_supplicant
sudo nano /etc/NetworkManager/NetworkManager.conf
```

paste in this at the end:

```
[device]
wifi.backend=iwd
```

Run:

```
systemctl enable iwd
systemctl enable wifi-fix.service
```

then reboot.