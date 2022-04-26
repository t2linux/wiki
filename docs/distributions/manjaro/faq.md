# Migrating from Pykee's old kernel to new LTS kernel

Run this in your terminal:

```sh
cat << EOF | sudo tee -a /etc/pacman.conf
[manjaro-mact2]
SigLevel = Never
Server = https://mirror.funami.tech/manjaro-mact2/os/x86_64
EOF
sudo pacman --ignore zfs-utils -Syu linux515-t2 linux515-t2-headers apple-bcm-wifi-firmware
```

After running this, remove old repository and reboot.

# Migrating from mainline 5.16 kernel to LTS kernel (recommended)

Users using 5.16 kernel are advised to migrate to LTS kernel since it now integrates necessary modules into kernel. Even if you want to update to 5.17 it's still advised to first jump to LTS kernel and wait here.

Run this in your terminal:

```sh
# Say yes to removing conflicting packages. apple-ibridge-dkms-git and apple-bce-dkms-git is now integrated to kernel thus those DKMS modules are not necessary.
sudo pacman -Syu linux515-t2 linux515-t2-headers
sudo pacman -R linux516-t2 linux516-t2-headers
```

# Installing alongside Windows

If you want both Manjaro and Windows installed on your system, refer to this guide on [triple booting](https://wiki.t2linux.org/guides/windows/) as you install.

# Switch Touchbar to Function Keys

Run this in your terminal:

```sh
sudo bash -c "echo 2 > /sys/class/input/*/device/fnmode"
```
