# Introduction

This page is a guide on getting Windows and Linux both installed. Secure Boot Must be disabled from macOS recovery. If you want to be able to choose from macOS, Windows, or Linux in the Startup Manager (the menu you get by holding ⌥ key), goto 'Using separate EFI partitions'. If you just want to select between Linux and Windows in the GRUB bootloader, goto 'Using the same EFI partition'.

The simplest way to triple boot is to install Windows first, and install Linux on the same EFI partition, so that the Windows option in Startup Manager will let you pick Linux or Windows. To do that, follow the first set of instructions here.

# Using the same EFI partition

## If Windows is installed first

1. Install [Linux normally](https://wiki.t2linux.org/guides/preinstall/) (this is probably done for you if you are using an installer specific to T2 Macs). During installation, Put your bootloader on `/dev/nvme0n1p1`, which should be set to mount at `/boot/efi`. Once it installs the bootloader, the Windows entry in startup manager will boot Linux.

2. Fix blank screen issue that may occur when booting Windows (Credits to gbrow004 for documenting this fix on his [Gist](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4#fixing-bootcampwindows)):

    1. Open a terminal and type in ``sudo gdisk /dev/nvme0n1``.
    2. Press `x` for expert mode
    3. Press `n` to create a protective MBR
    4. Press `w` to write the partition and `y` to confirm
    5. If gdisk doesn't quit, press `q` to exit the command

    !!! info
        Currently, this issue has been observed only with Ubuntu. If you are not facing this issue, you can safely skip this step.

3. Enable the GRUB menu so that you'll have time to pick Windows:

    1. Boot into your Linux install by selecting the Windows option in startup manager.
    2. Edit `/etc/default/grub` with any preferred editor (nano/vim/) and with `sudo`. Change line `GRUB_TIMEOUT_STYLE` to `GRUB_TIMEOUT_STYLE=MENU`. If you are using `nano`, save the file by doing CTRL+X, Y, then enter.
    3. We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in `sudo update-grub` (For Ubuntu) or `sudo grub-mkconfig -o /boot/grub/grub.cfg` (For Arch based distros) and hit enter. After the command is done, you're finished.

    !!! note "Using bootloaders other than GRUB"
        In case you are using some other bootloader, like systemd-boot, consult the documentation for the same.

4. You should now be able to boot either Windows or Linux from the GRUB bootloader.

## If Linux is installed first

1. Make sure that your Linux partitions are not labeled as `Microsoft Basic Data`, if they are, Bootcamp Assistant will think Windows is already installed. To fix this, go to Linux and do `sudo cfdisk /dev/nvme0n1` and change the type of your Linux partitions to `Linux Filesystem`.
2. Install Windows normally with Bootcamp. Windows will replace your Linux boot option.
3. Boot into macOS.
4. `sudo diskutil mount disk0s1`
5. Go to `/Volumes/EFI/efi`
6. In this folder there will be a `Microsoft` folder, an `Apple` folder, one with your distro's name or just `GRUB`, and one called `Boot`. The `Boot` folder will have a file named `bootx64.efi`, rename this to `windows_bootx64.efi`
7. Copy the `grubx64.efi` file in your distro's folder to `/Volumes/EFI/efi/Boot/bootx64.efi`. The the Windows option in Startup Manager will now boot Linux.
8. Fix blank screen issue that may occur when booting Windows (Credits to gbrow004 for documenting this fix on his [Gist](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4#fixing-bootcampwindows)).

    1. In Linux, open a terminal and type in ``sudo gdisk /dev/nvme0n1``.
    2. Press `x` for expert mode
    3. Press `n` to create a protective MBR
    4. Press `w` to write the partition and `y` to confirm
    5. If gdisk doesn't quit, press `q` to exit the command

9. Enable the GRUB menu so that you'll have time to pick Windows

    1. Boot into your Linux install by selecting the Windows option in startup manager.
    2. Edit ``/etc/default/grub`` with any preferred editor (nano/vim/) and with sudo. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. If you are using `nano`, save the file by doing CTRL+X, Y, then enter.
    3. We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

10. You should now be able to boot either Windows or Linux from the GRUB bootloader.

It may be possible to skip steps 5-8 by doing the following command in macOS: `sudo sh -c "bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/efi/$(ls /Volumes/EFI/efi|grep -i -e microsoft -e boot -e apple -v)/grubx64.efi --shortform"` This might not prevent step 8 from being needed.

# Using separate EFI partitions

## Installing Linux (With or without Windows already installed)

### In macOS

Create partitions with Disk Utility:

- Make a 500Mb FAT32 partition, call it something like `EFI2`. Make sure you do not use `EFI` as the label.
- Create your main partition(s) for Linux, make them macOS Extended/HFS+ to stop Bootcamp Installer from thinking they are Windows. These will be erased and reformatted by your installer.

### In your distro's installer

If you are using an interactive installer:

1. Set the `EFI2` partition to be mounted at `/boot/efi` and set it as "ESP"/"Boot"/"EFI System Partition". Don't use the partition labeled `EFI` located at `/dev/nvme0n1p1`, to avoid breaking the Windows bootloader stored there. Ensure that `/dev/nvme0n1p1` wasn't set by default to be used as the "EFI System Partition".

    !!! info "Ubuntu"
        On Ubuntu since the installer doesn't support separate EFI partitions, install normally to the Windows EFI partition and follow [this section](https://wiki.t2linux.org/guides/windows/#separate-the-efi-partition-after-linux-is-installed) to separate out the partition.

2. Your main partition that were formatted as macOS Extended/HFS+ can be mounted at `/`.

3. If it fails to install the bootloader, open a terminal:

    1. Use `lsblk` or `mount` to find where your install's root partition is installed
    2. `chroot $that_partitions_mount_point_here`
    3. `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram --removable`

4. There will now be an `EFI Boot` option in the macOS Startup Manager (The menu you get by holding option at boot) which will boot Linux.

If you are doing it manually:

1. Format the main Linux partition(s) as ext4, btrfs, or whatever you intend to use.
2. Mount your partitions, put the `EFI2` one at `/boot/efi` within your chroot.
3. Install normally up until you install your bootloader, but don't forget to get a patched kernel and the correct dkms modules
4. Within your chroot, do `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram --removable`
5. There will now be an `EFI Boot` option in the macOS Startup Manager (The menu you get by holding option at boot) which will boot Linux.

## Installing Windows when Linux is installed

1. If there are partitions labeled as `Microsoft Basic Data`, Bootcamp Assistant will think you have Windows installed. Use `sudo cfdisk /dev/nvme0n1` to change your Linux partitions to `Linux Filesystem` or whatever is appropriate.
2. If your second EFI partition is labeled as `EFI System`, you'll need to use `cfdisk` again to make it not that, as the Windows installer fails if there are two.
3. Bootcamp should install Windows normally. If you put your Linux bootloader on `/dev/nvme0n1p1`, Windows will replace it, and that's why a second EFI partition is ideal.

## Separate the EFI partition after Linux is installed

In case you have installed Linux to the same EFI partition as used by Windows, and now want to separate it out, then:

1. Using disk utility, make a 500Mb FAT32 partition, call it something like `EFI2`. Make sure you do not use `EFI` as the label.
2. Download [this script](https://wiki.t2linux.org/tools/efi.sh).
3. Run this script using `bash /path/to/script <Name of separate partition>` in Linux. E.g.: If your separate partition has the name `EFI2`, and script is in your Downloads folder, run `bash $HOME/Downloads/efi.sh EFI2`.
