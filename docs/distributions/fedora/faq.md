# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Fedora. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# Why isn't sound / WiFi working?

Due to issues in the Fedora install process, there is no sound or WiFi working after install. You'll have to set them up manually.
Refer to these guides on [audio configuration](https://wiki.t2linux.org/guides/audio-config) (note to follow the PipeWire instructions as Fedora uses PipeWire now) and [WiFi configuration](https://wiki.t2linux.org/guides/wifi/).

# My boot hangs before getting to the installer

This may be due to differences between USB-C to USB-A adapters. Try a different one if it is not working.

# Updating Kernel

Please refer to [this section](https://github.com/mikeeq/mbp-fedora-kernel#how-to-update-kernel-mbp).
