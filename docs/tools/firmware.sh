#!/usr/bin/env bash
#
# Copyright (C) 2022 Aditya Garg <gargaditya08@live.com>
# Copyright (C) 2022 Orlando Chamberlain <redecorating@protonmail.com>
#
# The python script is based upon the original work by The Asahi Linux Contributors.

""":"
set -euo pipefail

verbose=""
while getopts "vhx" option; do
	case $option in
		v) verbose="-v" ;;
		h) echo "usage: $0 [-vhx]"; exit 0 ;;
		x) set -x;;
		?) exit 1 ;; 
	esac
done

python_check () {
	if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/python3" ] && [ ! -f "/Applications/Xcode.app/Contents/Developer/usr/bin/python3" ]
	then
		echo -e "\nPython 3 not found. You will be prompted to install Xcode command line developer tools."
		xcode-select --install
		echo
		read -p "Press enter after you have installed Xcode command line developer tools."
	fi
}

homebrew_check () {
	if [ ! -f "/usr/local/bin/brew" ]
	then
		echo -e "\nHomebrew not found!"
		echo
		read -p "Press enter to install Homebrew."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
}

create_deb () {
	if [ ! -f "/usr/local/bin/dpkg" ]
	then
		echo -e "\ndpkg and/or its dependencies are missing!"
		echo
		read -p "Press enter to install dpkg and its dependencies via Homebrew. This script can install Homebrew automatically if you haven't installed it. Alternatively you can terminate this script by pressing Control+C and install dpkg yourself, if you want to install it via some alternate method."
		homebrew_check
		echo -e "\nInstalling dpkg and its dependencies"
		brew install dpkg
	fi

	echo -e "\nBuilding deb package"
	workarea=$(mktemp -d)
	python3 "$0" /usr/share/firmware ${workarea}/firmware.tar
	cd ${workarea}
	mkdir -p deb
	cd deb
	mkdir -p DEBIAN
	mkdir -p usr/lib/firmware/brcm
	cd usr/lib/firmware/brcm
	tar -xf ${workarea}/firmware.tar ${verbose}
	cd - >/dev/null

	if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]
	then
		nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
		txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${nvramfile} "usr/lib/firmware/brcm/brcmfmac4364b2-pcie.txt"
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${txcapblob} "usr/lib/firmware/brcm/brcmfmac4364b2-pcie.txcap_blob"
	fi

	cat <<- EOF > DEBIAN/control
		Package: apple-firmware
		Version: ${ver}-1
		Maintainer: Apple
		Architecture: all
		Description: Wi-Fi and Bluetooth firmware for T2 Macs
	EOF

	cat <<- EOF > DEBIAN/postinst
		modprobe -r brcmfmac_wcc || true
		modprobe -r brcmfmac || true
		modprobe brcmfmac || true
		modprobe -r hci_bcm4377 || true
		modprobe hci_bcm4377 || true
	EOF

	chmod a+x DEBIAN/control
	chmod a+x DEBIAN/postinst

	cd ${workarea}
	if [[ ${verbose} = -v ]]
	then
		dpkg-deb --build --root-owner-group -Zgzip deb
		dpkg-name deb.deb
	else
		dpkg-deb --build --root-owner-group -Zgzip deb >/dev/null || echo "Failed to make deb package. Run the script with -v to get logs."
		dpkg-name deb.deb >/dev/null
	fi

	cp ${verbose} apple-firmware_${ver}-1_all.deb $HOME/Downloads
	echo -e "\nCleaning up"
	rm -r ${verbose} ${workarea}

	echo -e "\nDeb package apple-firmware_${ver}-1_all.deb has been saved to Downloads!"
	echo "Copy it to Linux and install it by running the following in the Linux terminal:"
	echo -e "\nsudo apt install /path/to/apple-firmware_${ver}-1_all.deb"
}

create_rpm () {
	if [ ! -f "/usr/local/bin/rpmbuild" ]
	then
		echo -e "\nrpm and/or its dependencies are missing!"
		echo
		read -p "Press enter to install rpm and its dependencies via Homebrew. This script can install Homebrew automatically if you haven't installed it. Alternatively you can terminate this script by pressing Control+C and install rpm yourself, if you want to install it via some alternate method."
		homebrew_check
		echo -e "\nInstalling rpm and its dependencies"
		brew install rpm
	fi

	echo -e "\nBuilding rpm package"
	mkdir -p $HOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

	# Extract firmware 
	python3 "$0" /usr/share/firmware $HOME/rpmbuild/SOURCES/firmware.tar
	cd $HOME/rpmbuild/BUILD

	if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]
	then
		nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
		txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${nvramfile} brcmfmac4364b2-pcie.txt
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${txcapblob} brcmfmac4364b2-pcie.txcap_blob
		tar --append ${verbose} -f $HOME/rpmbuild/SOURCES/firmware.tar brcmfmac4364b2-pcie.txt
		tar --append ${verbose} -f $HOME/rpmbuild/SOURCES/firmware.tar brcmfmac4364b2-pcie.txcap_blob
		rm brcmfmac4364b2-pcie.txcap_blob brcmfmac4364b2-pcie.txt
	fi

	# Create the spec file
	cat <<- EOF > $HOME/rpmbuild/SPECS/apple-firmware.spec
		Name:       apple-firmware
		Version:    ${ver}
		Release:    1
		Summary:    Wi-Fi and Bluetooth firmware for T2 Macs
		License:    Proprietary
		BuildArch:  noarch

		Source1: firmware.tar

		%description
		Wi-Fi and Bluetooth firmware for T2 Macs

		%prep
		tar -xf %{SOURCE1}

		%build

		%install
		mkdir -p %{buildroot}/usr/lib/firmware/brcm
		install -m 644 * %{buildroot}/usr/lib/firmware/brcm

		%posttrans
		modprobe -r brcmfmac_wcc || true
		modprobe -r brcmfmac || true
		modprobe brcmfmac || true
		modprobe -r hci_bcm4377 || true
		modprobe hci_bcm4377 || true

		%files
		/usr/lib/firmware/brcm/*
	EOF

	# Build
	if [[ ${verbose} = -v ]]
	then
		rpmbuild -bb --define '_target_os linux' $HOME/rpmbuild/SPECS/apple-firmware.spec
	else
		rpmbuild -bb --define '_target_os linux' $HOME/rpmbuild/SPECS/apple-firmware.spec >/dev/null 2>&1 || echo "Failed to make rpm package. Run the script with -v to get logs."
	fi

	# Copy and Cleanup
	cp ${verbose} $HOME/rpmbuild/RPMS/noarch/apple-firmware-${ver}-1.noarch.rpm $HOME/Downloads
	echo -e "\nCleaning up"
	rm -r ${verbose} $HOME/rpmbuild

	echo -e "\nRpm package apple-firmware-${ver}-1.noarch.rpm has been saved to Downloads!"
	echo "Copy it to Linux and install it by running the following in the Linux terminal:"
	echo -e "\nsudo dnf install --disablerepo=* /path/to/apple-firmware-${ver}-1.noarch.rpm"
}

create_arch_pkg () {
	if [ ! -f "/usr/local/bin/makepkg" ] || [ ! -f "/usr/local/bin/sha256sum" ]
	then
		echo -e "\nmakepkg and/or its dependencies are missing!"
		echo
		read -p "Press enter to install makepkg and its dependencies via Homebrew. This script can install Homebrew automatically if you haven't installed it. Alternatively you can terminate this script by pressing Control+C and install makepkg yourself, if you want to install it via some alternate method."
		homebrew_check
		echo -e "\nInstalling makepkg and its dependencies"
		brew install makepkg coreutils
	fi

	echo -e "\nBuilding pacman package"
	workarea=$(mktemp -d)
	python3 "$0" /usr/share/firmware ${workarea}/firmware.tar
	cd ${workarea}
	if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]
	then
		nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
		txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${nvramfile} "${workarea}/brcmfmac4364b2-pcie.txt"
		cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${txcapblob} "${workarea}/brcmfmac4364b2-pcie.txcap_blob"
		tar --append ${verbose} -f firmware.tar brcmfmac4364b2-pcie.txt
		tar --append ${verbose} -f firmware.tar brcmfmac4364b2-pcie.txcap_blob
		rm ${verbose} brcmfmac4364b2-pcie.txt
		rm ${verbose} brcmfmac4364b2-pcie.txcap_blob
	fi

	# Create the PKGBUILD
	cat <<- EOF > PKGBUILD
		pkgname=apple-firmware
		pkgver=${ver}
		pkgrel=1
		pkgdesc="Wi-Fi and Bluetooth Firmware for T2 Macs"
		arch=("any")
		url=""
		license=('unknown')
		replaces=('apple-bcm-wifi-firmware')
		source=("firmware.tar")
		noextract=("firmware.tar")
		sha256sums=('SKIP')
	EOF
	cat <<- 'EOF' >> PKGBUILD

		package() {
			mkdir -p $pkgdir/usr/lib/firmware/brcm
			cd $pkgdir/usr/lib/firmware/brcm
			tar xf $srcdir/firmware.tar
		}

		install=apple-firmware.install
	EOF

	cat <<- EOF > apple-firmware.install
		post_install() {
			modprobe -r brcmfmac_wcc || true
			modprobe -r brcmfmac || true
			modprobe brcmfmac || true
			modprobe -r hci_bcm4377 || true
			modprobe hci_bcm4377 || true
		}
	EOF

	# Set path to use newer bsdtar and GNU touch
	PATH_OLD=$PATH
	PATH=/usr/local/Cellar/libarchive/$(ls /usr/local/Cellar/libarchive | head -n 1)/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH_OLD

	# Build
	if [[ ${verbose} = -v ]]
	then
		PKGEXT='.pkg.tar.zst' makepkg
	else
		PKGEXT='.pkg.tar.zst' makepkg >/dev/null 2>&1 || echo "Failed to make pacman package. Run the script with -v to get logs."
	fi

	# Revert path to its original form
	PATH=${PATH_OLD}

	# Copy to Downloads and cleanup
	cp ${verbose} apple-firmware-${ver}-1-any.pkg.tar.zst $HOME/Downloads
	echo -e "\nCleaning up"
	rm -r ${verbose} ${workarea}

	echo -e "\nPacman package apple-firmware-${ver}-1-any.pkg.tar.zst has been saved to Downloads!"
	echo "Copy it to Linux and install it by running the following in the Linux terminal:"
	echo -e "\nsudo pacman -U /path/to/apple-firmware-${ver}-1-any.pkg.tar.zst"
}

detect_package_manager () {
	if $(apt --help >/dev/null 2>&1)
	then
		PACKAGE_MANAGER=apt
	elif $(dnf >/dev/null 2>&1)
	then
		PACKAGE_MANAGER=dnf
	elif $(pacman -h >/dev/null 2>&1)
	then
		PACKAGE_MANAGER=pacman
	else
		PACKAGE_MANAGER=NONE
		echo -e "\nUnable to detect the package manager your distro is using!"
	fi
}

curl_check () {
	if ! $(curl --help >/dev/null 2>&1)
	then
		echo -e "\ncurl and/or its dependencies are missing!"
		detect_package_manager
		echo
		if [[ ${PACKAGE_MANAGER} = "NONE" ]]
		then
			read -p "The script could not detect your package manager. Please install curl manually and press enter once you have it installed."
		else
			read -p "Press enter to install curl and its dependencies via ${PACKAGE_MANAGER}. Alternatively you can terminate this script by pressing Control+C and install curl yourself, if you want to install it via some alternate method."
			echo -e "\nInstalling curl and its dependencies"
			case ${PACKAGE_MANAGER} in
				(apt)
					sudo apt update
					sudo apt install -y curl
					;;
				(dnf)
					sudo dnf install -y curl
					;;
				(pacman)
					sudo pacman -Sy --noconfirm curl
					;;
				(*)
					echo -e "\nUnknown error"
					exit 1
					;;
			esac
					
		fi
	fi
}

dmg2img_check () {
	if ! $(dmg2img >/dev/null 2>&1)
	then
		echo -e "\ndmg2img and/or its dependencies are missing!"
		detect_package_manager
		echo
		if [[ ${PACKAGE_MANAGER} = "NONE" ]]
		then
			read -p "The script could not detect your package manager. Please install dmg2img manually and press enter once you have it installed."
		else
			read -p "Press enter to install dmg2img and its dependencies via ${PACKAGE_MANAGER}. Alternatively you can terminate this script by pressing Control+C and install dmg2img yourself, if you want to install it via some alternate method."
			echo -e "\nInstalling dmg2img and its dependencies"
			case ${PACKAGE_MANAGER} in
				(apt)
					sudo apt update
					sudo apt install -y dmg2img
					;;
				(dnf)
					sudo dnf install -y dmg2img
					;;
				(pacman)
					dmg2imgdir=$(mktemp -d)
					cd ${dmg2imgdir}
					sudo pacman -Sy --noconfirm git base-devel
					git clone https://aur.archlinux.org/dmg2img.git ${dmg2imgdir}
					makepkg -si --noconfirm
					cd - >/dev/null
					sudo rm -r ${verbose} ${dmg2imgdir}
					;;
				(*)
					echo -e "\nUnknown error"
					exit 1
					;;
			esac
					
		fi
	fi
}

apfs_install () {
	echo -e "\nAPFS driver missing!"
	detect_package_manager
	echo
	apfs_driver_link=https://github.com/linux-apfs/linux-apfs-rw.git
	if [[ ${PACKAGE_MANAGER} = "NONE" ]]
	then
		read -p "The script could not detect your package manager. Please install the APFS driver manually from ${apfs_driver_link} and press enter once you have it installed."
	else
		read -p "Press enter to install the APFS driver via ${PACKAGE_MANAGER}. Alternatively you can terminate this script by pressing Control+C and install it yourself from ${apfs_driver_link}."
		echo -e "\nInstalling the APFS driver"
		case ${PACKAGE_MANAGER} in
			(apt)
				sudo apt update
				sudo apt install --reinstall -y apfs-dkms
				;;
			(dnf)
				sudo dnf -y copr enable sharpenedblade/t2linux
				sudo dnf install -y linux-apfs-rw
				echo -e "\nRunning akmods\n"
				sudo akmods
				;;
			(pacman)
				apfsdir=$(mktemp -d)
				cd ${apfsdir}
				sudo pacman -Sy --noconfirm git base-devel
				git clone https://aur.archlinux.org/linux-apfs-rw-dkms-git.git ${apfsdir}
				makepkg -si --noconfirm
				cd - >/dev/null
				sudo rm -r ${verbose} ${apfsdir}
				;;
			(*)
				echo -e "\nUnknown error"
				exit 1
				;;
		esac				
	fi
	sudo modprobe ${verbose} apfs && echo -e "\nAPFS driver loaded successfully!" || (echo -e "\nAPFS driver could not be loaded. Make sure you have the kernel headers installed. If you are still facing the issue, try again after restarting your Mac, or use some other method to get the firmware" && exit 1)
}

os=$(uname -s)
case "$os" in
	(Darwin)
		echo "Detected macOS"
		ver=$(sw_vers -productVersion)
		ver_check=$(sw_vers -productVersion | cut -d "." -f 1)
		identifier=$(system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d ":" -f 2 | xargs)
		if [[ ${ver_check} < 12 ]] && [[ (${identifier} = MacBookPro15,4) || (${identifier} = MacBookPro16,3) || (${identifier} = MacBookAir9,1) ]]
		then
			cat <<- EOF

			Warning: You are running a macOS version earlier than macOS Monterey.
			Your Mac model needs Bluetooth firmware for in addition to Wi-Fi firmware, which is available only on macOS Monterey or later.
			Only Wi-Fi firmware shall be copied to Linux.
			For Bluetooth firmware, you can either:

			a) Upgrade macOS to Monterey or later.
			b) Run this script directly in Linux and choose the option to Download a macOS Recovery Image from there.

			EOF
		fi
		echo -e "\nHow do you want to copy the firmware to Linux?"
		echo -e "\n1. Copy the firmware to the EFI partition and run the same script on Linux to retrieve it."
		echo "2. Create a tarball of the firmware and extract it to Linux."
		echo "3. Create a Linux specific package which can be installed using a package manager."
		echo -e "\nNote: Option 2 and 3 require additional software like python3 and tools specific for your package manager. Requirements will be told as you proceed further."
		read choice
		case ${choice} in
			(1)
				echo -e "\nMounting the EFI partition"
				EFILABEL=$(diskutil info disk0s1 | grep "Volume Name" | cut -d ":" -f 2 | xargs)
				sudo diskutil mount disk0s1
				echo "Getting Wi-Fi and Bluetooth firmware"
				tar ${verbose} -cf "/Volumes/${EFILABEL}/firmware.tar" -C /usr/share/firmware/ .
				gzip ${verbose} --best "/Volumes/${EFILABEL}/firmware.tar"
				if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]
		then
					nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
					txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
					cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${nvramfile} "/Volumes/${EFILABEL}/brcmfmac4364b2-pcie.txt"
					cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${txcapblob} "/Volumes/${EFILABEL}/brcmfmac4364b2-pcie.txcap_blob"
				fi
				echo "Copying this script to EFI"
				cp "$0" "/Volumes/${EFILABEL}/firmware.sh" 2>/dev/null || curl -s https://wiki.t2linux.org/tools/firmware.sh > "/Volumes/${EFILABEL}/firmware.sh" || (echo -e "\nFailed to copy script.\nPlease copy the script manually to the EFI partition using Finder\nMake sure the name of the script is firmware.sh in the EFI partition\n" && echo && read -p "Press enter after you have copied" && echo)
				echo "Unmounting the EFI partition"
				sudo diskutil unmount "/Volumes/${EFILABEL}/"
				echo
				echo -e "Run the following commands or run this script itself in Linux now to set up Wi-Fi :-\n\nsudo mkdir -p /tmp/apple-wifi-efi\nsudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi\nbash /tmp/apple-wifi-efi/firmware.sh\nsudo umount /tmp/apple-wifi-efi\n"
				;;
			(2)

				echo -e "\nChecking for missing dependencies"
				python_check
				echo -e "\nCreating a tarball of the firmware"
				python3 "$0" /usr/share/firmware $HOME/Downloads/firmware.tar ${verbose}
				if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]
		then
					nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
					txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
					cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${nvramfile} "$HOME/Downloads/brcmfmac4364b2-pcie.txt"
					cp ${verbose} /usr/share/firmware/wifi/C-4364__s-B2/${txcapblob} "$HOME/Downloads/brcmfmac4364b2-pcie.txcap_blob"
					cd $HOME/Downloads
					tar --append ${verbose} -f firmware.tar brcmfmac4364b2-pcie.txt
					tar --append ${verbose} -f firmware.tar brcmfmac4364b2-pcie.txcap_blob
					rm ${verbose} brcmfmac4364b2-pcie.txt
					rm ${verbose} brcmfmac4364b2-pcie.txcap_blob
					cd - >/dev/null
				fi
				echo -e "\nFirmware tarball saved to Downloads!"
				echo -e "\nExtract the tarball contents to /lib/firmware/brcm in Linux and run the following in the Linux terminal:"
				echo -e "\nsudo modprobe -r brcmfmac_wcc"
				echo "sudo modprobe -r brcmfmac"
				echo "sudo modprobe brcmfmac"
				echo "sudo modprobe -r hci_bcm4377"
				echo "sudo modprobe hci_bcm4377"
				;;
			(3)
				echo -e "\nWhat package manager does your Linux distribution use?"
				echo -e "\n1. apt"
				echo "2. dnf"
				echo "3. pacman"
				read package
				case ${package} in
					(1)
						echo -e "\nChecking for missing dependencies"
						python_check
						create_deb
						;;
					(2)
						echo -e "\nChecking for missing dependencies"
						python_check
						create_rpm
						;;
					(3)
						echo -e "\nChecking for missing dependencies"
						python_check
						create_arch_pkg
						;;
					(*)
						echo -e "\nError: Invalid option!"
						exit 1
						;;
					esac
				;;
			(*)
				echo -e "\nError: Invalid option!"
				exit 1
				;;
			esac
		;;

	(Linux)
		echo "Detected Linux"
		if [[ ! -e /lib/firmware/brcm ]]; then
			echo "/lib/firmware/brcm does not seem to exist. This script requires that directory to function."
			echo "If you are on some exotic distro like NixOS, please check the wiki for more information:"
			echo "  https://wiki.t2linux.org"
			echo "Exiting..."
			exit 1
		fi
		echo -e "\nHow do you want to copy the firmware to Linux?"
		echo -e "\n1. Retrieve the firmware from the EFI partition."
		echo "2. Retrieve the firmware directly from macOS."
		echo "3. Download a macOS Recovery Image from Apple and extract the firmware from there."
		echo -e "\nNote: If you are choosing Option 1, then make sure you have run the same script on macOS before and chose Option 1 (Copy the firmware to the EFI partition and run the same script on Linux to retrieve it) there."
		read choice
		case ${choice} in
			(1)
				echo -e "\nRe-mounting the EFI partition"
				mountpoint=$(mktemp -d)
				workdir=$(mktemp -d)
				echo "Installing Wi-Fi and Bluetooth firmware"
				sudo mount ${verbose} /dev/nvme0n1p1 $mountpoint
				sudo tar --warning=no-unknown-keyword ${verbose} -xC ${workdir} -f $mountpoint/firmware.tar.gz
				sudo python3 "$0" ${workdir} ${workdir}/firmware-renamed.tar ${verbose}

				sudo tar ${verbose} -xC /lib/firmware/brcm -f ${workdir}/firmware-renamed.tar

				for file in "$mountpoint/brcmfmac4364b2-pcie.txt" \
					    "$mountpoint/brcmfmac4364b2-pcie.txcap_blob"
				do
					if [ -f "$file" ]
					then
						sudo cp ${verbose} $file /lib/firmware/brcm
					fi
				done
				echo "Reloading Wi-Fi and Bluetooth drivers"
				sudo modprobe -r ${verbose} brcmfmac_wcc || true
				sudo modprobe -r ${verbose} brcmfmac || true
				sudo modprobe ${verbose} brcmfmac || true
				sudo modprobe -r ${verbose} hci_bcm4377 || true
				sudo modprobe ${verbose} hci_bcm4377 || true
				echo -e "\nKeeping a copy of the firmware and the script in the EFI partition shall allow you to set up Wi-Fi again in the future by running this script or the commands told in the macOS step in Linux only, without the macOS step."
				read -p "Do you want to keep a copy? (y/N)" input
				if [[ ($input != y) && ($input != Y) ]]
				then
					echo -e "\nRemoving the copy from the EFI partition"
					for file in "$mountpoint/brcmfmac4364b2-pcie.txt" \
					            "$mountpoint/brcmfmac4364b2-pcie.txcap_blob" \
					            "$mountpoint/firmware.tar.gz" \
					            "$mountpoint/firmware.sh"
					do
						if [ -f "$file" ]
						then
							sudo rm ${verbose} $file
						fi
					done
				fi
				sudo rm -r ${verbose} ${workdir}
				sudo umount $mountpoint
				sudo rmdir $mountpoint
				echo -e "\nDone!"
				;;
			(2)
				echo -e "\nChecking for missing dependencies"
				# Load the apfs driver, and install if missing
				sudo modprobe ${verbose} apfs 2>/dev/null || apfs_install
				unmount_macos_and_cleanup () {
					sudo rm -r ${verbose} ${workdir} || true
					for i in 0 1 2 3 4 5
					do
						if [[ ${verbose} = -v ]]
						then
							sudo umount -v ${macosdir}/vol${i} || true
						else
							sudo umount ${macosdir}/vol${i} 2>/dev/null || true
						fi
					done
					sudo rm -r ${verbose} ${macosdir} || true
				}

				echo -e "\nMounting the macOS volume"
				workdir=$(mktemp -d)
				macosdir=$(mktemp -d)
				macosvol=/dev/$(lsblk -o NAME,FSTYPE | grep nvme0n1 | grep apfs | head -1 | awk '{print $1'} | rev | cut -c -9 | rev)
				fwlocation=""
				for i in 0 1 2 3 4 5
				do
					mkdir -p ${macosdir}/vol${i}
					if [[ ${verbose} = -v ]]
					then
						sudo mount -v -o vol=${i} ${macosvol} ${macosdir}/vol${i} || true
					else
						sudo mount -o vol=${i} ${macosvol} ${macosdir}/vol${i} 2>/dev/null || true
					fi
					
					if [ -d "${macosdir}/vol${i}/usr/share/firmware" ]
					then
						fwlocation=${macosdir}/vol${i}/usr/share/firmware
					fi
				done
				echo "Getting firmware"
				if [[ ${fwlocation} = "" ]]
				then
					echo -e "Could not find location of firmware. Aborting!"
					unmount_macos_and_cleanup
					exit 1
				fi
				python3 "$0" ${fwlocation} ${workdir}/firmware-renamed.tar ${verbose} || (echo -e "\nCouldn't extract firmware. Try running the script again. If error still persists, try restarting your Mac and then run the script again, or choose some other method." && unmount_macos_and_cleanup && exit 1)
				sudo tar ${verbose} -xC /lib/firmware/brcm -f ${workdir}/firmware-renamed.tar
				echo "Reloading Wi-Fi and Bluetooth drivers"
				sudo modprobe -r ${verbose} brcmfmac_wcc || true
				sudo modprobe -r ${verbose} brcmfmac || true
				sudo modprobe ${verbose} brcmfmac || true
				sudo modprobe -r ${verbose} hci_bcm4377 || true
				sudo modprobe ${verbose} hci_bcm4377 || true
				echo "Cleaning up"
				unmount_macos_and_cleanup
				echo "Done!"
				;;
			(3)
				# Detect whether curl and dmg2img are installed
				echo -e "\nChecking for missing dependencies"
				curl_check
				dmg2img_check
				cleanup_dmg () {
					sudo rm -r ${verbose} ${workdir}
					sudo umount ${verbose} ${loopdevice}
					sudo rm -r ${verbose} ${imgdir}
					sudo losetup -d /dev/${loopdev}
				}

				echo -e "\nDownloading macOS Recovery Image"
				workdir=$(mktemp -d)
				imgdir=$(mktemp -d)
				cd ${workdir}
				if [[ ${verbose} = -v ]]
				then
					curl -O https://raw.githubusercontent.com/kholia/OSX-KVM/master/fetch-macOS-v2.py
				else
					curl -s -O https://raw.githubusercontent.com/kholia/OSX-KVM/master/fetch-macOS-v2.py
				fi
				echo -e "\nNote: In order to get complete firmware files, download macOS Monterey or later.\n"
				python3 fetch-macOS-v2.py
				echo -e "\nConverting image from .dmg to .img"
				if [[ ${verbose} = -v ]]
				then
					dmg2img -v BaseSystem.dmg fw.img
				else
					dmg2img -s BaseSystem.dmg fw.img
				fi
				echo "Mounting image"
				loopdev=$(losetup -f | cut -d "/" -f 3)
				sudo losetup -P ${loopdev} fw.img
				loopdevice=/dev/$(lsblk -o KNAME,TYPE,MOUNTPOINT -n | grep ${loopdev} | tail -1 | awk '{print $1}')
				sudo mount ${verbose} ${loopdevice} ${imgdir}
				echo "Getting firmware"
				cd - >/dev/null
				python3 "$0" ${imgdir}/usr/share/firmware ${workdir}/firmware-renamed.tar ${verbose} || (echo -e "\nCouldn't extract firmware. Try choosing some other macOS version (should be Monterey or later). If error still persists, try restarting your Mac and then run the script again." && cleanup_dmg && exit 1)
				sudo tar ${verbose} -xC /lib/firmware/brcm -f ${workdir}/firmware-renamed.tar
				echo "Reloading Wi-Fi and Bluetooth drivers"
				sudo modprobe -r ${verbose} brcmfmac_wcc || true
				sudo modprobe -r ${verbose} brcmfmac || true
				sudo modprobe ${verbose} brcmfmac || true
				sudo modprobe -r ${verbose} hci_bcm4377 || true
				sudo modprobe ${verbose} hci_bcm4377 || true
				echo "Cleaning up"
				cleanup_dmg
				echo "Done!"
				;;
			(*)
				echo -e "\nError: Invalid option!"
				exit 1
				;;
		esac
		;;
	(*)
		echo "Error: unsupported platform"
		;;
esac
exit 0
"""

