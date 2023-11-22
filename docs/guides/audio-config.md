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

Simply run the following to set up audio:

```bash
sudo git clone https://github.com/kekrby/t2-better-audio.git /tmp/t2-better-audio
cd /tmp/t2-better-audio
./install.sh
sudo rm -r /tmp/t2-better-audio
```

If your distro uses PulseAudio by default, consider switching to PipeWire with rtkit for the best possible experience. You can still use PulseAudio but the experience will not be as smooth as PipeWire, for example you might not be able to select the speakers as the output device when headphones are plugged in.

!!!note "Switching to headphones automatically"
    If you want headphones to be switched to automatically when they are plugged in, you should set them as the default audio sink using the settings app of your DE, `pavucontrol`, `pactl` or `wpctl`.

# Internal microphones DSP Configuration.

In order adjust the microphones signal automatically, we can use the following Pipewire filterchain config:

[Microphones config instructions](https://github.com/lemmyg/t2-apple-audio-dsp/tree/mic)

# Issues

- Some people are unable to get audio input to work. You may have to use a separate microphone.

## KDE

The "Audio Volume" dialog / Audio in System Settings allow users to "Raise maximum volume", allowing to go past 100%. This
does not offer a great deal of flexibility, it might work for getting acceptable recordings however.

## EasyEffects with PipeWire

[EasyEffects](https://github.com/wwmm/easyeffects) is a tool to control and modify audio streams when using PipeWire. Compared
to the KDE approach mentioned above using input plugins like "Autogain" offers a lot more fine grain control and higher volume
boosts.

There is a preconfigured convolver file to give a Dolby Atmos-type sound profile. You can find it [here](https://github.com/JackHack96/EasyEffects-Presets/blob/master/irs/Dolby%20ATMOS%20((128K%20MP3))%201.Default.irs). You simply need to download this file, open EasyEffects, select "Effects" --> Add Effect --> type "Convolver". Afterward select "Impulses" in the rightside menu, select the "Import Impulses" option and then select the file you downloaded earlier. It will usually be in your ~/Downloads folder. As a bonus, go into the preferences of EasyEffects and make sure "Shutdown on window closing" is deselected and "Launch Service at System Startup" is selected. 

# Speakers

All of apple's fancy tuning of the speakers is done in macOS, but a similar configuration is currently available for only the MacBook Pro 16 inch 2019.

## MacBook Pro 16" 2019

Currently we have an experimental DSP (Digital Signal Processing) config for MacBook Pro 16" 2019 with 6 speakers.
Note that each model needs specific settings. Do not use it with other models as it could damage the speakers. Also do not expect same sound quality as in macOS.

[DSP config instructions](https://github.com/lemmyg/t2-apple-audio-dsp/tree/speakers_161)
