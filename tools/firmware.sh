#!/usr/bin/env bash

# Copyright (C) 2024 Aditya Garg <gargaditya08@live.com>
# Copyright (C) 2024 Orlando Chamberlain <redecorating@protonmail.com>
# Copyright (C) 2024 Sharpened Blade <sharpenedblade@proton.me>
#
# The python script is based upon the original work by The Asahi Linux Contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

rename_firmware () {
python3 - "$@" <<'EOF'
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
EOF
}

set -euo pipefail

verbose=""
subcmd=""
target_pkg_manager=""
args=()
interactive="true"
while getopts "ivhxp" option; do
	case $option in
		i) interactive="false" ;;
		v) verbose="-v" ;;
		h)
		cat <<- EOF
		usage: $0 [-vhx] subcommand [subcmd args]

		Subcommands:
		rename_only /path/to/firmware archive.tar
		copy_to_efi
		create_archive
		create_package apt|rpm|pacman
		get_from_efi
		get_from_macos
		get_from_online
		EOF
		exit 0 ;;
		x) set -x;;
		?) exit 1 ;; 
	esac
done

if [[ "${1-}" == -* ]]; then
	subcmd="${2-}"
	args=( "${@:3}" )
else
	subcmd="${1-}"
	args=( "${@:2}" )
fi

if [[ "$subcmd" = "" ]] && [[ "$interactive" = "true" ]]; then
	case "$(uname -s)" in
		(Darwin)
			echo "Detected macOS"
			cat <<- EOF

			How do you want to copy the firmware to Linux?

			1. Copy the firmware to the EFI partition and run the same script on Linux to retrieve it.
			2. Create a tarball of the firmware and extract it to Linux.
			3. Create a Linux specific package which can be installed using a package manager.

			Note: Option 2 and 3 require additional software like python3 and tools specific for your package manager. Requirements will be told as you proceed further.
			EOF
			read -r choice
			case ${choice} in
				(1) subcmd="copy_to_efi" ;;
				(2) subcmd="create_archive" ;;
				(3) subcmd="create_package"
					echo -e "\nWhat package manager does your Linux distribution use?\n"
					echo "1. apt"
					echo "2. dnf"
					echo "3. pacman"
					read -r target_pkg_manager
					case ${target_pkg_manager} in
						(1) target_pkg_manager="apt" ;;
						(2) target_pkg_manager="dnf" ;;
						(3) target_pkg_manager="pacman" ;;
						(*) echo -e "\nError: Invalid option!" && exit 1 ;;
					esac
					;;
				(*) echo -e "\nError: Invalid option!" && exit 1 ;;
				esac
			;;
		(Linux)
			echo "Detected Linux"
			cat <<- EOF

			How do you want to copy the firmware to Linux?

			1. Retrieve the firmware from the EFI partition.
			2. Retrieve the firmware directly from macOS.
			3. Download a macOS Recovery Image from Apple and extract the firmware from there.

			Note: If you are choosing Option 1, then make sure you have run the same script on macOS before and chose Option 1 (Copy the firmware to the EFI partition and run the same script on Linux to retrieve it) there.
			EOF
			read -r choice
			case ${choice} in
				(1)
					subcmd="get_from_efi" ;;
				(2)
					subcmd="get_from_macos" ;;
				(3)
					subcmd="get_from_online" ;;
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
fi

if [[ "$subcmd" = "" ]]; then
	echo "No subcommand specified"
	exit 1
elif [[ "$subcmd" = "create_package" ]] &&  [[ "$target_pkg_manager" = "" ]]; then
	target_pkg_manager="${args[0]}"
fi

aur_install() {
	local aur_package=$1
	local dir
	dir=$(mktemp -d)
	cd "$dir"
	sudo pacman -Sy --noconfirm git base-devel
	git clone "https://aur.archlinux.org/$aur_package.git" .
	makepkg -si --noconfirm
	cd - >/dev/null
	sudo rm -r ${verbose} "$dir"
}