# SPDX-License-Identifier: MIT
import logging, os, os.path, re, sys, pprint, statistics, tarfile, io
from collections import namedtuple, defaultdict
from hashlib import sha256
from pathlib import Path

log = logging.getLogger("asahi_firmware.bluetooth")

BluetoothChip = namedtuple(
	"BluetoothChip", ("chip", "stepping", "board_type", "vendor")
)


class BluetoothFWCollection(object):
	VENDORMAP = {
		"MUR": "m",
		"USI": "u",
		"GEN": None,
	}
	STRIP_SUFFIXES = [
		"ES2"
	]

	def __init__(self, source_path):
		self.fwfiles = defaultdict(lambda: [None, None])
		self.load(source_path)

	def load(self, source_path):
		for fname in os.listdir(source_path):
			root, ext = os.path.splitext(fname)

			# index for bin and ptb inside self.fwfiles
			if ext == ".bin":
				idx = 0
			elif ext == ".ptb":
				idx = 1
			else:
				# skip firmware for older (UART) chips
				continue

			# skip T2 _DEV firmware
			if "_DEV" in root:
				continue

			chip = self.parse_fname(root)
			if chip is None:
				continue

			if self.fwfiles[chip][idx] is not None:
				log.warning(f"duplicate entry for {chip}: {self.fwfiles[chip][idx].name} and now {fname + ext}")
				continue

			path = os.path.join(source_path, fname)
			with open(path, "rb") as f:
				data = f.read()

			self.fwfiles[chip][idx] = FWFile(fname, data)

	def parse_fname(self, fname):
		fname = fname.split("_")

		match = re.fullmatch("bcm(43[0-9]{2})([a-z][0-9])", fname[0].lower())
		if not match:
			log.warning(f"Unexpected firmware file: {fname}")
			return None
		chip, stepping = match.groups()

		# board type is either preceeded by PCIE_macOS or by PCIE
		try:
			pcie_offset = fname.index("PCIE")
		except:
			log.warning(f"Can't find board type in {fname}")
			return None

		if fname[pcie_offset + 1] == "macOS":
			board_type = fname[pcie_offset + 2]
		else:
			board_type = fname[pcie_offset + 1]
		for i in self.STRIP_SUFFIXES:
			board_type = board_type.rstrip(i)
		board_type = "apple," + board_type.lower()

		# make sure we can identify exactly one vendor
		otp_values = set()
		for vendor, otp_value in self.VENDORMAP.items():
			if vendor in fname:
				otp_values.add(otp_value)
		if len(otp_values) != 1:
			log.warning(f"Unable to determine vendor ({otp_values}) in {fname}")
			return None
		vendor = otp_values.pop()

		return BluetoothChip(
			chip=chip, stepping=stepping, board_type=board_type, vendor=vendor
		)

	def files(self):
		for chip, (bin, ptb) in self.fwfiles.items():
			fname_base = f"brcmbt{chip.chip}{chip.stepping}-{chip.board_type}"
			if chip.vendor is not None:
				fname_base += f"-{chip.vendor}"

			if bin is None:
				log.warning(f"no bin for {chip}")
				continue
			else:
				yield fname_base + ".bin", bin

			if ptb is None:
				log.warning(f"no ptb for {chip}")
				continue
			else:
				yield fname_base + ".ptb", ptb

