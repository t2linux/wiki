# Installing EndeavourOS on a Mac with the T2 Chip

You will need:

- USB drive with at least 4GB
- A way to plug it into your Mac (USB-C and USB-A are different)
- A wired internet connection (i.e. USB-C to Ethernet dongle) or Wi-Fi.

---

!!! Warning "Users in NA/EU"
    If you're experiencing slow download speeds or installation failures, please edit your `/etc/pacman.conf` file and replace the old mirror.funami.tech link with `https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release` instead.

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for the installation.

2. Boot into the ISO and start the Calamares installer.

    1. If you're not connected to the internet, connect to it now, unless you're planning to use offline install. Use included GUI config tool to connect to Wi-Fi.
    2. On the "Welcome" window, click "Start the Installer" button.
    3. A pop up window will appear. Choose "Online" or "Offline" depending on your needs.

3. Follow the installer until Partitions.

    1. Select "Manual partitioning."
    2. Select "/dev/nvme0n1p1" partition, make sure the "boot" flag is set, and set it to mount under "/efi". If you want to use separate EFI partition, check out [this guide](https://wiki.t2linux.org/guides/windows/#using-separate-efi-partitions).
    3. Use remaining partition space to your convenience.

4. Follow the rest of the installer and reboot.

5. You can follow the [Fan guide](https://wiki.t2linux.org/guides/fan/) after rebooting into your install if your fan isn't working or if you want to customize how/when your fan will run.

6. You now will be able to select your EndeavourOS install in the macOS Startup Manager by holding option at boot.

7. Optionally, enable `bluetooth` daemon if you want to use Bluetooth.
