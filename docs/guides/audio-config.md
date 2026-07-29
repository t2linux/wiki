# Introduction

This page explains how to get the config files for using the T2 audio device, which allows use of the 3.5mm headphone port, the built in speakers, the built in mic and the headphones' mic.

Firstly, check whether the `t2bce_audio` driver exposes the model-specific speaker layout by running `sed -n "s/.*\(AppleT2.*\) -.*/\1/p" /proc/asound/cards`. If the output is `AppleT2xN` (where `N` is a number), then this guide can be followed. If it is just `AppleT2`, update your T2 kernel and its t2bce driver stack first.

If there is no output at all you probably do not have T2 Mac support. Follow the instructions on [how to add support for T2 Macs](https://wiki.t2linux.org/guides/postinstall/).

# Enable Pass-Through Kernel Parameters

Run `cat /proc/cmdline` and ensure that your kernel parameters contain `intel_iommu=on iommu=pt pm_async=off`.

If not present, you'll have to update your bootup kernel parameters:

- edit `/etc/default/grub` and update `GRUB_CMDLINE_LINUX` to include `intel_iommu=on iommu=pt pm_async=off`
- Apply your edits by running `sudo update-grub` on ubuntu or `sudo grub-mkconfig -o /boot/grub/grub.cfg` for other distros
    - `grub`'s command line interface names might differ on different distros, if the commands like `grub-xxx` are not found, try `grub2-xxx` alternatives instead. For example, it should be `sudo grub2-mkconfig ...` instead of `sudo grub-mkconfig ...` on Fedora 36.
- Reboot and ensure `cat /proc/cmdline` contains those params

!!!note "systemd-boot"
    If you use systemd-boot you'll instead edit your boot conf files to add `intel_iommu=on iommu=pt pm_async=off` to the options line. The files to edit will have the `.conf` extension and be in the loader/entries/ folder on your EFI partition. This will most likely be `/boot/efi/loader/entries`

!!!note "rEFInd"
    If you use rEFInd, it may have been configured to boot directly onto Linux, without indirectly booting GRUB or systemd-boot. If that's the case, you'll have to edit the boot parameters somewhere else. Follow the steps at [Using rEFInd as a replacement for GRUB, systemd-boot, etc.](refind.md#using-refind-as-a-replacement-for-grub-systemd-boot-etc)

# Audio Configuration Files

Simply run the following to set up audio:

```bash
sudo git clone https://github.com/kekrby/t2-better-audio.git /tmp/t2-better-audio
cd /tmp/t2-better-audio
./install.sh
sudo rm -r /tmp/t2-better-audio
cd -
```

If your distro uses PulseAudio by default, consider switching to PipeWire with rtkit for the best possible experience. You can still use PulseAudio but the experience will not be as smooth as PipeWire, for example you might not be able to select the speakers as the output device when headphones are plugged in.

!!!note "Switching to headphones automatically"
    If you want headphones to be switched to automatically when they are plugged in, you should set them as the default audio sink using the settings app of your DE, `pavucontrol`, `pactl` or `wpctl`.
