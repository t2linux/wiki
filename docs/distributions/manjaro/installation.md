---
icon: simple/manjaro
---

# Deprecation Notice :octicons-stop-16:

Manjaro T2 support is deprecated. See [Deprecation Plan](https://wiki.t2linux.org/distributions/manjaro/deprecation) for more information.

# Download a latest release

[See releases](https://github.com/NoaHimesaka1873/manjaroiso-t2/releases)

# Hardware Requirements

* USB-C to Ethernet cable adapter.
    * While you can install Manjaro over WiFi, it would be a lot easier to use an Adapter during the installation process.
* USB-C to USB Adapter
* USB drive

# Install Procedure

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for installing Manjaro.
2. Boot into the ISO.
3. Scroll down to `Boot x86 64 {Your Edition}` using the arrow keys and press enter.
4. Open the installer and proceed normally until you arrive at the partitioning stage (the Installer will automatically start if you have used the second set of commands given above).
5. Click Manual Partitioning.
6. Click on `/dev/nvme0n1p1`, then press edit at the bottom of the install window, change the mount point to `/boot/efi`, and then click ok.
7. Usually, the macOS partition is `/dev/nvme0n1p2` (the `Apple APFS` Partition). Ignore this partition.
8. Delete the partition you created before - this is usually mounted to `/dev/nvme0n1p3`.
9. These next steps involve partitioning the `/boot`(boot), `/`(Root) and `/home`(Home) partitions of your Linux filesystem. If you know what you're doing, feel free to skip to step 15.

    * Create a `2000 MiB` partition with `ext4` as the file system. Change the mount point to `/boot` and click ok.
    * Create a `51200 MiB` partition with `ext4` as the file system. Change the mount point to `/` and click ok.
    * Use the remaining disk space to create an `ext4` file system. Change the mount point to `/home`.

10. Continue the rest of the setup as normal. Once the setup process is complete, restart your computer. Make sure you remove the install medium once powered off.
11. Once again, power on your computer whilst holding the Option (⌥) key. Then select EFI Boot.
12. Welcome to Manjaro :)
