# Introduction

This page explains how to get the config files for using the T2 audio device, which allows use of the 3.5mm headphone port, the built in speakers, the built in mic and the headphones' mic.

Before you proceed, make sure you already have `apple_bce` loaded by running `lsmod | grep apple_bce`. If not, follow the instructions on [how to setup the BCE module](https://wiki.t2linux.org/guides/dkms/#installing-modules).

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

In most scenarios, you should use [these files](https://gist.github.com/MCMrARM/c357291e4e5c18894bea10665dcebffb), following the instructions in that gist's `README.md`.

Special scenarios are:

- [2019 16" MacBook Pro audio files](https://gist.github.com/kevineinarsson/8e5e92664f97508277fefef1b8015fba) - that laptop has 6 speakers and needs slightly different config
- [2020 13" MacBook Air audio files](https://gist.github.com/bigbadmonster17/8b670ae29e0b7be2b73887f3f37a057b)

# Using Pipewire instead of Pulseaudio

You'll need to modify the `/lib/udev/rules.d/91-pulseaudio-custom.rules` file from the links above.

```diff
SUBSYSTEM!="sound", GOTO="pulseaudio_end"
ACTION!="change", GOTO="pulseaudio_end"
KERNEL!="card*", GOTO="pulseaudio_end"

-SUBSYSTEMS=="pci", ATTRS{vendor}=="0x106b", ATTRS{device}=="0x1803", ENV{PULSE_PROFILE_SET}="apple-t2.conf"
+SUBSYSTEMS=="pci", ATTRS{vendor}=="0x106b", ATTRS{device}=="0x1803", ENV{PULSE_PROFILE_SET}="apple-t2.conf", ENV{ACP_PROFILE_SET}="apple-t2.conf"

LABEL="pulseaudio_end"
```

Note: The updated locations for the files in the links above for Pipewire distributions will be:

- /usr/share/alsa/cards/AppleT2.conf
- **/usr/share/alsa-card-profile/mixer/profile-sets/apple-t2.conf**
- /usr/lib/udev/rules.d/91-pulseaudio-custom.rules

# Issues

- Some people are unable to get audio input to work. You may have to use a separate microphone.
- All of apple's fancy tuning of the speakers is done in macOS, we don't have anything like that at the moment.

# Approaches to fixing low microphone volume

## Pulseaudio (2019 16" MacBook Pro)

[Monitor](https://github.com/mahboobkarimian/mbp-2019-Ubuntu-audio) the volume of the microphone and set it back to 400% when a sudden drop in the volume of the microphone occurs (something sets in to 100%. This will help to have consistent microphone volume during video/audio calls.

## KDE

The "Audio Volume" dialog / Audio in System Settings allow users to "Raise maximum volume", allowing to go past 100%. This
does not offer a great deal of flexibility, it might work for getting acceptable recordings however.

## EasyEffects with Pipewire

[EasyEffects](https://github.com/wwmm/easyeffects) is a tool to control and modify audio streams when using pipewire. Compared
to the KDE approach mentioned above using input plugins like "Autogain" offers a lot more fine grain control and higher volume
boosts.
