# Introduction

This page explains how to install the kernel modules for the Keyboard, Audio, Touchbar and the Ambient Light sensor with DKMS. You will need a patched kernel.

# Installing modules

1. Install the `dkms` package
2. Installing the BCE (Buffer Copy Engine) module for Keyboard and Audio
	- You are on arch, get Aunali1's [apple-bce-dkms-git package](https://github.com/aunali1/apple-bce-arch/releases)
	- Otherwise, `sudo git clone https://github.com/t2linux/apple-bce-drv /usr/src/apple-bce-r183.c884d9c`
	- Use `sudo dkms install -m apple-bce -v r183.c884d9c`. Add `-k x.x.x-mbp` if you need to install for a specific kernel version.
3. Installing the Touchbar and Ambient Light sensor modules
	- `sudo git clone https://github.com/t2linux/apple-ib-drv /usr/src/apple-ibridge-0.1`
	- Use `sudo dkms install -m apple-ibridge -v 0.1`. Add `-k x.x.x-mbp` if you need to install for a specific kernel version.
4. Load the modules into the kernel

```
sudo modprobe apple_bce
sudo modprobe apple_ib_tb
sudo modprobe apple_ib_als
```

# Audio Configuration Files

The Touchbar and keyboard should work.

For audio, there are config files required, these can be found [here](https://gist.github.com/MCMrARM/c357291e4e5c18894bea10665dcebffb)

If you are using a 2019 16 inch MBP, use [this](https://gist.github.com/kevineinarsson/8e5e92664f97508277fefef1b8015fba) set of files, as that laptop has 6 speakers.

# Fixing Suspend

Copy [this script](https://github.com/marcosfad/mbp-ubuntu/blob/master/files/suspend/rmmod_tb.sh) to `/lib/systemd/system-sleep/rmmod_tb.sh`

# Issues

The `apple_ib_als` module can cause issues, if you find your computer hanging at shutdown, or having BCE errors at boot, try blacklisting it `sudo sh -c "echo blacklist apple-ib-als" >> /etc/modprobe.d/blacklist.conf`
