# Introduction

This page explains how to remove Linux from your Mac. It shouldn't matter what distro you are using.

# Removing Linux partitions

You may want to do this from macOS Recovery as you will be resizing (expanding) your startup disk, although you don't need to.

1. In macOS open Disk Utility
2. Click "View" then "Show all devices"
3. Select your Apple SSD
4. Click "Partition". If it suggests adding volumes, don't.
5. Select your Linux partition, and click `-` to remove it. Your macOS partition should expand to fill the space that Linux was in.
6. Click apply.
7. Disk Utility will remove your Linux partition and expand your macOS partition. This may take a while, but **do not interrupt this process**. While it does this, consider the fact that you didn't need admin to remove your Linux partition.

# Removing the Linux boot-loader

1. In macOS run `sudo diskutil mount disk0s1`, which mounts your EFI System Partition.
2. There will now be an "EFI" disk visible in Finder, open it and go into the "EFI" folder (within the "EFI" disk).
3. Remove any folders other than "Apple", "Boot", or "Microsoft".
4. Enter the "Boot" folder
5. If you don't have Windows installed with Bootcamp, remove `bootx64.efi`. If you have Windows installed with Bootcamp, you may want to replace `bootx64.efi` with `Microsoft/Boot/bootmgfw.efi`, but be careful not to delete the Windows bootloader.

# Enable Secure Boot (Optional)

1. Boot to macOS Recovery by holding `⌘-R` as you turn your Mac on.
2. Enable Secure Boot as described [here](https://support.apple.com/en-au/HT208198).
