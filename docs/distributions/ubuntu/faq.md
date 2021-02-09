# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries accessing the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the External keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occured for anyone on the 16,1 and maybe the 16,4.

(Credits to Redecorating#0350 for this fix)

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, type in ``sudo nano /etc/default/grub``. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file by doing CTRL+X, Y, then enter.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

(Also credits to Redecorating#0350 for telling me about this fix, marcosfad for documenting the fix)

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation.

Unlike other Linux distros, if you try to boot into it, it won't work and will stay at a black screen (confirmed with the 16,1 and might not be true with other models).
There is a fix for this.

While booted into Ubuntu, do the following:

1. Open a terminal and type in ``sudo gdisk /dev/nvme0n1``.
2. Press `x` for expert mode
3. Press `n` to create a protective MBR
4. Press `w` to write the partition and `y` to confirm
5. If gdisk doesn't quit, press `q` to exit the command

It should work now. Reboot into the GRUB Menu and try booting into Windows.

(Credits to gbrow004 for documenting this fix on his [Gist](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4#fixing-bootcampwindows))

# Why isn't sound working?

For some reason, the creator of the mbp-ubuntu iso can't get the sound working after the install. You'll have to do this manually.

For the 16,1 and higher, you can use the files from [here.](https://gist.github.com/kevineinarsson/8e5e92664f97508277fefef1b8015fba)

For anything lower than the 16,1, you can use the files from [here.](https://gist.github.com/MCMrARM/c357291e4e5c18894bea10665dcebffb)

The READMEs in the Gist should be clear on where to put the files. You can download them by clicking on Raw, right clicking, and press Save Page. Place them in an easy to access folder like your Downloads folder.

Once that's done, reboot and sound should be working.
