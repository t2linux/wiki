# Introduction

This article is meant to guide users through the wiki by giving an overview over the required steps to
get to a working installation.

## Deciding on the Installation

Using Linux on a T2 Mac comes with compromises as well as advantages compared to macOS. You will need
to decide for yourself if it its worth it.

Your first consideration should be the risk you are taking. Don't worry, nobody has broken their machine so far by installing
Linux and by following the guides closely you should be able to get everything working even without a lot of knowledge as well.
Still in case something goes wrong we are not responsible for it, we will try our best to help out however.

## Can I completely remove macOS?

While its technically possible to remove macOS entirely, its strongly encouraged to dual boot it with Linux because :-

1. To set up Wi-Fi on Linux, you will need Wi-Fi firmware, which can be legally obtained only from macOS. It is illegal to host the firmware on any website as it is under a non redistributable license.
2. It acts as a backup in case something goes wrong.
3. macOS updates often bring along certain firmware updates, which tend to be useful for Linux as well.

Still if you wish to remove macOS completely, it is recommended to [create a bootable macOS installer](https://support.apple.com/en-us/HT201372) so as to have an option of restoring macOS back.

You can also use the [Internet Recovery](https://support.apple.com/en-in/HT204904) to reinstall macOS, but this has been quite unreliable and slow for a considerable amount of users, thus making the bootable installer method a better one.

## What works on Linux?

Take a look at the [state article](https://wiki.t2linux.org/state/). It gives a list of roughly what works on Linux and what doesn't.
If a specific feature is not listed at all, there is a chance it actually works.

## Choosing a Distribution

While technically it is not a limitation when installing Linux, different distributions do provide different levels of documentation,
ease of use and polish.

Arch Linux probably has the most documentation, both officially for the whole project in form of the Arch Wiki and in scope of the
t2linux wiki with a really detailed and up to date install guide. On top of that there is also a work in progress `archinstall` script.
Keep in mind however that the whole process is done in the command line.

Manjaro has a more guided install experience, with a graphical installer and multiple prebuilt ISOs for different desktop environments. There are 2 versions of the Manjaro ISO built by different people. JPyke3's version, which is not recommended, and NoaHimesaka1873's which is newer and recommended.

EndeavourOS is an Arch based Linux distribution with a graphical installer. This distribution requires little to no configuration after install.

Ubuntu also has a graphical installer. Additionally, less post configuration work is required as some kernel modules are getting installed automatically.

Fedora also has a prebuilt ISO and a graphical installer. Most things work out of the box, though audio and WiFi generally need to be set up as in the guides below. Then they should work flawlessly.

NixOS has both prebuilt graphical and command line installers. Support for T2 devices is provided in the form of a `nixos-hardware` module.
Importing the module is the only thing you have to do to get your configuration working on your Mac.

If you wish to use another distribution, you can install it normally, also follow the steps to [install the kernel yourself manually](https://wiki.t2linux.org/guides/kernel/) and follow the [post installation steps](https://wiki.t2linux.org/roadmap/#configuring-the-installation).

## Installing

Follow the [Pre-installation steps](https://wiki.t2linux.org/guides/preinstall) to prepare your Mac to install Linux and head over to the appropriate guide of the distro of your choice as mentioned in that guide.

## Configuring the Installation

After successfully booting into your new installation, you will need to configure a few things:

-   [Performing a basic setup](https://wiki.t2linux.org/guides/postinstall/)
-   [Getting Wi-Fi and Bluetooth to work](https://wiki.t2linux.org/guides/wifi-bluetooth/)
-   [Install drivers for the fan (if not working automatically or want to force a certain speed)](https://wiki.t2linux.org/guides/fan/)
-   [Configure audio](https://wiki.t2linux.org/guides/audio-config/)
-   [Configure the Startup Manager (optional)](https://wiki.t2linux.org/guides/startup-manager/)
-   [Install rEFInd (optional)](https://wiki.t2linux.org/guides/refind/)

You might also want to look into [getting the internal GPU to work](https://wiki.t2linux.org/guides/hybrid-graphics/) if your Mac has two
graphics cards. However, if you don't need it specifically, it's probably best to stick with the dedicated one. If your Mac only has
a single graphics unit, you can ignore this.
