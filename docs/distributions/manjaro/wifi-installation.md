# Step 1 - Installing WiFi firmware files

Follow the generic instructions on the [wifi guide](https://wiki.t2linux.org/guides/wifi/) until (including) point 3. in the [On Linux](https://wiki.t2linux.org/guides/wifi/#on-linux) section.

# Step 2 - Installing IWD

```sh
sudo pacman -S iwd wifi-fix-mbp
systemctl stop wpa_supplicant
systemctl mask wpa_supplicant
sudo nano /etc/NetworkManager/NetworkManager.conf
```

paste in this at the end:

```ini
[device]
wifi.backend=iwd
```

Run:

```sh
systemctl enable iwd
systemctl enable wifi-fix.service
```

then reboot.
