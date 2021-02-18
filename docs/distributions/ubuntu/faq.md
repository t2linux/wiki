# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries accessing the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the External keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occured for anyone on the 16,1 and maybe the 16,4.

(Credits to Redecorating for this fix)

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, edit file ``/etc/default/grub`` with any preferred editior (nano/vim) and with sudo permissions. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file once you're done.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

(Also credits to Redecorating for telling me about this fix, marcosfad for documenting the fix [here](https://github.com/marcosfad/mbp-ubuntu#activate-grub-menu))

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get windows working again.

# Why isn't sound working?

Due to issues in the mbp-ubuntu install process, there is no sound working after install. You'll have to set it up manually.
Refer to this guide on [audio configuration](https://wiki.t2linux.org/guides/audio-config).
