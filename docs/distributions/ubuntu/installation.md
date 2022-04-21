# Download the latest safe release

!!! Warning "Mac Mini"
    Mac Mini users will need to [install rEFInd](https://wiki.t2linux.org/guides/refind/) to boot GRUB as the Mac Startup Manager on Mac Mini is not booting Ubuntu's GRUB directly.

[Download here (experimental)](https://github.com/AdityaGarg8/mbp-ubuntu/releases/latest)

[Download here (old but stable)](https://github.com/marcosfad/mbp-ubuntu/releases/tag/v20.04-5.7.19-1)

The iso you should download depends on your machine, but usually the normal mbp iso works fine.

# Hardware Requirements

* USB-C to Ethernet adapter
    * This isn't required, and you can use a USB WiFi Adapter instead.
* USB-C to USB adapter

# Install Procedure

(These instructions are reused from the Manjaro installation guide)

1. In order to install Ubuntu, you'll need to partition your SSD. You can use Disk Utility and a recommended amount is over 64 GB. If you have a Bootcamp install, you don't have to uninstall it. Make sure to have two partitions when your done (Linux partition and macOS partition).
2. Flash the downloaded iso to a USB Flash Drive, or even an SD Card. Use [Balena Etcher](https://www.balena.io/etcher/) for a gui option, command line option is dd.
3. Disable Secure Boot. This is required to even boot into the Live USB. Instructions are below (taken from [here](https://support.apple.com/en-au/HT208330))

    1. Shut down your Mac. Then turn it on. If you hear a startup sound or just see the Apple logo, hold down Command (⌘)-R.

    2. Once you are in Recovery Mode, click on Utilites -> Startup Security Utility

    3. If it asks for your password, type in the administrator's password and press OK.

    4. Set the first option to "No Security", and the second to "Allow booting from External Media".

    5. You should be done. Close the window and reboot your Mac.

4. After disabling Secure Boot, hold down Option (⌥) while the Mac is rebooting.
5. Plug in your USB Flash Drive/SD Card. If two Yellow EFI Boot options appear, select the one towards the very right and hit enter.
6. You should now be in the GRUB boot menu. Select "Try Ubuntu without installing". Just a warning, if you select "Install Ubuntu", there might be a loud startup sound.
7. Once booted into Ubuntu, you can install it like normal until you get to the partition option.
8. Find the partition you made before. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. (optional) a 1GB ext4 partiton mounted at /boot

    2. (optional) 8GB swap partition (this can be larger depending on what you are using Ubuntu for)

    3. rest of the free partition space or around 30GB to an ext4 partition mounted at /

    4. (Optional) rest of the free partition space to an ext4 partition mounted at /home

    5. Leave efi boot alone until using a [separate efi partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions).

9. Continue the rest of the setup. If your Mac somehow turns off with the fans spinning at full speed, go to FAQ. If not, you should be fine.
10. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
11. Welcome to Ubuntu! :)

If you find that you cannot login after installing check [the FAQ](https://wiki.t2linux.org/distributions/ubuntu/faq.md#i-am-unable-to-login-after-a-fresh-install)
