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

1. It acts as a backup in case something goes wrong.
2. macOS updates often bring along certain firmware updates, which tend to be useful for Linux as well.

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

Manjaro has a more guided install experience, with a graphical installer and multiple prebuilt ISOs for different desktop environments. There are 2 versions of the Manjaro ISO built by different people. JPyke3's version, which is not reccomended, and NoaHimesaka1873's which is newer and reccomended. 

Ubuntu also has a graphical installer. Additionally, less post configuration work is required as some kernel modules are getting installed automatically.

Fedora also has a prebuilt ISO and a graphical installer. Most things work out of the box, though audio and WiFi generally need to be set up as in the guides below. Then they should work flawlessly.

If you wish to use another distribution, you can install it normally, also follow the steps to [install the kernel yourself manually](https://wiki.t2linux.org/guides/kernel/) and follow the [post installation steps](https://wiki.t2linux.org/roadmap/#configuring-the-installation).

## Preparing the Installation

You will want to look at [the wifi guide](https://wiki.t2linux.org/guides/wifi/) to check if your model is supported before starting an installation.
Based on that information, prepare anything that is needed for installing on Linux.

Make sure to keep the wifi firmware, as well as any other files you might want to access after the installation (a password manager database for example) on a medium you can access from Linux. Linux cannot read APFS, the file system macOS uses by default.

You will also need to make some space on your hard drive. While its technically possible to install Linux on an external drive, it depends on the install process of the distribution if this is supported. 20 to 40GB should be fine for a base installation.

To boot into a live environment, you need to [disable secure boot and allow booting from an external device](https://support.apple.com/en-us/HT208198).

If your distribution needs a connection to the Internet while installing, make sure to prepare an Ethernet cable, wifi adapter or
phone for tethering. If none of these options are available but your model has wifi support, you can also follow the steps to install firmware in your live environment. Keep in mind that in that case you will still need to follow the guide on your actual install after exiting
the live environment.

If you want to triple boot with Windows, read the instructions in the [triple boot guide](https://wiki.t2linux.org/guides/windows/) before proceeding.

## Installing

Now follow the installation guide of your specific distribution.

This wiki provides a set of [guides for different distributions](https://wiki.t2linux.org/distributions/overview/). If the distribution you want to use is present there, it's recommended to follow it instead of the official documentation by distribution vendor, as it considers T2 support.

## Configuring the Installation

After successfully booting into your new installation, you will need to configure a few things:

-   [Install/upgrade drivers for the soundcard, internal keyboard, trackpad and touchbar](https://wiki.t2linux.org/guides/dkms/)
-   [Getting wifi to work](https://wiki.t2linux.org/guides/wifi)
-   [Install drivers for the fan (if not working automatically or want to force a certain speed)](https://wiki.t2linux.org/guides/fan/)
-   [Configure audio](https://wiki.t2linux.org/guides/audio-config/)
-   [Configure startup manager (optional)](https://wiki.t2linux.org/guides/startup-manager/)
-   [Install rEFInd (optional)](https://wiki.t2linux.org/guides/refind/)

You might also want to look into [getting the internal GPU to work](https://wiki.t2linux.org/guides/hybrid-graphics/) if your Mac has two
graphics cards. However, if you don't need it specifically, it's probably best to stick with the dedicated one. If your Mac only has
a single graphics unit, you can ignore this.
