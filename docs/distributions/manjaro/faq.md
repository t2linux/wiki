# Migrating to new kernel

Run this in your terminal:

```sh
cat << EOF | sudo tee -a /etc/pacman.conf
[manjaro-mact2]
SigLevel = Never
Server = https://mirror.funami.tech/manjaro-mact2/os/x86_64
EOF
sudo pacman --ignore zfs-utils -Syu linux516-t2 linux516-t2-headers dkms apple-bce-dkms-git apple-ibridge-dkms-git apple-bcm-wifi-firmware
sudo pacman -R linux57-mbp 
sudo pacman -R linux56-mbp
sudo pacman -R linux57-mbp-headers
sudo pacman -R linux56-mbp-headers
sudo mkdir -p /etc/modules-load.d
sudo touch /etc/modules-load.d/t2.conf
cat << EOF | sudo tee /etc/modules-load.d/t2.conf
apple-bce
brcmfmac
EOF
```

After running this, remove old repository and reboot.

# Installing alongside Windows

If you want both Manjaro and Windows installed on your system, refer to this guide on [triple booting](https://wiki.t2linux.org/guides/windows/) as you install.

## Switch Touchbar to Function Keys

Run this in your terminal:

```sh
sudo bash -c "echo 2 > /sys/class/input/*/device/fnmode"
```

