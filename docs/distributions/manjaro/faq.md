# Installing alongside Windows

If you want both Manjaro and Windows installed on your system, refer to this guide on [triple booting](https://wiki.t2linux.org/guides/windows/) as you install.

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
