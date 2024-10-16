#!/usr/bin/env bash
# Copyright (c) 2022 Aditya Garg

set -euo pipefail

if [[ `uname -s` != "Linux" ]] ; then
	echo "This script is intended to be run from Linux. Aborting!"
	exit 1
fi


if [[ ${1-default} == default ]] ; then
	echo "Please specify the name of the new EFI partition. Aborting!"
	exit 1
fi

if [ $USER != root ]
then
echo "This script is intented to be run as root. You will be asked for your password."
sudo chmod 755 $0
sudo $0 "$1"
exit 0
fi

echo "Are you sure you want to change your EFI partition to \""$1"\"? (y/N)"
read input
if [[ ($input != y) && ($input != Y) ]]
then
	echo "Abort!"
	exit 1
fi

echo "Changing the EFI partition."
# Mount the new partition to /tmp/newefi

mkdir /tmp/newefi
MOUNTPOINT=$(lsblk -o label,mountpoints | grep -w "$1" | cut -d "/" -f 2-)
OLDUUID=$(lsblk -o mountpoints,uuid | grep -w "/boot/efi" | xargs | cut -d " " -f 2)
NEWUUID=$(lsblk -o uuid,label | grep -w "$1" | xargs | cut -d " " -f 1)
FSTABUUID=$(cat /etc/fstab | grep "${OLDUUID}" | cut -d "=" -f 2 | cut -c 1-9)
if [[ ${OLDUUID} != ${FSTABUUID} ]]
then
	echo "Old EFI partition not found in /etc/fstab. Abort!"
	exit 1
fi
umount "${MOUNTPOINT}" 2>/dev/null || true
mount UUID="${NEWUUID}" /tmp/newefi

# Copy files

echo "Copying Bootloader to new EFI partition."
cp -r /boot/efi/EFI /tmp/newefi
for folder in "/tmp/newefi/EFI/APPLE" \
              "/tmp/newefi/EFI/Microsoft"
do
	if [[ -d "$folder" ]]
	then
		rm -r "$folder"
	fi
done

# Remove Linux from old EFI

echo "Removing Bootloader from old EFI partition."
cd /boot/efi/EFI
shopt -s extglob
rm -r !("APPLE"|"Microsoft")
cd - > /dev/null
if [[ -f /boot/efi/EFI/Microsoft/Boot/bootmgfw.efi ]]
then
	echo "Windows installation detected. Restoring Windows Bootloader."
	mkdir /boot/efi/EFI/Boot
	cp /boot/efi/EFI/Microsoft/Boot/bootmgfw.efi /boot/efi/EFI/Boot/bootx64.efi
fi

# Update fstab

echo "Updating /etc/fstab."
sed -i "s/${OLDUUID}/${NEWUUID}/g" /etc/fstab

# Mount new EFI

echo "Mounting the new EFI partition."
umount /tmp/newefi
umount /boot/efi
rm -r /tmp/newefi
mount -a

echo "Success!"
