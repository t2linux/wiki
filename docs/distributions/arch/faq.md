# Updating Kernel
If you're using `linux-mbp`, you **MUST** update your kernel since it isn't maintained anymore.

Add this repository first by adding these lines to your `pacman.conf`
```ini
[Redecorating-t2]
Server = https://github.com/Redecorating/archlinux-t2-packages/releases/download/packages

[arch-mact2]
Server = https://mirror.funami.tech/arch-mact2/os/x86_64
SigLevel = Never
```

And install and delete new kernel by running `sudo pacman -Syu linux-t2{,-headers} apple-bcm-firmware apple-t2-audio-config && sudo pacman -R linux-mbp`. Delete remaining `apple-bce` and `apple-ibridge` DKMS moduleif you have them.
