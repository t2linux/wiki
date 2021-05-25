# Kernel

This page explains how to compile or install linux-mbp-arch kernel and headers on non arch based distros. If you you are on an arch based distro, refer to [this section](#arch-based-systems-pacman). You may want to put this files into a package, so that you can manage the kernel files with your package manager. There is [some guidance](#packaging-the-kernel) about this, but the process is differs between package managers. If you have issues, make sure you are running the commands here with `bash`.

Before begining, set the directory that you want to install to.

If you want to install the kernel with a package manager:

```bash
pkgdir=$PWD/pkg
mkdir pkg
```

If you want to install to your current system directly (the kernel will not be managed by your package manager):

```bash
pkgdir=/
```

## Compile

To compile a kernel with the patches in [linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch), run the following commands. You will need your distro's equivalent of these arch packages `bc kmod libelf pahole cpio perl tar xz` respectively `build-essential libncurses-dev libssl-dev flex bison` on ubuntu.

```bash
git clone https://github.com/aunali1/linux-mbp-arch
cd linux-mbp-arch
source PKGBUILD
wget https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.xz
tar -xf $_srcname.tar.xz
prepare
make all -jX # change "X" to the number of cpu threads you have.
cd ..
_package # use sudo if installing directly
cd ..
_package-headers # use sudo if installing directly
```

## Extract linux-mbp-arch binary without compiling

You may need to change the version on the first line if linux-mbp-arch has been updated. This all needs to be run with `sudo` if you are installing directly.

```bash
VER=5.11.22-1
cd $pkgdir
wget https://dl.t2linux.org/archlinux/mbp/x86_64/linux-mbp-$VER-x86_64.pkg.tar.zst
wget https://dl.t2linux.org/archlinux/mbp/x86_64/linux-mbp-headers-$VER-x86_64.pkg.tar.zst
tar -xf linux-mbp-headers-$VER-x86_64.pkg.tar.zst
tar -xf linux-mbp-$VER-x86_64.pkg.tar.zst
rm .MTREE .PKGINFO .BUILDINFO linux-mbp-$VER-x86_64.pkg.tar.zst linux-mbp-headers-$VER-x86_64.pkg.tar.zst
```

## Packaging the kernel

The process for this will depend on which package manager your distro uses. If you installed directly to your filesystem, don't do this.

### Debian based systems (apt)

```
cd $pkgdir
mkdir DEBIAN
cat << EOF > DEBIAN/control
Package: linux-mbp
Version: $pkgver
Architecture: amd64
EOF
dpkg -b . linux-mbp.deb
sudo apt install linux-mbp.deb
```

### Arch based systems (pacman)

You do not need to follow the other instructions on this page.

To compile:

```bash
git clone https://github.com/aunali1/linux-mbp-arch
cd linux-mbp-arch
makepkg -si
```

To install the binary, first make sure you have added aunali1's repo to `/etc/pacman.conf`. To do this, follow steps 6d-e and 8 from the [arch install guide](https://wiki.t2linux.org/distributions/arch/installation/). Then `sudo pacman -S linux-mbp linux-mbp-headers`
