# Introduction

This page is a step by step guide to get fan control working on T2 Macs.

In some Macs, the fan has been found to work out of the box. In such a case the driver is not required until you want to force a certain speed or do some other configuration which can be done by the help of this driver.

## Steps

1. Install `t2fand`.

    -   If you're using Arch Linux, EndeavourOS, or Manjaro:
        
	1. Simply install it by running `sudo pacman -S t2fand`. (Do note that EndeavourOS Cassini Nova R1 already includes t2fand.)

    -   If you're using other distributions:

        1. Clone the repository by running `git clone https://github.com/NoaHimesaka1873/t2fand`

        2. Change directory into the cloned repository.

	3. Install it by running `make install`.


2. Enable daemon by running `sudo systemctl enable --now t2fand`. 

    !!! note
        This will run a patch script that finds a fan device on your system.
        You can use its output for debug purposes

3. Edit the config and restart the daemon if needed.

## Configuration

The daemons config file can be found at `/etc/t2fand.conf`. You can change the activating temperature and/or fan curve to suit your needs.
For more information, like how fan curves look like, check out [the repository](https://github.com/NoaHimesaka1873/t2fand).