log() {
	while read -r line; do
		if [ "${verbose}" = "-v" ]; then
			echo "$line"
		fi
		# TODO: Log to file
	done
}

err_msg() {
	local msg="$1"
	echo "$msg"
	if ! [[ "$verbose" = "-v" ]]; then
		echo "Run the script with -v to get logs."
	fi
}

detect_package_manager () {
	if [[ $(uname -s) = "Darwin" ]]
	then
		echo brew
	elif apt --help >/dev/null 2>&1
	then
		echo apt
	elif dnf >/dev/null 2>&1
	then
		echo dnf
	elif pacman -h >/dev/null 2>&1
	then
		echo pacman
	else
		echo NONE
	fi
}

install_package() {
	local package=$1
	local package_manager
	package_manager=$(detect_package_manager)
	if [[ "$interactive" = "false" ]]; then
		echo "$package is missing. Install it then try again"
		echo "Exiting"
		exit 1
	fi
	if [[ $package = "linux-apfs-rw" ]]
	then
		local apfs_driver_link=https://github.com/linux-apfs/linux-apfs-rw.git
		echo -e "\nAPFS driver is missing!\n"
		read -rp "Press enter to install the APFS driver via $package_manager. Alternatively you can terminate this script by pressing Control+C and install it yourself from $apfs_driver_link."
	else
		echo -e "\n$package and/or its dependencies are missing!\n"
		if [[ $package_manager = "brew" ]]
		then
			read -rp "Press enter to install $package and its dependencies via Homebrew. This script can install Homebrew automatically if you haven't installed it. Alternatively you can terminate this script by pressing Control+C and install $package yourself, if you want to install it via some alternate method."
		else
			read -rp "Press enter to install $package and its dependencies via $package_manager. Alternatively you can terminate this script by pressing Control+C and install $package yourself, if you want to install it via some alternate method."
		fi
	fi

	case $package_manager in
		"apt")
			case $package in
				"linux-apfs-rw")
					sudo apt update
					sudo apt install --reinstall -y apfs-dkms
					sudo modprobe ${verbose} apfs
					;;
				*)
					sudo apt update
					sudo apt install -y "$package" ;;
			esac ;;
		"dnf")
			case $package in
				"linux-apfs-rw")
					sudo dnf -y copr enable sharpenedblade/t2linux
					sudo dnf install -y linux-apfs-rw
					echo -e "\nRunning akmods\n"
					sudo akmods
					sudo modprobe ${verbose} apfs
					;;
				*)
					sudo dnf install -y "$package" ;;
			esac ;;
		"pacman")
			case $package in
				"linux-apfs-rw")
					aur_install linux-apfs-rw-dkms-git
					sudo modprobe ${verbose} apfs
					;;
				"dmg2img")
					aur_install dmg2img ;;
				*)
					sudo pacman -Sy --noconfirm "$package" ;;
			esac ;;
		"brew")
			if [ ! -f "/usr/local/bin/brew" ]; then
				echo -e "\nHomebrew not found!\n"
				read -rp "Press enter to install Homebrew."
				/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			fi
			case $package in
				"makepkg")
					brew install makepkg coreutils
					;;
				*)
					brew install "$package"
					;;
			esac ;;
		"NONE")
			read -rp "The script could not detect your package manager. Please install $package manually and press enter once you have it installed." ;;
	esac
}

create_firmware_archive() {
	local firmware_tree=$1
	local archive=$2
	rename_firmware "$firmware_tree" "$archive" ${verbose}
	if [[ $(uname -s) = "Darwin" ]]; then
		local identifier
		identifier=$(system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d ":" -f 2 | xargs)
		if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]; then
			nvram_txcap_quirk "$firmware_tree" "$archive"
		fi
	fi
}

