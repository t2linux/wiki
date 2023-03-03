# Why does my MacBook turn off in the middle of the Ubuntu installation?

This seems to happen with certain MacBooks because the GRUB bootloader installer tries accessing the efivars/nvram, which Apple doesn't allow and the installer doesn't know what to do.

There is a way to stop this. Boot into the installation media with an External USB Keyboard plugged in. Press e when you selected the "Try Ubuntu without installing" option.

Scroll to the bottom with the arrow keys, and type in ``efi=noruntime``. With the External keyboard, then press CTRL+X or F10 to boot into the Live Media. The installation should work fine now.

This issue has occured for anyone on the 16,1 and maybe the 16,4.

# Making the GRUB Menu appear

The GRUB bootloader by default turns off the GRUB Menu. This means you can't boot into Bootcamp Windows if it's installed. This can be easily fixed after Ubuntu is fully installed.

In a Terminal in Ubuntu, edit file ``/etc/default/grub`` with any preferred editior (nano/vim) and with root permissions. Change line ``GRUB_TIMEOUT_STYLE`` to ``GRUB_TIMEOUT_STYLE=MENU``. Save the file once you're done.

We've now changed the GRUB Bootloader settings, but we now need to update GRUB to apply these changes. Type in ``sudo update-grub`` and hit enter. After the command is done, you're finished.

# Installing alongside Windows

If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Ubuntu. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.

# Why isn't sound working?

On **Ubuntu 22.04 or earlier**, PulseAudio is installed by default, which performs really bad with T2 audio configuration files. It is suggested to [switch to PipeWire](https://linuxconfig.org/how-to-install-pipewire-on-ubuntu-linux) for better performance, although its still bad as compared to Ubuntu 22.10, which has native support for PipeWire.

On **Ubuntu 22.10 or later**, PipeWire is support natively and works just fine with audio configuration files. Still, it's recommended to use the upstream version of PipeWire since it is found to perform better and has more features than the native one. You can run the following commands to use the upstream version :-

```bash
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream
sudo apt install pipewire pipewire-audio-client-libraries libpipewire-0.3-modules libspa-0.2-{bluetooth,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,tests}}
```

# Why there are no Wi-Fi networks in scan list

In some cases users are not getting even a single Wi-Fi network listed when attempting to connect to a network, inspite of having followed the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) completely and correctly.

To fix this :-

1. Edit `/etc/NetworkManager/NetworkManager.conf` to look like this :-

    ```conf
    [main]
    plugins=ifupdown,keyfile

    [ifupdown]
    managed=false

    [device]
    wifi.scan-rand-mac-address=no
    ```

2. Now edit `/etc/NetworkManager/conf.d/wifi_backend.conf` to look like this :-

    ```conf
    #[device]
    #wifi.backend=iwd
    ```

3. Finally run `sudo systemctl restart NetworkManager`.

# How do I upgrade my kernel

Ubuntu based distro users can upgrade their kernel with [these](https://github.com/AdityaGarg8/T2-Ubuntu-Kernel#pre-installation-steps) instructions.

Debian based distro users can upgrade their kernel with [these](https://github.com/andersfugmann/T2-Debian-Kernel#download-package-manually) instructions.
