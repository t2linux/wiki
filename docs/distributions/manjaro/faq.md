# Installing alongside Windows

If you want both Manjaro and Windows installed on your system, refer to this guide on [triple booting](https://wiki.t2linux.org/guides/windows/) as you install.

# Issues Updating Because of the MBP Repository

When you update the system, you may recieve errors about my key being corrupted, if that occurs open a terminal and run this

```sh
sudo pacman-key --recv-key 2BA2DFA128BBD111034F7626C7833DB15753380A --keyserver keyserver.ubuntu.com
```

# Switch Touchbar to Function Keys

Run this in your terminal:

```sh
sudo bash -c "echo 2 > /sys/class/input/*/device/fnmode"
```

# "unable to satisfy dependency 'zfs-utils=0.8.5' required by linux57-mbp-zfs" error when updating

See Updating Kernel below, and then remove the older linux57-mbp kernel's packages once the new kernel is working.

You can also use `pacman -Syu --ignore zfs-utils` to update while skipping the offending package. This is a partial upgrade and is not a reccomended practice. If you are not using zfs-utils then it is unlikely to cause issues.

# Updating Kernel

!!! Warning
    These instructions are currently broken as the new kernel fails to find modules on the initramfs to mount the root filesystem.

The `mbp-manjaro` Kernel is currently not being updated. For now, you can use an [Arch Linux kernel instead](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel).

Then you may have to update the dkms modules, refer to [this page](https://wiki.t2linux.org/guides/dkms/).
