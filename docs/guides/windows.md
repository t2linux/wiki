# Introduction

This page is a guide on getting windows and Linux both installed.


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


## Quality of life things

### Giving Options in macOS Startup Manager Custom Icons

Put an `icns` file with your desired icon in the top directory of the disk that the bootloader of the menu entry is on, and call it `.VolumeIcon.icns`.

### Setting your Linux Partitions as `Linux Filesystem` type

Use `sudo cfdisk /dev/nvme0n1` and change the type of your Linux partitions. This will show up when you do `diskutil list` in macOS.
