# Introduction

This page explains how to get the config files for using the T2 audio device, which allows use of the 3.5mm headphone port, the built in speakers, the built in mic and the headphones' mic.

Firstly, check whether you are using an updated `apple-bce` version by running `sed -n "s/.*\(AppleT2.*\) -.*/\1/p" /proc/asound/cards`. If the output is `AppleT2xN` (where `N` is a number), then this guide can be followed. If it's just `AppleT2`, then either update the driver first or follow the [older version](https://github.com/t2linux/wiki/blob/00e882d0d5afb3102aedd02872426dc5fba789a5/docs/guides/audio-config.md) of this guide.

If there is no output at all, follow the instructions on [how to setup the BCE module](https://wiki.t2linux.org/guides/dkms/#installing-modules).

# Enable Pass-Through Kernel Parameters

Cat `cat /proc/cmdline` and ensure that your kernel parameters contain `intel_iommu=on iommu=pt pcie_ports=compat`.

If not present, you'll have to update your bootup kernel params:

- edit `/etc/default/grub` and update `GRUB_CMDLINE_LINUX` to include `intel_iommu=on iommu=pt pcie_ports=compat`
- Apply your edits by running `sudo update-grub` on ubuntu or `sudo grub-mkconfig -o /boot/grub/grub.cfg` for other distros
    - Note that, `grub`'s command line interface names might differ on different distros, if the commands like `grub-xxx` are not found, try `grub2-xxx` alternatives instead. For example, it should be `sudo grub2-mkconfig ...` instead of `sudo grub-mkconfig ...` on Fedora 36.
- Reboot and ensure `cat /proc/cmdline` contains those params

!!!note "systemd-boot"
    If you use systemd-boot you'll instead edit your boot conf files to add `intel_iommu=on iommu=pt pcie_ports=compat` to the options line. The files to edit will have the `.conf` extension and be in the loader/entries/ folder on your EFI partition. This will most likely be `/boot/efi/loader/entries`

# Audio Configuration Files

Simply run the following to set up audio :-

```bash
sudo git clone https://github.com/kekrby/t2-better-audio.git /tmp/t2-better-audio
cd /tmp/t2-better-audio
./install.sh
sudo rm -r /tmp/t2-better-audio
```

If your distro uses PulseAudio by default, consider switching to PipeWire with rtkit for the best possible experience. You can still use PulseAudio but the experience will not be as smooth as PipeWire, for example you might not be able to select the speakers as the output device when headphones are plugged in.

An example to get PipeWire working on Ubuntu, which uses PulseAudio by default is given [here](https://linuxconfig.org/how-to-install-pipewire-on-ubuntu-linux).

!!!note "Switching to headphones automatically"
    If you want headphones to be switched to automatically when they are plugged in, you should set them as the default audio sink using the settings app of your DE, `pavucontrol`, `pactl` or `wpctl`.

# Issues

- Some people are unable to get audio input to work. You may have to use a separate microphone.
- All of apple's fancy tuning of the speakers is done in macOS, we don't have anything like that at the moment.

# Approaches to fixing low microphone volume

## PulseAudio (2019 16" MacBook Pro)

[Monitor](https://github.com/mahboobkarimian/mbp-2019-Ubuntu-audio) the volume of the microphone and set it back to 400% when a sudden drop in the volume of the microphone occurs (something sets in to 100%. This will help to have consistent microphone volume during video/audio calls.

## KDE

The "Audio Volume" dialog / Audio in System Settings allow users to "Raise maximum volume", allowing to go past 100%. This
does not offer a great deal of flexibility, it might work for getting acceptable recordings however.

## EasyEffects with PipeWire

[EasyEffects](https://github.com/wwmm/easyeffects) is a tool to control and modify audio streams when using PipeWire. Compared
to the KDE approach mentioned above using input plugins like "Autogain" offers a lot more fine grain control and higher volume
boosts.
