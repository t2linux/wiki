# Introduction

Welcome to the t2linux wiki!

This wiki contains knowledge about running Linux on Macs with the T2 chip.
A list of those devices can be found [on Apple's website](https://support.apple.com/en-us/HT208862).

# Warnings

- Some kernel versions, notably `5.8.x` and `5.9.x` are known to have issues. See the releases (those not marked as a pre-release) of [aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch/releases) for ones that have been tested. Keep in mind that some might very have reached their [end of life](https://en.wikipedia.org/wiki/Linux_kernel_version_history#Releases_5.x.y).
- **Ubuntu's GRUB** is not booting using the Mac Startup Manager for many users. Thus affected users are advised to [install the rEFInd bootloader](https://wiki.t2linux.org/guides/refind/) and boot the kernel using it instead of the Startup Manager.

# Getting started

To get started with an installation, refer to the [roadmap](https://wiki.t2linux.org/roadmap).

# Contact us

You may contact us on the [Linux on T2 Macs (2018+) Discord Server](https://discord.com/invite/68MRhQu), where you can find most of the people involved.

# Contribute

Visit the [Contribute page](https://wiki.t2linux.org/contribute/) for more details.

# Notable Resources

## Distributions

Different distributions are maintained by different people in their own repositories.
If the distribution you want to use has a guide [here](https://wiki.t2linux.org/distributions/overview/), it's recommended to follow it instead of the instructions given in one of the repositories or otherwise official documentation by distribution vendor, as it considers T2 support.

- Arch [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)
- EndeavourOS [https://github.com/t2linux/EndeavourOS-ISO-t2](https://github.com/t2linux/EndeavourOS-ISO-t2)
- Fedora [https://github.com/mikeeq/mbp-fedora](https://github.com/mikeeq/mbp-fedora)
- Gentoo [https://github.com/t2linux/T2-Gentoo-Kernel](https://github.com/t2linux/T2-Gentoo-Kernel)
- Manjaro (Jpyke3 - Outdated) [https://github.com/JPyke3/mbp-manjaro](https://github.com/JPyke3/mbp-manjaro)
- Manjaro (NoaHimesaka - Reccomended) [https://github.com/NoaHimesaka1873/manjaroiso-t2](https://github.com/NoaHimesaka1873/manjaroiso-t2)
- Tails [https://github.com/T2minator/mbp-tails](https://github.com/T2minator/mbp-tails)
- Ubuntu [https://github.com/marcosfad/mbp-ubuntu](https://github.com/marcosfad/mbp-ubuntu)

## Kernel Modules

Support for hardware is cross distro besides patches to the distribution specific kernel.
The following repos contain kernel modules for said support:

- MacBook Bridge / T2 Linux Driver [https://github.com/t2linux/apple-bce-drv](https://github.com/t2linux/apple-bce-drv)
- Touchbar and Ambient Light [https://github.com/t2linux/apple-ib-drv](https://github.com/t2linux/apple-ib-drv)

## Guides and similar

Note that, if you are using one of the distributions listed above, you should follow their install guides rather than the ones listed under this section. However, they might still be important to gain a better general picture or to help with specific issues.

- List of Mac Model Identifiers on [everymac.com](https://everymac.com/systems/by_capability/mac-specs-by-machine-model-machine-id.html)
- Using Luks with the integrated keyboard [https://github.com/DimitriDokuchaev/GrubLuksUnlock](https://github.com/DimitriDokuchaev/GrubLuksUnlock)
- Adding macOS-like screenshot shortcuts to KDE Plasma [https://gist.github.com/networkException/5a68299accc1872749c86301c1449690](https://gist.github.com/networkException/5a68299accc1872749c86301c1449690)
- Disable thermal throttling (better performance but higher temperatures) [https://github.com/yyearth/turnoff-BD-PROCHOT](https://github.com/yyearth/turnoff-BD-PROCHOT)
- Install a distribution in a virtual machine and copy it to bare metal afterwards [https://gist.github.com/Redecorating/c876a4c3b24e47d79c1f921495f62213](https://gist.github.com/Redecorating/c876a4c3b24e47d79c1f921495f62213) (using Pop!_OS as an example)
- Get SMART information of your Apple Internal SSD using Linux [https://gist.github.com/AdityaGarg8/b03e57826213019fbffa747e1c724cac](https://gist.github.com/AdityaGarg8/b03e57826213019fbffa747e1c724cac)
- Keyboard related issues [https://wiki.archlinux.org/title/Apple_Keyboard](https://wiki.archlinux.org/title/Apple_Keyboard)
- Get silent boot experience similar to macOS and Windows on [Ubuntu](https://gist.github.com/AdityaGarg8/a39063f0d8c39572f03f55cbe02f9beb) and [Arch Linux](https://wiki.archlinux.org/title/silent_boot).

*Outdated*

- State of Linux on the MacBook Pro (technical documentation) [https://github.com/Dunedan/mbp-2016-linux](https://github.com/Dunedan/mbp-2016-linux)
- Arch on 2018 MacBook Pro [https://gist.github.com/TRPB/437f663b545d23cc8a2073253c774be3](https://gist.github.com/TRPB/437f663b545d23cc8a2073253c774be3)
- Ubuntu on 16 inch, 2019 MacBook Pro [https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4)

# Notable Contributors

Check out the list of all Notable Contributors [here](https://wiki.t2linux.org/notable-contributors).
