# Introduction

This page is a guide on getting Windows and Linux both installed. Secure Boot Must be disabled from macos recovery. If you want to be able to choose from macos, Windows, or Linux in the Startup Manager (the menu you get by holding ⌥ key), goto 'Using seperate EFI partitions'. If you just want to select between Linux and Windows in the GRUB bootloader, goto 'Using the same EFI partition'. 

The simplist way to triple boot is to install windows first, and install linux on the same EFI partition, so that the Windows option in Startup Manager will let you pick Linux or Windows. To do that, follow the first set of instructions here.

# Using the same EFI partition

## If Windows is installed first

1. Install linux normally, with a patched kernel and dkms modules (this is probably done for you if you are using an installer specific to t2 macs).
2. Put your bootloader on `/dev/nvme0n1p1`, which should be set to mount at `/boot/efi`. Once it installs the bootloader, the windows entry in startup manager will boot linux.
3. Fix blank screen issue that may occur when booting windows (Credits to gbrow004 for documenting this fix on his [Gist](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4#fixing-bootcampwindows)).
	1. Open a terminal and type in ``sudo gdisk /dev/nvme0n1``.
	2. Press `x` for expert mode
	3. Press `n` to create a protective MBR
	4. Press `w` to write the partition and `y` to confirm
	5. If gdisk doesn't quit, press `q` to exit the command
4. Enable the GRUB menu so that you'll have time to pick windows
	1. Boot into your linux install by selecting the windows option in startup manager.
	2. Edit ``/etc/default/grub`` with any preferred editior (nano/vim/) and with sudo. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. If you are using `nano`, save the file by doing CTRL+X, Y, then enter.
	3. We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.
5. You should now be able to boot either Windows or Linux from the GRUB bootloader.

## If Linux is installed first

1. Make sure that your linux partitions are not labled as `Microsoft Basic Data`, if they are, Bootcamp Assistant will think windows is already installed. To fix this, go to Linux and do `sudo cfdisk /dev/nvme0n1` and change the type of your linux partitions to `Linux Filesystem`.
2. Install Windows normaly with Bootcamp. Windows will replace your Linux boot option.
3. Boot into macos.
4. `sudo diskutil mount disk0s1`
5. Go to `/Volumes/EFI/efi`
6. In this folder there will be a `Microsoft` folder, an `Apple` folder, one with your distro's name or just `GRUB`, and one called `Boot`. The `Boot` folder will have a file named `bootx64.efi`, rename this to `windows_bootx64.efi`
7. Copy the `grubx64.efi` file in your distro's folder to `/Volumes/EFI/efi/Boot/bootx64.efi`. The the windows option in Startup Manager will now boot Linux.
8. Fix blank screen issue that may occur when booting windows (Credits to gbrow004 for documenting this fix on his [Gist](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4#fixing-bootcampwindows)).
	1. In Linux, open a terminal and type in ``sudo gdisk /dev/nvme0n1``.
	2. Press `x` for expert mode
	3. Press `n` to create a protective MBR
	4. Press `w` to write the partition and `y` to confirm
	5. If gdisk doesn't quit, press `q` to exit the command
9. Enable the GRUB menu so that you'll have time to pick windows
	1. Boot into your linux install by selecting the windows option in startup manager.
	2. Edit ``/etc/default/grub`` with any preferred editior (nano/vim/) and with sudo. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. If you are using `nano`, save the file by doing CTRL+X, Y, then enter.
	3. We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.
10. You should now be able to boot either Windows or Linux from the GRUB bootloader.

It may be possible to skip steps 5-8 by doing the following command in macos: `sudo sh -c "bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/efi/$(ls|grep -i -e microsoft -e boot -e apple -v)/grubx64.efi --shortform"` This might not prevent step 8 from being needed.

# Using seperate EFI partitions

## Installing Linux (With or without Windows already installed)

### In macOS

Create partitions with Disk Utility:

- Make a 200Mb FAT32 partition, call it something like `EFI2`
- Create your main partition(s) for Linux, make them macOS Extended/HFS+ to stop Bootcamp Installer from thinking they are Windows. These will be erased and reformatted by your installer.

### In your distro's installer

If you are using an interactive installer:

1. Set the `EFI2` partition to be mounted at `/boot/efi`, don't use the partition labeled `EFI` located at `/dev/nvme0n1p1`, to avoid breaking the Windows bootloader stored there.
2. Your main partition that were formatted as macOS Extended/HFS+ can be mounted at `/`.
3.  If it fails to install the bootloader, open a terminal:
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

1. If there are partitions labeled as `Microsoft Basic Data`, Bootcamp Assistant will think you have windows installed. Use `sudo cfdisk /dev/nvme0n1` to change your Linux partitions to `Linux Filesystem` or whatever is appropriate. 
2. If your second EFI partition is labeled as `EFI System`, you'll need to use `cfdisk` again to make it not that, as the Windows installer fails if there are two.
3. Bootcamp should install windows normally. If you put your Linux bootloader on `/dev/nvme0n1p1`, Windows will replace it, and that's why a second EFI partition is ideal.

# Quality of life things

### Giving Options in macOS Startup Manager Custom Icons

Put an `icns` file with your desired icon in the top directory of the disk that the bootloader of the menu entry is on, and call it `.VolumeIcon.icns`.

## Setting your Linux Partitions as `Linux Filesystem` type

Use `sudo cfdisk /dev/nvme0n1` and change the type of your Linux partitions. This will show up when you do `diskutil list` in macOS.
