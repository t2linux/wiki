# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Fedora. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# My boot hangs before getting to the installer

This may be due to differences between USB-C to USB-A adapters. Try a different one if it is not working.

# My touchbar is blank

This is becuase of a firmware bug. Reboot into MacOS recovery (hold `CMD+R` while booting), then boot back into Fedora.

# My touchbar is flickering

Your touchbar is probably broken at the hardware level. Pay apple to fix it.

# My keyboard won't light up (only applies to some hardware)

This sometimes doesn't work on Fedora, we are working on a fix. For now, you can't really do anything about it.

# I get an error about the bootloader when installing

Download the latest ISO, then try again.

# My wifi stops working after suspending

Run `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac` in a terminal.
