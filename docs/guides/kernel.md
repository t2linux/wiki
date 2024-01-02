# Kernel

This page explains how to compile a Linux kernel with patches for T2 hardware support and with apple-bce + apple-ibridge included. If you have issues, make sure you are running the commands here with `bash`.

If your distro is not one of the distros with documentation on this Wiki, you may not need to compile a kernel yourself to get support for T2 hardware. Debian based systems can use the same kernel as described in the Ubuntu section, Arch based systems can use the same kernel as described in the Arch section, etc.

## Requirements

- You will need some packages to build the kernel:

    - Arch based systems: `sudo pacman --needed -S bc kmod libelf pahole cpio perl tar xz git`
    - Debian based systems: `sudo apt install build-essential libncurses-dev libssl-dev flex bison libelf-dev bc dwarves openssl`
    - For other distros you will need the equivalent of these, but if you miss something you'll most likely get an error saying what's missing, and you can then install it and re-run `make` to continue where you left off.

- You will need about 20GB of disk space to compile the kernel. If you have a large amount of ram, you could use tmpfs to store build files in ram.

## Building kernel

### Getting kernel source and applying patches

!!! Hint
    The kernel source will be downloaded with HTTP**S**, but if you would like to be extra careful and verify the kernel source code with `gpg`, please refer to [this page](https://kernel.org/signature.html#using-gnupg-to-verify-kernel-signature).

```bash
mkdir build && cd build
git clone --depth=1 https://github.com/t2linux/linux-t2-patches patches

pkgver=$(curl -sL https://github.com/t2linux/T2-Ubuntu-Kernel/releases/latest/ | grep "<title>Release" | awk -F " " '{print $2}' | cut -d "v" -f 2 | cut -d "-" -f 1)
_srcname=linux-${pkgver}
wget https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.xz
tar xf $_srcname.tar.xz
cd $_srcname

for patch in ../patches/*.patch; do
    patch -Np1 < $patch
done
```

### Setting kernel configuration

!!! Info "Using config from lower kernel versions"
    We will use the config of the kernel that is currently running. If your running kernel is an older longterm/stable kernel, it's possible that some of the default choices for new options added to the kernel might not be what you want. You can replace `make olddefconfig` in the code block below with `make oldconfig` if you want to manually set new options. You can always later use `make menuconfig` to change kernel config options if you have issues.

```bash
zcat /proc/config.gz > .config
make olddefconfig
scripts/config --module CONFIG_BT_HCIBCM4377
scripts/config --module CONFIG_HID_APPLETB_BL
scripts/config --module CONFIG_HID_APPLETB_KBD
scripts/config --module CONFIG_DRM_APPLETBDRM
scripts/config --module CONFIG_HID_APPLE_MAGIC_BACKLIGHT
scripts/config --module CONFIG_APPLE_BCE
```

### Building

This may take 2-3 hours to build depending on your CPU and the kernel config.

!!! Info "Incremental builds"
    If you `control-c` to stop the build process, you may continue where you left off by running `make` again. If you build the kernel, and realise you want to make more changes to the code or config, re-running `make` will only rebuild bits that you changed.

```bash
make -j$(nproc)
```

## Installing

```bash
export MAKEFLAGS=-j$(nproc)

sudo make modules_install
sudo make install
```

If `sudo make install` said "Cannot find LILO.", that's fine.

Look at the output from `sudo make install`. If it mentioned creating an initramfs or an initrd, a script provided by your distro has done the next step for you. The same goes for if it mentions updating grub or systemd-boot or bootloader config. This distro script would be at `/sbin/updatekernel`.

### Initramfs/Initrd

Next we must create an initramfs/initrd (Initial RAM Filesystem / Initial RAM Disk). As mentioned in the previous step, this may have been automatically done for you.

For most arch based systems:

```bash
sudo mkinitcpio -k /boot/vmlinuz -c /etc/mkinitcpio.conf -g /boot/initramfs.img
```

For other distros, refer to your distro's documentation if this wasn't done by `make install` earlier.

### Adding new kernel to bootloader config

Again, `sudo make install` may have done this for you.

#### Grub

1. Edit `/etc/default/grub` and set `GRUB_TIMEOUT=3` (You can pick a different amount of seconds), and `GRUB_TIMEOUT_STYLE=menu`
2. `sudo grub-mkconfig -o /boot/grub/grub.cfg`

#### Systemd-boot

1. Make a copy of any `.conf` file in `/boot/loader/entries/` and name it something like `linux.conf`
2. Edit the file you just created and change the `linux` and `initrd` lines like this, but leave any `initrd` lines with `ucode`. Also change the title to something different.

    ```plain
    title   Linux Custom
    linux   /vmlinuz
    initrd  /initramfs.img
    ```

3. Edit `/boot/loader/loader.conf` and make sure the timeout is 1 or higher, and if you want you can change the default to the name of the file you created in step 1.

## Rebooting

When you reboot, you should either now have the new kernel as the default, or be able to select it with up and down arrow keys and enter. You can check `uname -r` to see the kernel version that you are currently running.

!!! Hint
    You also can use `kexec` to start the new kernel without a full reboot which is quicker if you are rebuilding the kernel repeatedly. `sudo kexec -l /boot/vmlinuz --initrd=/boot/initramfs.img --reuse-cmdline && systemctl kexec`
