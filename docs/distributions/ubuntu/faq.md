# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries to access the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the external keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occurred for anyone on the 16,1 and possibly the 16,4.

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, edit file ``/etc/default/grub`` with any preferred editor (nano/vim) and with root permissions. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file once you're done.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

Restart after installing or updating the audio configuration.

# How do I upgrade my kernel

Follow [these](https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel?tab=readme-ov-file#using-the-apt-repo) instructions.
