# Download the latest safe release

Many thanks to Mike for building. You can download a live iso [here](https://github.com/mikeeq/mbp-fedora).

If you need a more updated kernel, use the iso from [here](https://github.com/sharpenedblade/t2linux-fedora-iso/releases). Follow the instalation instructions below until step 5, then install like a normal Fedora iso. If you do not know how to install Fedora normally, read [this](https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/). Remember to follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/).

# Hardware Requirements

-   USB-C to USB adapter. Important: different USB-C to USB adapters work differently - if you're stuck before getting to the graphical UI during boot this may be the problem.

# Install Procedure

(These instructions are re-used from the Manjaro installation guide)

1. In order to install Fedora, you'll need to partition your SSD. You can use Disk Utility and a recommended amount is over 64 GB. If you have a Bootcamp install, you don't have to uninstall it. Make sure to have two partitions when you're done (Linux partition and macOS partition).
2. Flash the downloaded iso to a USB Flash Drive, or even an SD Card. Use [Balena Etcher](https://www.balena.io/etcher/) for a gui option, command line option is dd.
3. Disable Secure Boot. This is required to even boot into the Live USB. Instructions are below (taken from [here](https://support.apple.com/en-au/HT208330))

    1. Shut down your Mac. Then turn it on. If you hear a startup sound or just see the Apple logo, hold down Command (⌘)-R.

    2. Once you are in Recovery Mode, click on Utilites -> Startup Security Utility

    3. If it asks for your password, type in the administrator's password and press OK.

    4. Set the first option to "No Security", and the second to "Allow booting from External Media".

    5. You should be done. Close the window and reboot your Mac.

4. After disabling Secure Boot, hold down Option (⌥) while the Mac is rebooting.
5. Plug in your USB Flash Drive/SD Card. If two Yellow EFI Boot options appear, select the one towards the very right and hit enter.
6. You should now be in the GRUB boot menu. Select "Try Fedora Live CD".
7. Once booted into Fedora, you can install it like normal until you get to the partition option. If you don't get to the graphic OS, try another USB stick. They are not all created alike.
8. Find the partition you made before. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. (optional) a 1GB ext4 partiton mounted at /boot

    2. rest of the free partition space or around 30GB to an btrfs partition mounted at /

    3. Leave efi boot alone unless using a [separate efi partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions).

9. Continue the rest of the setup. If your Mac somehow turns off with the fans spinning at full speed, go to the FAQs for [Ubuntu](https://wiki.t2linux.org/distributions/ubuntu/faq/) and [Manjaro](https://wiki.t2linux.org/distributions/manjaro/faq/). If not, you should be fine.
10. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
11. Welcome to Fedora! :)
12. Once you're booted and in your desktop, set up [Wi-Fi](https://wiki.t2linux.org/guides/wifi-bluetooth/) to finalize.
