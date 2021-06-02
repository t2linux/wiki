# Introduction

This article is meant to guide users through the wiki by giving an overview over the required steps to
get to a working installation

## Deciding on the Installation

Using Linux on a T2 Mac comes with compromises as well as advantages compared to macOS. You will need
to decide for yourself it its worth it.

Your first consideration should be the risk you are taking. Don't worry, nobody has broke their machine so far by installing
Linux and by following the guides closely you should be able to get everything working even without a lot of knowledge as well.
Still in case something goes wrong we are not responsible for it, we will try our best to help out however.

Note that while its technically possible to remove macOS entirely, its strongly encouraged to dual boot it with Linux to have
a backup in case something goes wrong.

Now, take a look at the [state article](https://wiki.t2linux.org/state/). It gives an lists roughly what works on Linux and what not.
If a specific feature is not listed at all, there is a chance it actually works. For a more technical list you might want to refer to
[https://github.com/Dunedan/mbp-2016-linux](https://github.com/Dunedan/mbp-2016-linux).

## Choosing a Distribution

While technially not a limitation when installting Linux, different distributions do provide different levels of documentation,
ease of use and polish.

Arch Linux probably has the most documentation, both officially for the whole project in form of the Arch Wiki and in scope of the
t2linux wiki with a really detailed and up to date install guide. On top of that there is also a work in progress archinstall script.
Keep in mind however that the whole process is done in the command line.

Manjaro has a more guided install experience, with a graphical installer and multiple prebuild isos for different desktop environments.

Ubuntu also has a grahical installer. Additionally, less post configuration work is required as some kernel modules are getting
installed automatically.

Fedora also has a prebuild iso.

Note that with the expection of Arch, all distributions currently only have 5.7.19 as the latest kernel version that is considered stable. The support period for 5.7.x ended in August 2020.
You could [upgrade the kernel yourself manually](https://wiki.t2linux.org/guides/kernel/)

If you wish to use another distribution, you can install it normally, also follow the steps to [install the kernel yourself manually](https://wiki.t2linux.org/guides/kernel/) and follow the [post installation steps](https://wiki.t2linux.org/roadmap/#configuring-the-installation)

## Preparing the Installation

You will want to look at [Is my model supported?](https://wiki.t2linux.org/guides/wifi/#is-my-model-supported) in the wifi guide before starting an installation.
Based on that information, follow the wifi guide until any steps you need to run on linux. This includes finding
out your model identifier, the firmware files needed for your device and downloading or extracting those firmware files.

Make sure to keep the wifi files, as well as any other files you might want to access after the installation (a password manager database for example) on a medium you can access from Linux. Linux can not read APFS, the file system macOS uses by default.

You also need to make some space on your harddrive. While its technically possible to install Linux on an external drive, it depends on the install process of the distribution if this is supported. 20 to 40 GB should be fine for a base installation.

To boot into a live environment, you need to [disable secure boot and allow booting from an external device](https://support.apple.com/en-us/HT208198).

If you distribution needs a connection to the internet while installing, make sure to prepare an ethernet cable, wifi adapter or
phone for tethering. If non of those are an option but your model has wifi support, you can also follow the On Linux steps of the wifi
guide on your live environment. Keep in mind that in that case you will also still follow the guide on your actual install after exiting
the live environment.

If you want to triple boot with Windows, read the instructions on in the [triple boot guide](https://wiki.t2linux.org/guides/windows/) before proceeding.

## Installing

Now follow the installation guide of your specific distribution.

This wiki provides a set of such guides for different distributions, which can be found [here](https://wiki.t2linux.org/distributions/overview/). If the distribution you want to use has such a guide, its recommended to follow it instead of the instructions given in one of the repositories or otherwise official documentation by distribution vendor.

## Configuring the Installation

After successfully booting into your new installation, you will need to configure a few things.

- Install drivers for the internal keyboard, trackpad and touchbar (if not working already): [here](https://wiki.t2linux.org/guides/dkms/)
- Install drivers for wifi: [here](https://wiki.t2linux.org/guides/wifi/#on-linux)
- Install drivers for the fan: [here](https://wiki.t2linux.org/guides/fan/)
- Configure audio: [here](https://wiki.t2linux.org/guides/audio-config/)

You might also want to look into [getting the interal GPU to work](https://wiki.t2linux.org/guides/hybrid-graphics/) if you Mac has two
graphics cards. However if you don't need it specifically, its probably best to stick with the deticated gpu. If your Mac only has
a single GPU, you can ignore this anyways.