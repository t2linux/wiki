# Introduction

Welcome to the t2linux wiki!

This wiki contains knowledge about running Linux on Macs with the T2 chip.
A list of those devices can be found [on Apple's website](https://support.apple.com/en-us/HT208862).

# Warnings

- Kernel versions newer than `5.7.19` are considered in-development builds and should not be used due to issues from within the kernel and the init system.
- It is highly recommended that you use the stock Apple boot manager for all distributions, other boot managers like rEFInd have been known to cause issues.

# Notable Resources

In general you can find most of the people involved on the [Linux on T2 Macs (2018+) Discord Server](https://discord.com/invite/68MRhQu), making it probably the most helpful and important resource of all.

## Distributions

Different distributions are maintained by different people in their own repositories.
Still more detailed or just different documentation about certain distributions might also be found [here](https://wiki.t2linux.org/distributions/manjaro/home/)

- Ubuntu [https://github.com/marcosfad/mbp-ubuntu](https://github.com/marcosfad/mbp-ubuntu)
- Fedora [https://github.com/mikeeq/mbp-fedora](https://github.com/mikeeq/mbp-fedora)
- Arch [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)
- Manjaro [https://github.com/JPyke3/mbp-manjaro](https://github.com/JPyke3/mbp-manjaro)

## Kernel Modules

Support for hardware is cross distro besides patches to the distribution specific kernel.
The following repos contain kernel modules for said support.

- MacBook Bridge / T2 Linux Driver [https://github.com/t2linux/apple-bce-drv](https://github.com/t2linux/apple-bce-drv)
- Touchbar and Ambient Light [https://github.com/t2linux/apple-ib-drv](https://github.com/t2linux/apple-ib-drv)

## Guides and similar

Note that if you are using one of the distributions listed above you should follow their install guides rather than the ones listed under this section. However they might still be important to gain a better general picture or to help with specific issues.

- State of Linux on the MacBook Pro [https://github.com/Dunedan/mbp-2016-linux](https://github.com/Dunedan/mbp-2016-linux)
- List of Mac Model Identifiers on [everymac.com](https://everymac.com/systems/by_capability/mac-specs-by-machine-model-machine-id.html)
- Using Luks with the intergrated keyboard [https://github.com/DimitriDokuchaev/GrubLuksUnlock](https://github.com/DimitriDokuchaev/GrubLuksUnlock)
- Patching and compiling a Kernel for T2 Devices [https://github.com/DimitriDokuchaev/PatchingAndBuildingLinuxKernel](https://github.com/DimitriDokuchaev/PatchingAndBuildingLinuxKernel)

*Outdated*

- Arch on 2018 MacBook Pro [https://gist.github.com/TRPB/437f663b545d23cc8a2073253c774be3](https://gist.github.com/TRPB/437f663b545d23cc8a2073253c774be3)
- Ubuntu on 2016 MacBook Pro [https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4](https://gist.github.com/gbrow004/096f845c8fe8d03ef9009fbb87b781a4)

# Notable Contributors

- aunali1 (Arch Linux and Kernel Module work) [https://github.com/aunali1](https://github.com/aunali1)
- MCMrARM (MacBook Bridge / T2 Linux Driver) [https://github.com/MCMrARM](https://github.com/MCMrARM)
- roadrunner2 (Touchbar and Ambient Light Driver) [https://github.com/roadrunner2](https://github.com/roadrunner2)
- mikeeq (Fedora) [https://github.com/mikeeq](https://github.com/mikeeq)
- marcosfad (Ubuntu) [https://github.com/marcosfad](https://github.com/marcosfad)
- JPyke3 (Manjaro) [https://github.com/JPyke3](https://github.com/JPyke3)

... and many more