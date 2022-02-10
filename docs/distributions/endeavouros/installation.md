# Installing EndeavourOS on a Mac with the T2 Chip

You will need:

- USB drive with at least 4GB
- A way to plug it into your Mac (USB-C isn't USB-A)
- A wired internet connection (i.e. USB-C to Enternet dongle) or wifi.

---

1. Making a partition for Linux.

    1. Open the Bootcamp installer and follow it until it asks for a Windows ISO, this will clear space for a Linux partition (by removing APFS snapshots).
    2. In macOS Disk Utility, make a partition, format doesn't matter, but pick the amount of space that you want for Linux. You won't be able to resize your APFS partitions from the installer, so you must make space now.

2. Creating bootable media

    1. Download an installer ISO from [here](https://github.com/t2linux/EndeavourOS-ISO-t2/releases).
    2. Put this image onto a USB stick, follow these instructions on the [Arch Wiki](https://wiki.archlinux.org/index.php/USB_flash_installation_medium#In_macOS).

3. Disabling secure boot

    1. Follow [this article's](https://support.apple.com/en-us/HT208198) instructions.
    2. Once in startup security utility, turn secure boot to no security and enable external boot.

4. Booting the live environment.

    1. Plug the USB in to your computer.
    2. Boot while holding the option key, this will put you in macOS Startup Manager.
    3. Select the orange EFI option with arrow keys and press return/enter on it.

5. Starting Calamares installer

    1. If you're not connected to the internet, connect to it now. Use included GUI config tool to connect to Wi-Fi.
    2. Click "Start the Installer" on the "Welcome" window.

        !!! warning
            NEVER use the option "Install community editions" or choose "Offline" installation method. They certainly don't work.
            Community edition support is planned, but never expect support for offline install.

    3. Click "Online."

6. Follow the installer until Partitions.

    1. Select "Manual partitioning."
    2. Select "/dev/nvme0n1p1" partition, set the "boot" flag, and set it to mount under "/boot/efi"
    3. Use remaining partition space to your convenience.

7. When you see Desktop, you ***MUST NOT*** uncheck "Apple T2-based devices." This package group contains important packages to support your device. Follow the instruction below to set it properly for your device.

    1. Open "Extras for Apple T2-based devices"
    2. Select proper package for your device.

        1. If your device is not MacBook Pro 16-inch (2019), choose "apple-t2-audio-config"
        2. If your device is MacBook Pro 16-inch (2019), choose "apple-t2-audio-config-alt"

    3. Just continue.

8. Follow the rest of the installer and reboot.

9. You can follow the [Fan guide](https://wiki.t2linux.org/guides/fan/) after rebooting into your install to make your fan work.

10. You now will be able to select your EndeavourOS install in the macOS Startup Manager by holding option at boot.