log = logging.getLogger("asahi_firmware.wifi")

class FWNode(object):
	def __init__(self, this=None, leaves=None):
		if leaves is None:
			leaves = {}
		self.this = this
		self.leaves = leaves

	def __eq__(self, other):
		return self.this == other.this and self.leaves == other.leaves

	def __hash__(self):
		return hash((self.this, tuple(self.leaves.items())))

	def __repr__(self):
		return f"FWNode({self.this!r}, {self.leaves!r})"

	def print(self, depth=0, tag=""):
		print(f"{'  ' * depth} * {tag}: {self.this or ''} ({hash(self)})")
		for k, v in self.leaves.items():
			v.print(depth + 1, k)

class WiFiFWCollection(object):
	EXTMAP = {
		"trx": "bin",
		"txt": "txt",
		"clmb": "clm_blob",
		"txcb": "txcap_blob",
	}
	DIMS = ["C", "s", "P", "M", "V", "m", "A"]
	def __init__(self, source_path):
		self.root = FWNode()
		self.load(source_path)
		self.prune()

	def load(self, source_path):
		included_folders = ["C-4355__s-C1", "C-4364__s-B2", "C-4364__s-B3", "C-4377__s-B3"]
		for dirpath, dirnames, filenames in os.walk(source_path):
			dirnames[:] = [d for d in dirnames if d in included_folders]
			if "perf" in dirnames:
				dirnames.remove("perf")
			if "assert" in dirnames:
				dirnames.remove("assert")
			subpath = os.path.relpath(dirpath, source_path)
			for name in sorted(filenames):
				if not any(name.endswith("." + i) for i in self.EXTMAP):
					continue
				path = os.path.join(dirpath, name)
				relpath = os.path.join(subpath, name)
				if not name.endswith(".txt"):
					name = "P-" + name
				idpath, ext = os.path.join(subpath, name).rsplit(".", 1)
				props = {}
				for i in idpath.replace("/", "_").split("_"):
					if not i:
						continue
					k, v = i.split("-", 1)
					if k == "P" and "-" in v:
						plat, ant = v.split("-", 1)
						props["P"] = plat
						props["A"] = ant
					else:
						props[k] = v
				ident = [ext]
				for dim in self.DIMS:
					if dim in props:
						ident.append(props.pop(dim))

				if props:
					log.error(f"Unhandled properties found: {props} in file {relpath}")

				assert not props

				node = self.root
				for k in ident:
					node = node.leaves.setdefault(k, FWNode())
				with open(path, "rb") as fd:
					data = fd.read()

				if name.endswith(".txt"):
					data = self.process_nvram(data)

				node.this = FWFile(relpath, data)

	def prune(self, node=None, depth=0):
		if node is None:
			node = self.root

		for i in node.leaves.values():
			self.prune(i, depth + 1)

		if node.this is None and node.leaves and depth > 3:
			first = next(iter(node.leaves.values()))
			if all(i == first for i in node.leaves.values()):
				node.this = first.this

		for i in node.leaves.values():
			if not i.this or not node.this:
				break
			if i.this != node.this:
				break
		else:
			node.leaves = {}

	def _walk_files(self, node, ident):
		if node.this is not None:
			yield ident, node.this
		for k, subnode in node.leaves.items():
			yield from self._walk_files(subnode, ident + [k])

	def files(self):
		for ident, fwfile in self._walk_files(self.root, []):
			(ext, chip, rev), rest = ident[:3], ident[3:]
			rev = rev.lower()
			ext = self.EXTMAP[ext]

			if rest:
				rest = "," + "-".join(rest)
			else:
				rest = ""
			filename = f"brcmfmac{chip}{rev}-pcie.apple{rest}.{ext}"

			yield filename, fwfile

	def process_nvram(self, data):
		data = data.decode("ascii")
		keys = {}
		lines = []
		for line in data.split("\n"):
			if not line:
				continue
			key, value = line.split("=", 1)
			keys[key] = value
			# Clean up spurious whitespace that Linux does not like
			lines.append(f"{key.strip()}={value}\n")

		return "".join(lines).encode("ascii")

	def print(self):
		self.root.print()

