# Updating Kernel

`linux-mbp` is abandoned. Switch to `linux-t2` or `linux-xanmod-edge-t2` now if you're still using `linux-mbp`.

Add new repositories to `/etc/pacman.conf`, by adding this:

```ini
[Redecorating-t2]
Server = https://github.com/Redecorating/archlinux-t2-packages/releases/download/packages

[arch-mact2]
Server = https://mirror.funami.tech/arch-mact2/os/x86_64
SigLevel = Never
```

Then install new kernel and supporting packages by running this:
`sudo pacman -Syu linux-t2 apple-t2-audio-config apple-bcm-firmware`

You can use Xanmod kernel instead by replacing `linux-t2` with `linux-xanmod-edge-t2`. If you need header package, also install `linux-t2-headers` (or `linux-xanmod-edge-t2-headers` if you chose to install Xanmod kernel).

# Building Kernel

```sh
git clone https://github.com/Redecorating/linux-t2-arch
cd linux-t2-arch
makepkg -si
```

You can instead clone the other repos mentioned under [Updating Kernel](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel). You may need to change the folder you `cd` into.
