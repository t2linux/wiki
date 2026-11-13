# Introduction

This page is a step by step guide to get fan control working on T2 Macs.

In some Macs, the fan has been found to work out of the box. In such cases, the driver is not required unless you want to force a certain speed or do some other configuration which can be done by the help of this driver.

!!! warning "Mac Pro 2019 (MacPro7,1)"
    On the Mac Pro the fans do not react to CPU load without `t2fanrd`. Under Linux the SMC does not get the CPU die temperature, so it keeps the fans at idle while the CPU heats up. A full load on all cores of a Xeon W-3275M took it from 34 °C to 90 °C in 3.5 minutes with the fans unchanged. Install `t2fanrd` on this model. The Radeon on the Mac Pro is usually `card1`, which `t2fanrd` only reads with [T2FanRD#19](https://github.com/GnomedDev/T2FanRD/pull/19); without it the fans follow the CPU temperature alone.

## Steps

1. Install `t2fanrd`.

    -   If you're using Arch based distros:

        1. Check if you installed Arch using our guide or added our repositories. If you haven't done that, follow [this guide](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel) first.

        2. Install the package by running `sudo pacman -S t2fanrd`. (Note that EndeavourOS Cassini Nova R1 already includes t2fand.)

    -   If you're using Debian or Ubuntu based distros:

        1. If you don't have t2-ubuntu-repo, follow [this](https://github.com/AdityaGarg8/t2-ubuntu-repo#apt-repository-for-t2-macs) first to add the repository.

        2. Install the package by running `sudo apt install t2fanrd`.

    -   If you're using Fedora based distros (it should be installed by default, but you need to enable the service):

        1. Make sure our COPR repo is enabled: `sudo dnf copr enable sharpenedblade/t2linux`

        2. Install the package by running `sudo dnf install t2fanrd`

    -   If you're using NixOS with Flakes,

        1. Add <https://github.com/GnomedDev/T2FanRD> to your flakes inputs.

        2. Add the `nixosModule` to your output modules.

        3. Enable the systemd services in your `configuration.nix` and configure the fans.

    -   If you're using other distributions:

        You can compile the daemon by following the instructions given in [this repository](https://github.com/GnomedDev/T2FanRD) and add a systemd service.

2. Enable daemon by running `sudo systemctl enable --now t2fanrd`.

3. Edit the config and restart the daemon by running `sudo systemctl restart t2fanrd` if needed.

## Configuration

The daemons config file can be found at `/etc/t2fand.conf`. You can change the activating temperature and/or fan curve to suit your needs.
For more information, like how fan curves look like, check out [the repository](https://github.com/GnomedDev/T2FanRD#configuration).
