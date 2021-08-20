# Introduction

This page explains how to get the config files for using the T2 audio device, which allows use of the 3.5mm headphone port, the built in speakers, the built in mic and the headphones' mic.

# Audio Configuration Files

These files can be found [here](https://gist.github.com/MCMrARM/c357291e4e5c18894bea10665dcebffb), and there are instructions on where to put them in that gist.

If you are using a 2019 16 inch MBP, use [this](https://gist.github.com/kevineinarsson/8e5e92664f97508277fefef1b8015fba) set of files, as that laptop has 6 speakers and needs slightly different config.

# Fixing low mic volume

Edit `/etc/pulse/default.pa` and add the following at the end :-

```plain
set-source-volume 1 300000
```

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

# Issues

- Some people are unable to get audio input to work. You may have to use a seperate microphone.
- All of apple's fancy tuning of the speakers is done in macOS, we don't have anything like that at the moment.
