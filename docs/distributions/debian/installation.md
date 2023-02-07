# Introduction

This guide will help you in installing a Debian or Ubuntu-based Linux distro that does not have a modified ISO with T2 support.

Some popular distros include:

* [Linux Mint](https://linuxmint.com/) (Ubuntu-based | Debian-based if using LMDE)
* [Pop!_OS](https://pop.system76.com/) (Ubuntu-based)
* [elementary OS](https://elementary.io/) (Ubuntu-based)
* [Debian](https://www.debian.org/) (Debian)
* [Zorin OS](https://zorin.com/) (Ubuntu-based)
* [Kali Linux](https://www.kali.org/) (Debian-based)
* Other Ubuntu flavours like [Kubuntu](https://kubuntu.org/), [Ubuntu Unity](https://ubuntuunity.org/) etc. (Ubuntu-based)

# Required Hardware

* USB-C to USB-A adapter

    May be required to connect various hardware (e.g. a wire to your phone, wireless Wi-Fi dongle etc.)

* Internet connection - either **wired** (using an USB Ethernet dongle or USB tethering from a phone) or **wireless** (using a Linux-compatible Wi-Fi adapter)

    The internal Wi-Fi does not work without the T2 kernel. Note that you will be able to setup internal Wi-Fi after you install and setup the T2 kernel. More on this later in the guide.

* External keyboard and mouse

    Required as the internal keyboard and trackpad do not work without the T2 kernel.

# Install Procedure

!!! Warning "Installation fails when installing the bootloader (e.g. GRUB)"
    It is possible that during installation, when the bootloader (GRUB in most cases) is being installed, the installation may fail. This is because the distro's ISO is using an old Linux kernel which doesn't support writing to the NVRAM of T2 Macs. In such a case, boot into the ISO again. When the initial menu gets displayed having options to try/install the distro, press "e" on the option you otherwise would have chosen to install. This will open the command line. Add `efi=noruntime` to the command line and press "F10" to boot. This should fix the issue.

!!! Warning "Pop!_OS incorrect partition sizes"
    Due to a bug in the Pop!_OS installer, the partition sizes shown by it are incorrect when using manual partitioning. As a workaround you may follow the instructions given in this [GitHub issue](https://github.com/elementary/installer/issues/620#issuecomment-1356978490) in the live ISO environment to fix the installer and then start the installation.

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for installation.
2. Boot into the Live ISO. In the GRUB boot menu, select the option relevant to you.
3. Start the installer and go through it like normal. Make sure to select **manual partitioning** instead of letting the installer automatically manage partitions for you!
4. **WARNING: MAKE SURE TO SELECT THE RIGHT PARTITION OR YOU MAY LOSE YOUR DATA.** Find the partition you made for Linux during the Pre-installation step and delete it to make free space. You'll need to make these partitions:

    1. You **must** create a **`/`** ("root") partition formatted as **ext4** or **btrfs**.

    2. You may opt to make separate partitions for **`/home`**, **`/boot`**, **swap** etc. as you would normally.

    3. If `ubiquity` is the installer used by your distro (used by *Ubuntu*, *Linux Mint* and other similar distros), then you can leave EFI Boot alone. If you are using a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions), then you shall have to separate it out after installation by following [this guide](https://wiki.t2linux.org/guides/windows/#seperate-the-efi-partition-after-linux-is-installed).
  
        For other installers, you need to mount `nvme0n1p1`, or your [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions) (whatever case applies to you) at `/boot/efi`. If the installer supports the `boot` flag, set it as well for your EFI partition.

5. Continue with the rest of the installation.
6. Once it's finished, reboot. You may remove your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.

# Adding T2 support

After installation, you need to install a kernel with patches with T2 support (needed for the internal keyboard, trackpad, touchbar, audio, Wi-Fi etc. to work).

Steps:

1. Boot into your new installation.

2. Connect to the internet using Ethernet / USB tethering / an external Wi-Fi adapter.

3. Add the **t2-ubuntu-repo** apt repo by running:

    ```bash
    curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
    sudo curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
    sudo apt update
    ```
  
4. Now install the kernel upgrade script.
  
    * If your distro is Ubuntu-based, run:
  
       ```bash
       sudo apt install t2-kernel-script
       ```
  
    * If your distro is Debian-based, run:
  
       ```bash
       sudo apt install t2-kernel-script-debian
       ```
  
5. Then upgrade your kernel to a T2 kernel by running:
  
    ```bash
    update_t2_kernel
    ```
  
6. Install the audio configuration files by running:
  
    ```bash
    sudo apt install apple-t2-audio-config
    ```
  
    **Note:** If your distro is using PulseAudio by default, consider switching to PipeWire as mentioned in the [audio guide](https://wiki.t2linux.org/guides/audio-config/#audio-configuration-files).

7. Follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) to get internal Wi-Fi working.

# Basic set up

After installing the new kernel, follow the [Basic setup](https://wiki.t2linux.org/guides/postinstall/) guide. You mainly have to follow the [Add necessary kernel parameters](https://wiki.t2linux.org/guides/postinstall/#add-necessary-kernel-paramaters) and [Make modules load on boot](https://wiki.t2linux.org/guides/postinstall/#make-modules-load-on-boot) sections. If using disk encryption (LUKS), then follow the [Make modules load on early boot](https://wiki.t2linux.org/guides/postinstall/#make-modules-load-on-early-boot) section as well. The rest has been set up automatically by the kernel upgrade script.
