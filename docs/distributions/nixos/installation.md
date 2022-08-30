# NixOS Installation

## Requirements

* A USB that can be plugged in your Mac.

## Installation Steps

1. Get a NixOS iso from the releases page of [this repo](https://github.com/kekrby/nixos-t2-iso) and write it to your USB using `dd` or another tool.
2. Partition your disk using Disk Utily by splitting the main APFS partition into two partitions where one of them is a FAT32 partition with the amount of space you want to allocate for your Linux installation.
3. [Open the Startup Security Utility](https://support.apple.com/en-us/HT208198) and set the security level to "no security".
4. Reboot while pressing the `Option` key and select the orange `EFI Boot` option.
5. Partition your disk using `cfdisk` or the tool of your preference, initialize the partitions with the `mkfs` command of the filesystem you want (`mkswap` is for swap) and mount them under `/mnt`.
    * **Note**: You might want to leave a little part of your disk as a FAT32 partition to be able to transfer files easily between MacOS and Linux.
6. Connect to internet using `iwctl`.
7. Generate your configuration using `sudo nixos-generate-config --root /mnt`.
8. Edit `/mnt/etc/configuration.nix` to your liking. Add `"${builtins.fetchGit { url = "https://github.com/kekrby/nixos-hardware.git"; }}/apple/t2"` to `imports`.
    * **Note**: Don't forget to add a bootloader, `systemd-boot` works quite well. If you want to use `GRUB`, don't forget to set `boot.grub.efiInstallAsRemovable`, `boot.grub.efiSupport` to `true` and `boot.grub.device` to `"nodev"`.
9. Run `sudo nixos-install`.

And the installation is complete!
Note that you should probably transition to a more structured configuration [using flakes](https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support), that is omitted here for brevity.
