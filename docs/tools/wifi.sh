#!/usr/bin/env bash
#
# Copyright (C) 2022 Aditya Garg <gargaditya08@live.com>
#
# The python script is based upon the original work by The Asahi Linux Contributors.

""":"
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
		if [[ ${1-default} = -v ]]
		then
			tar czvf /Volumes/EFI/wifi.tar.gz wifi/*
		else
			tar czf /Volumes/EFI/wifi.tar.gz wifi/*
		fi
		echo "Copying this script to EFI"
		cd - >/dev/null
		cp "$0" "/Volumes/EFI/wifi.sh"|| (echo -e "\nFailed to copy script.\nPlease copy the script manually to the EFI partition using Finder\nMake sure the name of the script is wifi.sh in the EFI partition\n" && echo && read -p "Press enter after you have copied" && echo)
		echo "Unmounting the EFI partition"
		sudo diskutil unmount disk0s1
		echo
		echo -e "Run the following commands or run this script itself in Linux now to set up Wi-Fi :-\n\nsudo umount /dev/nvme0n1p1\nsudo mkdir /tmp/apple-wifi-efi\nsudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi\nbash /tmp/apple-wifi-efi/wifi.sh\n"
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
		echo "Getting WiFi firmware"
		sudo mkdir /tmp/apple-wifi-fw
		cd /tmp/apple-wifi-fw
		if [[ ${1-default} = -v ]]
		then
			sudo tar xvf $mountpoint/wifi.tar.gz
		else
			sudo tar xf $mountpoint/wifi.tar.gz 2>/dev/null
		fi
		echo "Setting up WiFi"
		if [[ ${1-default} = -v ]]
		then
			sudo python3 $mountpoint/wifi.sh /tmp/apple-wifi-fw/wifi firmware.tar
		else
			sudo python3 $mountpoint/wifi.sh /tmp/apple-wifi-fw/wifi firmware.tar >/dev/null
		fi
		cd /lib/firmware
		if [[ ${1-default} = -v ]]
		then
			sudo tar xvf /tmp/apple-wifi-fw/firmware.tar
		else
			sudo tar xf /tmp/apple-wifi-fw/firmware.tar
		fi
		sudo modprobe -r brcmfmac
		sudo modprobe brcmfmac
		echo "Cleaning up"
		sudo rm -r /tmp/apple-wifi-fw
		echo "Keeping a copy of the firmware and the script in the EFI partition shall allow you to set up Wi-Fi again in the future by running this script or the commands told in the macOS step in Linux only, without the macOS step. Do you want to keep a copy? (y/N)"
		read input
		if [[ ($input != y) && ($input != Y) ]]
		then
			echo "Removing the copy from the EFI partition"
			sudo rm $mountpoint/wifi.tar.gz $mountpoint/wifi.sh
		fi
		echo "Running post-installation scripts"
		exec sudo sh -c "umount /dev/nvme0n1p1 && mount -a && rmdir /tmp/apple-wifi-efi && echo Done!"
		;;
	(*)
		echo "Error: unsupported platform"
		;;
esac
exit 0
"""

# SPDX-License-Identifier: MIT
import tarfile, io, os
from hashlib import sha256

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
        self.tarfile = tarfile.open(target, mode="w")
        self.hashes = {}
        self.manifest = []

    def close(self):
        self.tarfile.close()

    def add_file(self, name, data):
        ti = tarfile.TarInfo(name)
        fd = None
        if data.sha in self.hashes:
            ti.type = tarfile.SYMTYPE
            ti.linkname = os.path.relpath(self.hashes[data.sha], os.path.dirname(name))
            self.manifest.append(f"LINK {name} {ti.linkname}")
        else:
            ti.type = tarfile.REGTYPE
            ti.size = len(data.data)
            fd = io.BytesIO(data.data)
            self.hashes[data.sha] = name
            self.manifest.append(f"FILE {name} SHA256 {data.sha}")

        self.tarfile.addfile(ti, fd)

    def add_files(self, it):
        for name, data in it:
            self.add_file(name, data)

    def __del__(self):
        self.tarfile.close()

import sys, os, os.path, pprint, statistics

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
        for dirpath, dirnames, filenames in os.walk(source_path):
            if "perf" in dirnames:
                dirnames.remove("perf")
            subpath = dirpath.lstrip(source_path)
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
            filename = f"brcm/brcmfmac{chip}{rev}-pcie.apple{rest}.{ext}"

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

if __name__ == "__main__":
    col = WiFiFWCollection(sys.argv[1])
    if len(sys.argv) > 2:

        pkg = FWPackage(sys.argv[2])
        pkg.add_files(sorted(col.files()))
        pkg.close()

        for i in pkg.manifest:
            print(i)
    else:
        for name, fwfile in col.files():
            if isinstance(fwfile, str):
                print(name, "->", fwfile)
            else:
                print(name, f"({len(fwfile.data)} bytes)")
