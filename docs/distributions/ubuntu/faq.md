# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries accessing the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the External keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occured for anyone on the 16,1 and maybe the 16,4.

(Credits to Redecorating for this fix)

# I am unable to login after a fresh install

If the display manager in not appearing, and login from a tty is failing, it could be related to a permission problem. Here is how to check and fix the issue :

1. Reboot Ubuntu in Recovery Mode
  - Press Esc during boot, after the Startup Manager (step where you select EFI instead of Macintosh HD).
  - If you press Esc twice or hold it, you end up in GRUB's cli. Reboot and try again!
  - In the GRUB menu, select the line containing `Advanced Options`
  - Now select the line containing `recovery mode`
2. Use the `root` option to obtain root access to the system
3. Check the permissions on the root directory: `ls -lad /`
  - You should see something like: `drwxr-xr-x`.
  - If you see something different, like `drwx------`, then your user has no permission to read the file system.
4. Give users read access to the file system:
  - `chmod 755 /`
  - `chmod 755 /home/`

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, edit file ``/etc/default/grub`` with any preferred editior (nano/vim) and with root permissions. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file once you're done.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

(Also credits to Redecorating for telling me about this fix, marcosfad for documenting the fix [here](https://github.com/marcosfad/mbp-ubuntu#activate-grub-menu))

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# Why isn't sound working?

Due to issues in the mbp-ubuntu install process, there is no sound working after install. You'll have to set it up manually.
Refer to this guide on [audio configuration](https://wiki.t2linux.org/guides/audio-config).

# Updating Kernel

Ubuntu and Debian based distro users can upgrade their kernel with [these](https://github.com/AdityaGarg8/T2-Ubuntu-Kernel#pre-installation-steps) instructions.
