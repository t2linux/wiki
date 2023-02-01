# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Fedora. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# My boot hangs before getting to the installer

This may be due to differences between USB-C to USB-A adapters. Try a different one if it is not working.

# My touchbar is blank

Follow the instructions in the [post-install guide](https://wiki.t2linux.org/guides/postinstall/#setting-up-the-touch-bar). If it still is not working, try updating your macOS instalation.

# My keyboard won't light up (only applies to some hardware)

This sometimes doesn't work on Fedora, we are working on a fix. For now, you can't really do anything about it. This is only affects the internal Apple keyboard, it **will not** affect your external keyboard. This also only occurs on Fedora, the backlight works on all other ditros.

# I get an error about the bootloader when installing

Download the latest ISO, then try again. Make sure you are using the T2 Fedora iso.

# My Wi-Fi stops working after suspending

Try running `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` in a terminal.
