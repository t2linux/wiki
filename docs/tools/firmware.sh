#!/usr/bin/env bash
#
# Copyright (C) 2022 Aditya Garg <gargaditya08@live.com>

set -euo pipefail

os=$(uname -s)

case "$os" in
	(Darwin)
		echo "Detected macOS"
		echo "Mounting the EFI partition"
		sudo diskutil mount disk0s1

		echo "Copying this script to EFI"
		cp "$0" "/Volumes/EFI/firmware.sh"|| (echo -e "\nFailed to copy script.\nPlease copy the script manually to the EFI partition using Finder\nMake sure the name of the script is firmware.sh in the EFI partition\n" && echo && read -p "Press enter after you have copied" && echo)

		echo "Getting Wi-Fi and Bluetooth firmware"

		mkdir /Volumes/EFI/firmware

		#4355c1
		cd /usr/share/firmware/wifi/C-4355__s-C1
		for ISLAND in hawaii
		do

		if [[ ${1-default} = -v ]]
		then
		cp -v $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.bin
		cp -v $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.clm_blob
		cp -v $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.txcap_blob
		else
		cp $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.bin
		cp $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.clm_blob
		cp $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND.txcap_blob
		fi

		NVRAM_NUMBER=$(ls /usr/share/firmware/wifi/c-4355__s-C1 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | wc -l | xargs)
			for ((LINE=1;LINE<=$NVRAM_NUMBER;++LINE))
			do
			NVRAM=$(ls /usr/share/firmware/wifi/c-4355__s-C1 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE")
			VENDOR=$(ls /usr/share/firmware/wifi/c-4355__s-C1 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 2)
			VERSION=$(ls /usr/share/firmware/wifi/c-4355__s-C1 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 7-9)
			if [[ ${1-default} = -v ]]
			then
			cp -v $NVRAM /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND-YSBC-$VENDOR-$VERSION.txt
			else
			cp $NVRAM /Volumes/EFI/firmware/brcmfmac4355c1-pcie.apple,$ISLAND-YSBC-$VENDOR-$VERSION.txt
			fi
			done
		done

		#4364b2
		cd /usr/share/firmware/wifi/C-4364__s-B2
		for ISLAND in ekans hanauma kahana kauai lanai maui midway nihau sid
		do

		if [[ ${1-default} = -v ]]
		then
		cp -v $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.bin
		cp -v $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.clm_blob
		cp -v $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.txcap_blob
		else
		cp $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.bin
		cp $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.clm_blob
		cp $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND.txcap_blob
		fi

		NVRAM_NUMBER=$(ls /usr/share/firmware/wifi/c-4364__s-B2 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | wc -l | xargs)
			for ((LINE=1;LINE<=$NVRAM_NUMBER;++LINE))
			do
			NVRAM=$(ls /usr/share/firmware/wifi/c-4364__s-B2 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE")
			VENDOR=$(ls /usr/share/firmware/wifi/c-4364__s-B2 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 2)
			VERSION=$(ls /usr/share/firmware/wifi/c-4364__s-B2 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 7-9)
			if [[ ${1-default} = -v ]]
			then
			cp -v $NVRAM /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND-HRPN-$VENDOR-$VERSION.txt
			else
			cp $NVRAM /Volumes/EFI/firmware/brcmfmac4364b2-pcie.apple,$ISLAND-HRPN-$VENDOR-$VERSION.txt
			fi
			done
		done

		#4364b3
		cd /usr/share/firmware/wifi/C-4364__s-B3
		for ISLAND in bali borneo hanauma kahana kure sid trinidad
		do

		if [[ ${1-default} = -v ]]
		then
		cp -v $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.bin
		cp -v $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.clm_blob
		cp -v $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.txcap_blob
		else
		cp $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.bin
		cp $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.clm_blob
		cp $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND.txcap_blob
		fi

		NVRAM_NUMBER=$(ls /usr/share/firmware/wifi/c-4364__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | wc -l | xargs)
			for ((LINE=1;LINE<=$NVRAM_NUMBER;++LINE))
			do
			NVRAM=$(ls /usr/share/firmware/wifi/c-4364__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE")
			VENDOR=$(ls /usr/share/firmware/wifi/c-4364__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 2)
			VERSION=$(ls /usr/share/firmware/wifi/c-4364__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 7-9)
			if [[ ${1-default} = -v ]]
			then
			cp -v $NVRAM /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND-HRPN-$VENDOR-$VERSION.txt
			else
			cp $NVRAM /Volumes/EFI/firmware/brcmfmac4364b3-pcie.apple,$ISLAND-HRPN-$VENDOR-$VERSION.txt
			fi
			done

		done

		#4377b3
		cd /usr/share/firmware/wifi/C-4377__s-B3
		for ISLAND in fiji formosa tahiti
		do

		if [[ ${1-default} = -v ]]
		then
		cp -v $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.bin
		cp -v $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.clm_blob
		cp -v $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.txcap_blob
		else
		cp $ISLAND.trx /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.bin
		cp $ISLAND.clmb /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.clm_blob
		cp $ISLAND.txcb /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND.txcap_blob
		fi

		NVRAM_NUMBER=$(ls /usr/share/firmware/wifi/c-4377__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | wc -l | xargs)
			for ((LINE=1;LINE<=$NVRAM_NUMBER;++LINE))
			do
			NVRAM=$(ls /usr/share/firmware/wifi/c-4377__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE")
			VENDOR=$(ls /usr/share/firmware/wifi/c-4377__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 2)
			VERSION=$(ls /usr/share/firmware/wifi/c-4377__s-B3 | grep $ISLAND | grep txt | grep -v -E 'ID|X0|X2|X3' | awk "NR==$LINE" | cut -d "V" -f 2 | cut -c 7-9)
			if [[ ${1-default} = -v ]]
			then
			cp -v $NVRAM /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND-SPPR-$VENDOR-$VERSION.txt
			else
			cp $NVRAM /Volumes/EFI/firmware/brcmfmac4377b3-pcie.apple,$ISLAND-SPPR-$VENDOR-$VERSION.txt
			fi
			done
		done

		#4377 Bluetooth
		cd /usr/share/firmware/bluetooth
		if [[ ${1-default} = -v ]]
		then
		cp -v BCM4377B3__PCIE_Formosa_MFG_GEN__PRODK_R_.ptb /Volumes/EFI/firmware/brcmbt4377b3-apple,formosa.ptb
		cp -v BCM4377B3*_PROD.signed.bin /Volumes/EFI/firmware/brcmbt4377b3-apple,formosa.bin
		else
		cp BCM4377B3__PCIE_Formosa_MFG_GEN__PRODK_R_.ptb /Volumes/EFI/firmware/brcmbt4377b3-apple,formosa.ptb
		cp BCM4377B3*_PROD.signed.bin /Volumes/EFI/firmware/brcmbt4377b3-apple,formosa.bin
		fi

		echo "Unmounting the EFI partition"
		sudo diskutil unmount disk0s1
		echo
		echo -e "Run the following commands or run this script itself in Linux now to set up Wi-Fi :-\n\nsudo umount /dev/nvme0n1p1\nsudo mkdir /tmp/apple-wifi-efi\nsudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi\nbash /tmp/apple-wifi-efi/firmware.sh\n"
		;;
	(Linux)
		echo "Detected Linux"
		echo "Re-mounting the EFI partition"
		if [[ ${1-default} = -v ]]
		then
			sudo umount -v /dev/nvme0n1p1 || true
			sudo mkdir -v /tmp/apple-wifi-efi || true
			sudo mount -v /dev/nvme0n1p1 /tmp/apple-wifi-efi || true
		else
			sudo umount /dev/nvme0n1p1 2>/dev/null || true
			sudo mkdir /tmp/apple-wifi-efi 2>/dev/null || true
			sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi 2>/dev/null || true
		fi
		mountpoint=$(findmnt -n -o TARGET /dev/nvme0n1p1)
		echo "Getting WiFi and Bluetooth firmware"
		if [[ ${1-default} = -v ]]
		then
			sudo cp -v $mountpoint/firmware/* /lib/firmware/brcm
		else
			sudo cp $mountpoint/firmware/* /lib/firmware/brcm
		fi
		sudo modprobe -r brcmfmac
		sudo modprobe brcmfmac
		sudo modprobe -r hci_bcm4377
		sudo modprobe hci_bcm4377
		echo "Cleaning up"
		echo "Keeping a copy of the firmware and the script in the EFI partition shall allow you to set up Wi-Fi and Bluetooth again in the future by running this script or the commands told in the macOS step in Linux only, without the macOS step. Do you want to keep a copy? (y/N)"
		read input
		if [[ ($input != y) && ($input != Y) ]]
		then
			echo "Removing the copy from the EFI partition"
			sudo rm -r $mountpoint/firmware $mountpoint/firmware.sh
		fi
		echo "Running post-installation scripts"
		exec sudo sh -c "umount /dev/nvme0n1p1 && mount -a && rmdir /tmp/apple-wifi-efi && echo Done!"
		;;
	(*)
		echo "Error: unsupported platform"
		;;
esac