python_check () {
	if [[ "$interactive" = "false" ]]; then
		echo "Xcode command line tools are missing."
		echo "Exiting"
		exit 1
	fi
	echo -e "\nChecking for missing dependencies"
	if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/python3" ] && [ ! -f "/Applications/Xcode.app/Contents/Developer/usr/bin/python3" ]
	then
		echo -e "\nPython 3 not found. You will be prompted to install Xcode command line developer tools."
		xcode-select --install
		echo
		read -rp "Press enter after you have installed Xcode command line developer tools."
	fi
}

reload_kernel_modules () {
	echo "Reloading Wi-Fi and Bluetooth drivers"
	sudo modprobe -r ${verbose} brcmfmac_wcc || true
	sudo modprobe -r ${verbose} brcmfmac || true
	sudo modprobe ${verbose} brcmfmac || true
	sudo modprobe -r ${verbose} hci_bcm4377 || true
	sudo modprobe ${verbose} hci_bcm4377 || true
}

create_deb () {
	if [ ! -f "/usr/local/bin/dpkg" ]
	then
		install_package dpkg
	fi

	echo -e "\nBuilding deb package"
	local workarea
	workarea=$(mktemp -d)
	create_firmware_archive /usr/share/firmware "${workarea}/firmware.tar"
	cd "${workarea}"
	mkdir -p deb
	cd deb
	mkdir -p DEBIAN
	mkdir -p usr/lib/firmware/brcm
	cd usr/lib/firmware/brcm
	tar -xf "${workarea}/firmware.tar" ${verbose}
	cd - >/dev/null

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

	cd "${workarea}"
	dpkg-deb --build --root-owner-group -Zgzip deb | log || err_msg "Failed to make deb package."
	dpkg-name deb.deb | log

	cp ${verbose} "apple-firmware_${ver}-1_all.deb" "$HOME/Downloads"
	echo -e "\nCleaning up"
	rm -r ${verbose} "${workarea}"

	cat <<- EOF

	Deb package apple-firmware_${ver}-1_all.deb has been saved to Downloads!
	Copy it to Linux and install it by running the following in a Linux terminal:

	sudo apt install /path/to/apple-firmware_${ver}-1_all.deb
	EOF
}

create_rpm () {
	if [ ! -f "/usr/local/bin/rpmbuild" ]
	then
		 install_package rpm
	fi

	echo -e "\nBuilding rpm package"
	mkdir -p "$HOME/rpmbuild/"{BUILD,RPMS,SOURCES,SPECS,SRPMS}

	# Extract firmware 
	create_firmware_archive /usr/share/firmware "$HOME/rpmbuild/SOURCES/firmware.tar"
	cd "$HOME/rpmbuild/BUILD"

	# Create the spec file
	cat <<- EOF > "$HOME/rpmbuild/SPECS/apple-firmware.spec"
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
		install -m 644 brcm* %{buildroot}/usr/lib/firmware/brcm/

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
	rpmbuild -bb --target noarch-linux "$HOME/rpmbuild/SPECS/apple-firmware.spec" 2>&1 | log || err_msg "Failed to make rpm package."

	# Copy and Cleanup
	cp ${verbose} "$HOME/rpmbuild/RPMS/noarch/apple-firmware-${ver}-1.noarch.rpm" "$HOME/Downloads"
	echo -e "\nCleaning up"
	rm -r ${verbose} "$HOME/rpmbuild"

	cat <<- EOF

	Rpm package apple-firmware-${ver}-1.noarch.rpm has been saved to Downloads!
	Copy it to Linux and install it by running the following in a Linux terminal:

	sudo dnf install --disablerepo=* /path/to/apple-firmware-${ver}-1.noarch.rpm
	EOF
}

