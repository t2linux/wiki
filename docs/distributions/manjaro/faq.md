# Deprecation Notice

Manjaro support will be deprecated soon. See [Deprecation Plan](https://wiki.t2linux.org/distributions/manjaro/deprecation) for more information.

# Migrating from Pykee's old kernel to new kernel

Run this in your terminal:

```sh
cat << EOF | sudo tee -a /etc/pacman.conf
[manjaro-mact2]
SigLevel = Never
Server = https://mirror.funami.tech/manjaro-mact2/os/x86_64
EOF
sudo pacman --ignore zfs-utils -Syu linux519-t2 linux519-t2-headers apple-bcm-wifi-firmware
```

After running this, remove old repository and reboot.

# Upgrading to newer kernel (recommended)

Users using older kernel are advised to migrate to newest kernel since newer kernel has more support.

Join our Discord or enable notifications for [this repository](https://github.com/NoaHimesaka1873/manjaro-kernel-t2) to get pings for new kernel.

# Installing alongside Windows

If you want both Manjaro and Windows installed on your system, refer to this guide on [triple booting](https://wiki.t2linux.org/guides/windows/) as you install.

# Switch Touchbar to Function Keys

Run this in your terminal:

```sh
sudo bash -c "echo 2 > /sys/class/input/*/device/fnmode"
```
