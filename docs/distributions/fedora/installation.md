# Download the latest safe release

Many thanks to [Mike](https://github.com/mikeeq/) for building. You can download a live ISO from [here](https://github.com/t2linux/fedora-iso/releases).

# Hardware Requirements

-   USB-C to USB adapter. Important: different USB-C to USB adapters work differently - if you're stuck before getting to the graphical UI during boot this may be the problem.

# Install Procedure

1. Follow the [Pre-Install](https://wiki.t2linux.org/guides/preinstall) guide. You can use the [t2linux Installer](https://github.com/sharpenedblade/t2linux-installer/releases/latest) app to download the ISO.
2. Click on *Share disk with other operating system*, then select *Reclaim additional space*.
3. Delete the partition you created using macOS for Linux.
4. Continue with the rest of the installation.
5. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.
6. Welcome to Fedora! :)
7. Wi-Fi should work on first boot, but if it does not, you should follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/).

## Installing unsupported spins

1. Follow the installation instructions above, but use your custom (vanilla) ISO. You need an external keyboard and mouse. If you do not have a wired internet connection, you need to follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) on the live ISO before proceeding.
2. Add our DNF repo: `sudo dnf copr enable sharpenedblade/t2linux`
3. Install the kernel: `sudo dnf swap --from-repo="copr:copr.fedorainfracloud.org:sharpenedblade:t2linux" kernel kernel`
4. Install other packages:
    - For interactive usage: `sudo dnf install t2linux-release`
    - For headless setups: `sudo dnf install t2linux-config t2linux-scripts t2fanrd`

## Installing atomic desktops

1. Create an rpm with the brcmfmac firmware bundle on macos [(guide)](https://wiki.t2linux.org/guides/wifi-bluetooth/#__tabbed_1_3).
2. Follow the installation instructions above, but use the upstream ISO. You need an external keyboard, mouse, and wired internet connection.
3. Download the repo file from the [sharpenedblade/t2linux](https://copr.fedorainfracloud.org/coprs/sharpenedblade/t2linux/) copr.
4. Move the repo file to `/etc/yum.repos.d`
5. Install the kernel: `sudo rpm-ostree override replace --from-repo="copr:copr.fedorainfracloud.org:sharpenedblade:t2linux" kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel-matched`
6. Install other packages:
    - For interactive usage: `sudo rpm-ostree install t2linux-release`
    - For headless setups: `sudo rpm-ostree install t2linux-config t2linux-scripts t2fanrd`
7. Copy the firmware rpm you created on macos, and install it with `sudo rpm-ostree install ./path/to/firmware.rpm`
8. Reboot
