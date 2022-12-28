# Introduction

This guide shall help you in installing a Debian or Ubuntu based Linux distro, which is not available as a modified ISO with T2 support.

Some popular distros include :-

1. [Linux Mint](https://linuxmint.com/)
2. [Pop!_OS](https://pop.system76.com/)
3. [elementary OS](https://elementary.io/)
4. [Debian](https://www.debian.org/)
5. [Zorin OS](https://zorin.com/)
6. [Kali Linux](https://www.kali.org/)
7. Other Ubuntu flavours like [Kubuntu](https://kubuntu.org/), [Ubuntu unity](https://ubuntuunity.org/) etc.

# Hardware Requirements

* USB-C to USB adapter
* Wired internet connection (Ethernet/USB tethering) or Wi-Fi adapter compatible with Linux
* External keyboard and mouse

# Install Procedure

!!! Warning "Installation fails when installing the bootloader (Eg :- GRUB)"
    It is possible that during installation, when the installer is installing the bootloader (GRUB in most cases), the installation may fail. This is because the distro's ISO is using an old Linux kernel which doesn't support writing to the NVRAM of T2 Macs. In such a case, boot into the ISO again. When the initial menu gets displayed having options to try/install the distro, press "e" on the option you otherwise would have chosen to install. This will open the command line. Add `efi=noruntime` to the command line and press "F10" to boot. This should fix the issue.

!!! Warning "Pop!_OS"
    Due to a bug in Pop!_OS installer, the partition sizes shown by it are incorrect during manual partitioning step. As a workaround you may follow the instructions given in this [GitHub issue](https://github.com/elementary/installer/issues/620) in the live ISO environment to fix the installer and then start the installation.

1. Follow the [Pre-installation](https://wiki.t2linux.org/guides/preinstall) steps to prepare your Mac for installation.
2. Boot into the Live ISO. You should now be in the GRUB boot menu. Select the option which is relevent to you.
3. Start the installer and install it like normal until you get an option to manually specify partitions.
4. Find the partition you made for Linux when you were following the Pre-installation steps. MAKE SURE TO SELECT THE RIGHT PARTITION OR ELSE YOUR DATA WILL BE LOST. Delete it to make free space. You'll need to make these partitions:

    1. If you want, you can make seperate partitions for **swap**, `/home`, `/boot` etc as you do in a normal PC.

    2. The partition to be made compulsorily is the one mounted at `/` and formatted to **ext4** or **btrfs**.

    3. If the installer used by your distro is `ubiquity`, which is the one used in Ubuntu, Linux Mint etc., then you can leave EFI Boot alone. If you are using a [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions), then you shall have to separate it out after installation by following [this guide](https://wiki.t2linux.org/guides/windows/#seperate-the-efi-partition-after-linux-is-installed).
  
       For other installers, you need to mount `nvme0n1p1`, or your [separate EFI partition](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions) (whatever case applies to you) at `/boot/efi`. If the installer supports the "boot￼" flag, set it as well for your EFI partition.

5. Continue the rest of the setup.
6. Once it's finished, you can reboot without your installation media. Hold down Option (⌥) while booting, then select EFI Boot and press enter.

# Adding T2 support

After installation, we need to install a kernel having patches to support the T2 Macs for the internal keyboard, trackpad, touchbar, audio, Wi-Fi etc. to work. In order to do so :-

1. Boot into your new installation.
2. Connect to the internet using Ethernet/USB tethering/external Wi-Fi adapter.
3. Add the **t2-ubuntu-repo** apt repo by running :-
  
   ```bash
   curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
   sudo curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
   sudo apt update
   ```
  
4. Now install the kernel upgrade script.
  
   * If your distro is Ubuntu based, run :-
  
   ```bash
   sudo apt install t2-kernel-script
   ```
  
   * If your distro is Debian based, run :-
  
   ```bash
   sudo apt install t2-kernel-script-debian
   ```
  
5. Then upgrade your kernel to a T2 kernel by running :-
  
   ```bash
   update_t2_kernel
   ```
  
6. Install the audio configuration files by running :-
  
   ```bash
   sudo apt install apple-t2-audio-config
   ```
  
   **Note :-** If your distro is using PulseAudio by default, consider switching to PipeWire as mention in the [audio guide](https://wiki.t2linux.org/guides/audio-config/#audio-configuration-files)

7. Follow the [Wi-Fi guide](https://wiki.t2linux.org/guides/wifi-bluetooth/) to get internal Wi-Fi working.

# Basic set up

After installing the new kernel, follow the [Basic setup](https://wiki.t2linux.org/guides/postinstall/) guide. You shall mainly have to follow the [Add necessary kernel parameters](https://wiki.t2linux.org/guides/postinstall/#add-necessary-kernel-paramaters) and [Make modules load on boot](https://wiki.t2linux.org/guides/postinstall/#make-modules-load-on-boot) sections. If using disk encryption (LUKS), then follow the [Make modules load on early boot](https://wiki.t2linux.org/guides/postinstall/#make-modules-load-on-early-boot) section as well. Rest have been set up automatically by the kernel upgrade script.