class FWFile(object):
	def __init__(self, name, data):
		self.name = name
		self.data = data
		self.sha = sha256(data).hexdigest()

	def __repr__(self):
		return f"FWFile({self.name!r}, <{self.sha[:16]}>)"

	def __eq__(self, other):
		if other is None:
			return False
		return self.sha == other.sha

	def __hash__(self):
		return hash(self.sha)

class FWPackage(object):
	def __init__(self, target):
		self.path = target
		self.tarfile = tarfile.open(target, mode="w")
		self.hashes = {}
		self.manifest = []

	def close(self):
		self.tarfile.close()

	def add_file(self, name, data):
		ti = tarfile.TarInfo(name)
		fd = None
		if data.sha in self.hashes:
			ti.type = tarfile.LNKTYPE
			ti.linkname = self.hashes[data.sha]
			self.manifest.append(f"LINK {name} {ti.linkname}")
		else:
			ti.type = tarfile.REGTYPE
			ti.size = len(data.data)
			fd = io.BytesIO(data.data)
			self.hashes[data.sha] = name
			self.manifest.append(f"FILE {name} SHA256 {data.sha}")

		logging.info(f"+ {self.manifest[-1]}")
		self.tarfile.addfile(ti, fd)

	def add_files(self, it):
		for name, data in it:
			self.add_file(name, data)

	def save_manifest(self, filename):
		with open(filename, "w") as fd:
			for i in self.manifest:
				fd.write(i + "\n")

	def __del__(self):
		self.tarfile.close()

logging.getLogger().setLevel(logging.WARNING if (len(sys.argv) >= 4 and sys.argv[3] == "-v") else logging.ERROR)

pkg = FWPackage(sys.argv[2])
wifi_col = WiFiFWCollection(sys.argv[1]+"/wifi")
pkg.add_files(sorted(wifi_col.files()))
if not Path(sys.argv[1] + "/bluetooth").exists():
	log.warning("\nBluetooth firmware missing.\n\nThe source of the firmware is likely macOS Big Sur or earlier. Therefore, only Wi-Fi firmware shall be extracted.\nBluetooth firmware is needed only for MacBookPro15,4, MacBookPro16,3 and MacBookAir9,1. So, you can ignore this message if you do not have these Macs.\n")
else:
	bt_col = BluetoothFWCollection(sys.argv[1]+"/bluetooth")
	pkg.add_files(sorted(bt_col.files()))
pkg.close()

