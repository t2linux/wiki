# Download the latest safe release

Many thanks to [Mike](https://github.com/mikeeq/) for building. You can download a live iso from [here](https://github.com/t2linux/fedora-iso/releases).

# Hardware Requirements

-   USB-C to USB adapter. Important: different USB-C to USB adapters work differently - if you're stuck before getting to the graphical UI during boot this may be the problem.

# Install Procedure

1. Follow the [Pre-Install](https://wiki.t2linux.org/guides/preinstall) guide.
2. Click on *Share disk with other operating system*, then select *Reclaim additional space*.
3. Delete the partition you created using macOS for Linux.
4. Continue with the rest of the installation.
5. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
6. Welcome to Fedora! :)
7. Wi-Fi should work on first boot, but if it is not you should follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/).

## Installing unsupported spins

1. Follow the installation instructions above, but use your custom (vanilla) ISO. You need an external keyboard and mouse. If you do not have a wired internet connection, you need to follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) on the live ISO before proceeding.
2. Add our DNF repo: `sudo dnf copr enable sharpenedblade/t2linux`
3. Install the kernel: `sudo dnf swap --from-repo="copr:copr.fedorainfracloud.org:sharpenedblade:t2linux" kernel kernel`
4. Install other packages:
    - For interactive usage: `sudo dnf install t2linux-release`
    - For headless setups: `sudo dnf install t2linux-config t2linux-scripts t2fanrd`
