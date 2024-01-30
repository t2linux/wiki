# Introduction

This page is a step by step guide to get fan control working on T2 Macs.

In some Macs, the fan has been found to work out of the box. In such a case the driver is not required until you want to force a certain speed or do some other configuration which can be done by the help of this driver.

## Steps

1. Install `t2fanrd`.

    -   If you're using Arch based distros:

        1. Check if you installed Arch using our guide or added our repositories. If you haven't done that, follow [this guide](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel) first.

        2. Install the package by running `sudo pacman -S t2fanrd`. (Do note that EndeavourOS Cassini Nova R1 already includes t2fand.)

    -   If you're using Debian or Ubuntu based distros:

        1. If you don't have t2-ubuntu-repo, follow [this](https://github.com/AdityaGarg8/t2-ubuntu-repo#apt-repository-for-t2-macs) first to add the repository.

        2. Install the package by running `sudo apt install t2fanrd`.

    -   If you're using Fedora based distros:

        1. tbd

    -   If you're using other distributions:

        You can compile the daemon by following the instructions given in [this repository](https://github.com/GnomedDev/T2FanRD) and add a systemd service.

2. Enable daemon by running `sudo systemctl enable --now t2fand`.

3. Edit the config and restart the daemon by running `sudo systemctl restart t2fand` if needed.

## Configuration

The daemons config file can be found at `/etc/t2fand.conf`. You can change the activating temperature and/or fan curve to suit your needs.
For more information, like how fan curves look like, check out [the repository](https://github.com/GnomedDev/T2FanRD).
