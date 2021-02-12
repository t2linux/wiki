# Installing alongside Windows

If you install Manjaro whilst Windows is also installed on your system, Manjaro will use the same Boot entry as the Windows Boot Manager on the macOS Boot Loader.

After clicking on the Windows entry on the macOS bootloader, you will be taken to systemd-boot, from there you can choose if you would like to boot into Manjaro or use the Windows Boot Manager.

# Issues Updating Because of the MBP Repository

When you update the system, you may recieve errors about my key being corrupted, if that occurs open a terminal and run this

```
sudo pacman-key --recv-key 2BA2DFA128BBD111034F7626C7833DB15753380A --keyserver keyserver.ubuntu.com
```

# Switch Touchbar to Function Keys

Run this in your terminal:

```
sudo bash -c "echo 2 > /sys/class/input/*/device/fnmode"
```
