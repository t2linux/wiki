# Ubuntu and Linux Mint

## Download the latest release

!!! Warning "Blank screen on boot"
    **Ubuntu's GRUB** is not booting using the Mac Startup Manager for many users. Thus affected users are advised to [install the rEFInd Boot Manager](https://wiki.t2linux.org/guides/refind/) and boot the kernel using it instead of the Startup Manager.

Download Links:

[Ubuntu and its supported flavors](https://github.com/t2linux/T2-Ubuntu/releases/latest)

[Linux Mint](https://github.com/t2linux/T2-Mint/releases/latest)

We currently support the following flavors of Ubuntu:

- Ubuntu
- Kubuntu
- Ubuntu Unity

## Hardware Requirements

- USB-C to USB adapter

## Install Procedure

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for Ubuntu.
2. Boot into the Live ISO. You should now be in the GRUB boot menu. Select the option which is relevant to you.
3. Start the installer and install it like normal until you get to the partition option. MAKE SURE YOU CHOOSE MANUAL PARTITIONING (USUALLY DISPLAYED AS "Something else" OPTION IN UBUNTU).
4. Find the partition you made for Linux when you were following the Pre-installation steps. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. If you want, you can make separate partitions for **swap**, `/home`, `/boot` etc as you do in a normal PC.

    2. The only partition that must be made is the one mounted at `/` and formatted to **ext4** or **btrfs**.

    3. Leave EFI Boot alone. If you want to use a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-separate-efi-partitions), you can separate it out later after installation as instructed [here](https://wiki.t2linux.org/guides/windows/#separate-the-efi-partition-after-linux-is-installed).

5. Continue the rest of the setup.
6. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
7. Welcome to Ubuntu! :)

## Setting up Wi-Fi and Bluetooth

Once you're booted and in your desktop:

- Run `get-apple-firmware get_from_macos` **if you have macOS installed as well**.
- Run `get-apple-firmware get_from_online` **if you have removed macOS or the above method does not work** (Note: This method needs wired internet to work).

If these methods do not work, follow [this guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) to get firmware for Wi-Fi and Bluetooth.

## Configuring the Touch Bar

If your Mac has a Touch Bar, then you can install the `tiny-dfr` app by running `sudo apt update && sudo apt install tiny-dfr` to set up the Touch Bar. Make sure you restart your Mac after installing the app.

In order to make changes to the config for `tiny-dfr`, copy `/usr/share/tiny-dfr/config.toml` to `/etc/tiny-dfr/config.toml` and edit `/etc/tiny-dfr/config.toml` by following the instructions given in that file.

## Troubleshooting

If you are facing issues while installing or have post installation issues (E.g.: Wi-Fi, sound etc.), refer to the [FAQ](https://wiki.t2linux.org/distributions/ubuntu/faq/) section first. If it is not able to help you, you may open an issue [here](https://github.com/t2linux/T2-Ubuntu/issues) or contact us on the [Discord server](https://discord.com/invite/68MRhQu).
