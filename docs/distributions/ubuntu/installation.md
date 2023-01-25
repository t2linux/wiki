# Download the latest release

!!! Warning "Blank screen on boot"
    **Ubuntu's GRUB** is not booting using the Mac Startup Manager for many users. Thus affected users are advised to [install the rEFInd Boot Manager](https://wiki.t2linux.org/guides/refind/) and boot the kernel using it instead of the Startup Manager.

[Download here](https://github.com/AdityaGarg8/T2-Ubuntu/releases/latest)

# Hardware Requirements

* USB-C to USB adapter

# Install Procedure

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for Ubuntu.
2. Boot into the Live ISO. You should now be in the GRUB boot menu. Select the option which is relevent to you.
3. Start the installer and install it like normal until you get to the partition option.
4. Find the partition you for Linux when you were following the Pre-installation steps. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. If you want, you can make seperate partitions for **swap**, `/home`, `/boot` etc as you do in a normal PC.

    2. The only partition to be made compulsorily is the one mounted at `/` and formatted to **ext4** or **btrfs**.

    3. Leave EFI boot alone. If you want to use a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions), you can separate it out later after installation as instructed [here](https://wiki.t2linux.org/guides/windows/#seperate-the-efi-partition-after-linux-is-installed).

5. Continue the rest of the setup.
6. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
7. Welcome to Ubuntu! :)

# Receiving kernel updates

In order to continue receiving the kernel updates for T2 kernels, it's recommended to set up the kernel update script as described [here](https://github.com/t2linux/T2-Ubuntu-Kernel#using-the-kernel-upgrade-script).

# Troubleshooting

If you are facing issues while installing or have post installation issues (Eg:- Wi-Fi, sound etc.), refer to the [FAQ](https://wiki.t2linux.org/distributions/ubuntu/faq/) section first. If it is not able to help you, you may open an issue [here](https://github.com/t2linux/T2-Ubuntu-Kernel/issues) or contact us on the [Discord server](https://discord.com/invite/68MRhQu).