create_arch_pkg () {
	if [ ! -f "/usr/local/bin/makepkg" ] || [ ! -f "/usr/local/bin/sha256sum" ]
	then
		install_package makepkg
	fi

	echo -e "\nBuilding pacman package"
	local workarea
	workarea=$(mktemp -d)
	create_firmware_archive /usr/share/firmware "${workarea}/firmware.tar"
	cd "${workarea}"

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
	PATH=/usr/local/Cellar/libarchive/$(echo /usr/local/Cellar/libarchive/* | xargs basename)/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH_OLD

	# Build
	PKGEXT='.pkg.tar.zst' makepkg 2>&1 | log || err_msg "Failed to make pacman package."

	# Revert path to its original form
	PATH=${PATH_OLD}

	# Copy to Downloads and cleanup
	cp ${verbose} "apple-firmware-${ver}-1-any.pkg.tar.zst" "$HOME/Downloads"
	echo -e "\nCleaning up"
	rm -r ${verbose} "${workarea}"

	cat <<-EOF

	Pacman package apple-firmware-${ver}-1-any.pkg.tar.zst has been saved to Downloads!
	Copy it to Linux and install it by running the following in a Linux terminal:

	sudo pacman -U /path/to/apple-firmware-${ver}-1-any.pkg.tar.zst
	EOF
}


# MacOS only
nvram_txcap_quirk() {
	local firmware_tree="$1"
	local output_tar="$2"
	local nvramfile
	local txcapblob
	nvramfile=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 5 | rev | cut -c 4- | rev)
	txcapblob=$(ioreg -l | grep RequestedFiles | cut -d "/" -f 3 | cut -d "\"" -f 1)
	cp ${verbose} "${firmware_tree}/wifi/C-4364__s-B2/${nvramfile}" brcmfmac4364b2-pcie.txt
	cp ${verbose} "${firmware_tree}/wifi/C-4364__s-B2/${txcapblob}" brcmfmac4364b2-pcie.txcap_blob
	tar --append ${verbose} -f "$output_tar" \
		brcmfmac4364b2-pcie.txt brcmfmac4364b2-pcie.txcap_blob
	rm ${verbose} brcmfmac4364b2-pcie.txt brcmfmac4364b2-pcie.txcap_blob
}

os=$(uname -s)
case "$os" in
	(Darwin)
		ver=$(sw_vers -productVersion)
		ver_check=$(sw_vers -productVersion | cut -d "." -f 1)
		identifier=$(system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d ":" -f 2 | xargs)
		if [[ ${ver_check} -lt 12 ]] && [[ (${identifier} = MacBookPro15,4) || (${identifier} = MacBookPro16,3) || (${identifier} = MacBookAir9,1) ]]
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
		case ${subcmd} in
			("copy_to_efi")
				echo -e "\nMounting the EFI partition"
				EFILABEL=$(diskutil info disk0s1 | grep "Volume Name" | cut -d ":" -f 2 | xargs)
				sudo diskutil mount disk0s1
				echo "Getting Wi-Fi and Bluetooth firmware"
				tar ${verbose} -cf "/Volumes/${EFILABEL}/firmware-raw.tar" -C /usr/share/firmware/ .
				if [[ (${identifier} = iMac19,1) || (${identifier} = iMac19,2) || (${identifier} = iMacPro1,1) ]]; then
					nvram_txcap_quirk "/usr/share/firmware" "/Volumes/${EFILABEL}/firmware-raw.tar"
				fi
				gzip ${verbose} --best "/Volumes/${EFILABEL}/firmware-raw.tar"
				echo "Copying this script to EFI"
				cp "$0" "/Volumes/${EFILABEL}/firmware.sh" 2>/dev/null \
					|| curl -s https://wiki.t2linux.org/tools/firmware.sh > "/Volumes/${EFILABEL}/firmware.sh" \
					|| ( echo && cat <<- EOF && [ "$interactive" = "true" ] && echo "Press enter after you have copied" && read -r
						Failed to copy script.
						Please copy the script manually to the EFI partition using Finder
						Make sure the name of the script is firmware.sh in the EFI partition
						EOF
						)
				sudo diskutil unmount "/Volumes/${EFILABEL}/"
				cat <<- EOF

				Run the following commands or run this script itself in Linux now to set up Wi-Fi:

				sudo mkdir -p /tmp/apple-wifi-efi
				sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
				bash /tmp/apple-wifi-efi/firmware.sh
				sudo umount /tmp/apple-wifi-efi
				EOF
				;;
			("create_archive")
				python_check
				echo -e "\nCreating a tarball of the firmware"
				create_firmware_archive /usr/share/firmware "$HOME/Downloads/firmware.tar"
				cat <<- EOF

				Firmware tarball saved to Downloads!

				Extract the tarball contents to /lib/firmware/brcm in Linux and run the following in the Linux terminal:

				sudo modprobe -r brcmfmac_wcc
				sudo modprobe -r brcmfmac
				sudo modprobe brcmfmac
				sudo modprobe -r hci_bcm4377
				sudo modprobe hci_bcm4377
				EOF
				;;
			("create_package")
				python_check
				case ${target_pkg_manager} in
					("apt")
						create_deb
						;;
					("dnf")
						create_rpm
						;;
					("pacman")
						create_arch_pkg
						;;
					(*)
						echo -e "\nError: Invalid option!"
						exit 1
						;;
					esac
				;;
			("rename_only")
				rename_firmware "${args[@]}" ${verbose}
				;;
			(*)
				echo -e "\nError: Invalid option!"
				exit 1
				;;
			esac
		;;

	(Linux)
		if [[ ! -e /lib/firmware/brcm ]]; then
			cat <<- EOF
			/lib/firmware/brcm does not seem to exist. This script requires that directory to function.
			If you are on some exotic distro like NixOS, please check the wiki for more information:
			  https://wiki.t2linux.org
			Exiting...
			EOF
			exit 1
		fi
		case ${subcmd} in
			("get_from_efi")
				echo -e "\nRe-mounting the EFI partition"
				mountpoint=$(mktemp -d)
				workdir=$(mktemp -d)
				echo "Installing Wi-Fi and Bluetooth firmware"
				sudo mount ${verbose} /dev/nvme0n1p1 "$mountpoint"
				sudo tar --warning=no-unknown-keyword ${verbose} -xC "${workdir}" -f "$mountpoint/firmware-raw.tar.gz"
				sudo chown -R "$USER" "${workdir}"
				create_firmware_archive "${workdir}" "${workdir}/firmware-renamed.tar"

				sudo tar ${verbose} -xC /lib/firmware/brcm -f "${workdir}/firmware-renamed.tar"

				for file in "$workdir/brcmfmac4364b2-pcie.txt" \
					"$workdir/brcmfmac4364b2-pcie.txcap_blob"
				do
					if [ -f "$file" ]; then
						sudo cp ${verbose} "$file" /lib/firmware/brcm
					fi
				done
				reload_kernel_modules
				echo -e "\nKeeping a copy of the firmware and the script in the EFI partition shall allow you to set up Wi-Fi again in the future by running this script or the commands told in the macOS step in Linux only, without the macOS step."
				if [ "$interactive" = "true" ]; then
					read -rp "Do you want to keep a copy? (y/N)" input
				else
					input="y"
				fi
				if [[ ($input != y) && ($input != Y) ]]
				then
					echo -e "\nRemoving the copy from the EFI partition"
					for file in "$mountpoint/firmware-raw.tar.gz" \
					            "$mountpoint/firmware.sh"
					do
						if [ -f "$file" ]
						then
							sudo rm ${verbose} "$file"
						fi
					done
				fi
				sudo rm -r ${verbose} "${workdir}"
				sudo umount ${verbose} "$mountpoint"
				sudo rmdir ${verbose} "$mountpoint"
				echo -e "\nDone!"
				;;
			("get_from_macos")
				echo -e "\nChecking for missing dependencies"
				# Load the apfs driver, and install if missing
				sudo modprobe ${verbose} apfs 2>/dev/null || install_package linux-apfs-rw
				unmount_macos_and_cleanup () {
					sudo rm -r ${verbose} "${workdir}" || true
					for i in 0 1 2 3 4 5
					do
						sudo umount ${verbose} "${macosdir}/vol${i}" 2>&1 | log || true
					done
					sudo rm -r ${verbose} "${macosdir}" || true
				}

				echo -e "\nMounting the macOS volume"
				workdir=$(mktemp -d)
				macosdir=$(mktemp -d)
				macosvol=/dev/$(lsblk -o NAME,FSTYPE | grep nvme0n1 | grep apfs | head -1 | awk '{print $1}' | rev | cut -c -9 | rev)
				fwlocation=""
				for i in 0 1 2 3 4 5
				do
					mkdir -p "${macosdir}/vol${i}"
					if [[ ${verbose} = "-v" ]]
					then
						sudo mount -v -o vol=${i} "${macosvol}" "${macosdir}/vol${i}" || true
					else
						sudo mount -o vol=${i} "${macosvol}" "${macosdir}/vol${i}" 2>/dev/null || true
					fi
					
					if [ -d "${macosdir}/vol${i}/usr/share/firmware" ]
					then
						fwlocation="${macosdir}/vol${i}/usr/share/firmware"
					fi
				done
				echo "Getting firmware"
				if [[ ${fwlocation} = "" ]]
				then
					echo -e "Could not find location of firmware. Aborting!"
					unmount_macos_and_cleanup
					exit 1
				fi
				create_firmware_archive "${fwlocation}" "${workdir}/firmware-renamed.tar" || (echo -e "\nCouldn't extract firmware. Try running the script again. If error still persists, try restarting your Mac and then run the script again, or choose some other method." && unmount_macos_and_cleanup && exit 1)
				sudo tar ${verbose} -xC /lib/firmware/brcm -f "${workdir}/firmware-renamed.tar"
				reload_kernel_modules
				echo "Cleaning up"
				unmount_macos_and_cleanup
				echo "Done!"
				;;
			("get_from_online")
				# Detect whether curl and dmg2img are installed
				echo -e "\nChecking for missing dependencies"
				curl --version >/dev/null 2>&1 || install_package curl
				dmg2img >/dev/null 2>&1 || install_package dmg2img
				cleanup_dmg () {
					sudo rm -r ${verbose} "${workdir}"
					sudo umount ${verbose} "${loopdev_partition}"
					sudo rm -r ${verbose} "${imgdir}"
					sudo losetup -d /dev/"${loopdev}"
				}

				echo -e "\nDownloading macOS Recovery Image"
				workdir=$(mktemp -d "$HOME/tmp.XXXXXX")
				imgdir=$(mktemp -d)
				cd "${workdir}"
				if [[ ${verbose} = "-v" ]]
				then
					curl -O https://raw.githubusercontent.com/kholia/OSX-KVM/master/fetch-macOS-v2.py
				else
					curl -s -O https://raw.githubusercontent.com/kholia/OSX-KVM/master/fetch-macOS-v2.py
				fi
				echo -e "\nNote: In order to get complete firmware files, download macOS Monterey, Ventura or Sonoma.\n"
				python3 fetch-macOS-v2.py
				echo -e "\nConverting image from .dmg to .img"
				if [[ ${verbose} = "-v" ]]
				then
					dmg2img -v BaseSystem.dmg fw.img
				else
					dmg2img -s BaseSystem.dmg fw.img
				fi
				echo "Mounting image"
				loopdev=$(losetup -f | cut -d "/" -f 3)
				sudo losetup -P "${loopdev}" fw.img
				loopdev_partition=/dev/$(lsblk -o KNAME,TYPE,MOUNTPOINT -n | grep "${loopdev}" | tail -1 | awk '{print $1}')
				sudo mount ${verbose} "${loopdev_partition}" "${imgdir}"
				echo "Getting firmware"
				cd - >/dev/null
				create_firmware_archive "${imgdir}/usr/share/firmware" "${workdir}/firmware-renamed.tar" || (echo -e "\nCouldn't extract firmware. Try choosing some other macOS version (should be Monterey or later). If error still persists, try restarting your Mac and then run the script again." && cleanup_dmg && exit 1)
				sudo tar ${verbose} -xC /lib/firmware/brcm -f "${workdir}/firmware-renamed.tar"
				reload_kernel_modules
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


