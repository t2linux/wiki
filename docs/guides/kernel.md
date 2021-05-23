# Kernel

This page explains how to compile the linux-mbp-arch kernel on any distro, and also how to extract the compiled kernel and other files from the linux-mbp arch linux package, allowing you to install them manually without having to compile it (which can take a few hours). You may want to put this files into package, so that you can manage the kernel files with your package manager. There is [some guidance](#packaging-the-kernel) about this.

## Compile

To compile a kernel with the patches in [linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch), run the following commands. You will need your distro's equivalent of these arch packages: `bc kmod libelf pahole cpio perl tar xz`

```bash
git clone https://github.com/aunali1/linux-mbp-arch
cd linux-mbp-arch
source PKGBUILD
wget https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.xz
tar -xf $_srcname.tar.xz
prepare
make all -jX # change "X" to the number of cpu threads you have.
cd ..
sudo _package
cd ..
sudo _package-headers
```

## Install linux-mbp-arch binary on other distros without compiling

You may need to change the version on the first line, if linux-mbp-arch has been updated.

```bash
VER=5.11.22-1
cd /
sudo wget https://dl.t2linux.org/archlinux/mbp/x86_64/linux-mbp-$VER-x86_64.pkg.tar.zst
sudo wget https://dl.t2linux.org/archlinux/mbp/x86_64/linux-mbp-headers-$VER-x86_64.pkg.tar.zst
sudo tar -xf linux-mbp-headers-$VER-x86_64.pkg.tar.zst
sudo tar -xf linux-mbp-$VER-x86_64.pkg.tar.zst
rm .MTREE .PKGINFO .BUILDINFO linux-mbp-$VER-x86_64.pkg.tar.zst linux-mbp-headers-$VER-x86_64.pkg.tar.zst
```

## Packaging the kernel

You probably want to be able to install and uninstall linux-mbp with your package manager. To do so, you won't install the kernel to `/`. Instead, we will put it in `./pkg`. You can omit `sudo` from all commands except for when you install the package with your package manager.

### Building the kernel a custom directory

Before running the commands in [Compile](#compile), set the `pkgdir` environment variable:

```bash
pkgdir=$PWD/pkg
mkdir pkg
```

You can then run the commands in [Compile](#compile) and it will be installed to that folder.

### Extracting the linux-mbp-arch package to a custom directory

Follow [the commands here](#install-linux-mbp-arch-binary-on-other-distros-without-compiling), **but** skip `cd /`, and instead create and enter the `pkg` directory:

```
mkdir pkg
cd pkg
pkgdir=$PWD
```

Then run the rest of the commands in that section.

### Creating a package

The process for this will depend on which package manager your distro uses.

Debian based systems:

```
cd $pkgdir
mkdir DEBIAN
cat << EOF > DEBIAN/control
Package: linux-mbp
Version: $pkgver
Architecture: amd64
EOF
dpkg -b . linux-mbp.deb
```

You can then install `linux-mbp.deb`.
