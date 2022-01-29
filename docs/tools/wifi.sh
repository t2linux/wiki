#!/usr/bin/env bash
#
# Copyright (C) 2022 Aditya Garg <gargaditya08@live.com>
#

set -euo pipefail

os=$(uname -s);
script_name=$(echo $0 | rev | cut -d'/' -f 1 | rev)
case "$os" in
	(Darwin)
		echo "Detected macOS"
		echo "Mounting the EFI partition"
		sudo diskutil mount disk0s1
		echo "Getting Wi-Fi firmware"
		cd /usr/share/firmware
		tar czf /Volumes/EFI/wifi.tar.gz wifi/*
		echo "Getting Asahi's script"
		curl -L https://github.com/AsahiLinux/asahi-installer/archive/refs/heads/main.tar.gz > /Volumes/EFI/asahi-installer-main.tar.gz
		echo "Copying this script to EFI"
		cd -
		cp "$0" "/Volumes/EFI/wifi.sh"|| (echo -e "\nFailed to copy script.\nPlease copy the script manually to the EFI partition using Finder\nMake sure the name of the script is wifi.sh in the EFI partition\n" && echo && read -p "Press enter after you have copied" && echo)
		echo "Unmounting the EFI partition"
		sudo diskutil unmount disk0s1
		echo
		echo -e "Run the following commands or run this script itself in Linux now to set up Wi-Fi :-\n\nsudo umount /dev/nvme0n1p1\nsudo mkdir /tmp/apple-wifi-efi\nsudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi\nbash /tmp/apple-wifi-efi/wifi.sh\n"
		;;
	(Linux)
		echo "Detected Linux"
		echo "Re-mounting the EFI partition"
		sudo umount /dev/nvme0n1p1 || echo
		sudo mkdir /tmp/apple-wifi-efi || echo
		sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi || echo
		mountpoint=$(findmnt -n -o TARGET /dev/nvme0n1p1)
		echo "Getting WiFi firmware"
		sudo mkdir /tmp/apple-wifi-fw
		cd /tmp/apple-wifi-fw
		sudo tar xf $mountpoint/wifi.tar.gz
		echo "Getting Asahi's script"
		sudo tar xf $mountpoint/asahi-installer-main.tar.gz
		echo "Setting up WiFi"
		cd asahi-installer-main/src
		sudo python3 -m firmware.wifi /tmp/apple-wifi-fw/wifi firmware.tar
		cd /lib/firmware
		sudo tar xvf /tmp/apple-wifi-fw/asahi-installer-main/src/firmware.tar
		sudo modprobe -r brcmfmac
		sudo modprobe brcmfmac
		echo "Cleaning up"
		sudo rm -r /tmp/apple-wifi-fw
		echo "Keeping a copy of the firmware and the script in the EFI partition shall allow you to set up Wi-Fi again in the future by running this script or the commands told in the macOS step in Linux only, without the macOS step. Do you want to keep a copy? (y/n)"
		read input
		if [[ ($input != y) && ($input != Y) ]]
		then
			echo "Removing the copy from the EFI partition"
			sudo rm $mountpoint/wifi.tar.gz $mountpoint/asahi-installer-main.tar.gz $mountpoint/wifi.sh
		fi
		echo "Running post-installation scripts"
		exec sudo sh -c "umount /dev/nvme0n1p1 && mount -a && rmdir /tmp/apple-wifi-efi && echo Done!"
		;;
	(*)
		echo "Error: unsupported platform"
		;;
esac
