# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries to access the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the external keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occurred for anyone on the 16,1 and possibly the 16,4.

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, edit file ``/etc/default/grub`` with any preferred editor (nano/vim) and with root permissions. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file once you're done.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# Why isn't sound working?

On **Ubuntu 22.04 or earlier**, PulseAudio is installed by default, which performs really badly with T2 audio configuration files. It is suggested to [switch to PipeWire](https://linuxconfig.org/how-to-install-pipewire-on-ubuntu-linux) for better performance, although its still bad as compared to Ubuntu 22.10, which has native support for PipeWire.

On **Ubuntu 22.10 or later**, PipeWire is supported natively and works just fine with audio configuration files. Still, it's recommended to use the upstream version of PipeWire since it is found to perform better and has more features than the native one. You can run the following commands to use the upstream version:

```bash
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream
sudo apt install pipewire pipewire-audio-client-libraries libpipewire-0.3-modules libspa-0.2-{bluetooth,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,tests}}
```

# How do I upgrade my kernel

Follow [these](https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel?tab=readme-ov-file#using-the-apt-repo) instructions.

# Why does Wi-Fi stop working after closing the lid?

On some T2 Macs with the BCM4377b Wi-Fi chip (e.g. MacBookAir9,1), the `brcmfmac` driver
fails to handle suspend correctly, leaving the Wi-Fi firmware unresponsive after resume.
See the [Wi-Fi and Bluetooth guide](../../guides/wifi-bluetooth.md#wi-fi-not-working-after-lid-close-bcm4377b)
for the fix.
