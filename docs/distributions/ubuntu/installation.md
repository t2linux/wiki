# Download the latest safe release

!!! Warning "Blank screen on boot"
    **Ubuntu's GRUB** is not booting using the Mac Startup Manager for many users. Thus affected users are advised to [install the rEFInd Boot Manager](https://wiki.t2linux.org/guides/refind/) and boot the kernel using it instead of the Startup Manager.

[Download here (20.04)](https://github.com/marcosfad/mbp-ubuntu/releases/latest)

[Download here (22.04)](https://github.com/AdityaGarg8/T2-Ubuntu/releases/latest)

# Hardware Requirements

* USB-C to Ethernet adapter
    * This isn't required, and you can use a USB WiFi Adapter instead.
* USB-C to USB adapter

# Install Procedure

(These instructions are reused from the Manjaro installation guide)

1. In order to install Ubuntu, you'll need to partition your SSD. You can use Disk Utility and a recommended amount is over 64 GB. If you have a Bootcamp install, you don't have to uninstall it. Make sure to have atleast two partitions when your done (Linux partition and macOS partition, Windows too, if installed).
2. Flash the downloaded iso to a USB Flash Drive, or even an SD Card. Use [Balena Etcher](https://www.balena.io/etcher/) for a GUI option, command line option is `dd`. If using [Rufus](https://rufus.ie/), make sure you burn it in **DD mode** and *not* the **ISO mode**.
3. Disable Secure Boot and allow booting from external drives. This is required to even boot into the Live USB. Instructions are below (taken from [here](https://support.apple.com/en-au/HT208330)):

    1. Shut down your Mac. Then turn it on. If you hear a startup sound or just see the Apple logo, hold down Command (⌘)-R.

    2. Once you are in Recovery Mode, click on Utilites -> Startup Security Utility.

    3. If it asks for your password, type in the administrator's password and press OK.

    4. Set the first option to "No Security", and the second to "Allow booting from External Media".

    5. You should be done. Close the window and reboot your Mac.

4. After disabling Secure Boot, hold down Option (⌥) while the Mac is rebooting.
5. Plug in your USB Flash Drive/SD Card. If two Yellow EFI Boot options appear, select the one towards the very right and hit enter.
6. You should now be in the GRUB boot menu. Select the option which is relevent to you.
7. Once booted into Ubuntu, you can install it like normal until you get to the partition option.
8. Find the partition you made before. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. If you want, you can make seperate partitions for **swap**, `/home`, `/boot` etc as you do in a normal PC.

    2. The only partition to be made compulsorily is the one mounted at `/` and formatted to **ext4** or **btrfs**.

    3. Leave EFI boot alone until using a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions).

9. Continue the rest of the setup. If your Mac somehow turns off with the fans spinning at full speed, go to [FAQ](https://wiki.t2linux.org/distributions/ubuntu/faq/). If not, you should be fine.
10. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
11. Welcome to Ubuntu! :)

# Receiving kernel updates

In order to continue receiving the kernel updates for T2 kernels, it's recommended to set up the kernel update script as described [here](https://github.com/t2linux/T2-Ubuntu-Kernel#using-the-kernel-upgrade-script).
