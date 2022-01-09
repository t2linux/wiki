# Introduction

This page explains how to get the config files for using the T2 audio device, which allows use of the 3.5mm headphone port, the built in speakers, the built in mic and the headphones' mic.

Before you proceed, make sure you already have `apple_bce` loaded by running `lsmod | grep apple_bce`. If not, follow the instructions on [how to setup the BCE module](https://wiki.t2linux.org/guides/dkms/#installing-modules).

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
