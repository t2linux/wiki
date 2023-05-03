# Introduction

This page is a step by step guide to get fan control working on T2 Macs.

In some Macs, the fan has been found to work out of the box. In such a case the driver is not required until you want to force a certain speed or do some other configuration which can be done by the help of this driver.

## Steps

1. Install `t2fand`.

    -   If you're using Arch based distros:

        1. Check if you installed Arch using our guide or added our repositories. If you haven't done that, follow [this guide](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel) first.

        2. Install the package by running `sudo pacman -S t2fand`. (Do note that EndeavourOS Cassini Nova R1 already includes t2fand.)

    -   If you're using Debian or Ubuntu based distros:

        1. If you don't have t2-ubuntu-repo, add it first by running:

        ```sh
        curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
        sudo curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
        sudo apt update
        ```

        2. Install the package by running `sudo apt install t2fand`.

    -   If you're using other distributions:

        1. Clone the repository by running `git clone https://github.com/NoaHimesaka1873/t2fand`

        2. Change directory into the cloned repository.

        3. Install it by running `make install`.

2. Enable daemon by running `sudo systemctl enable --now t2fand`.

3. Edit the config and restart the daemon if needed.

## Configuration

The daemons config file can be found at `/etc/t2fand.conf`. You can change the activating temperature and/or fan curve to suit your needs.
For more information, like how fan curves look like, check out [the repository](https://github.com/NoaHimesaka1873/t2fand).
