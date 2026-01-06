# Introduction

rEFInd is an **optional** UEFI boot manager and an alternative to GRUB. It provides a graphical interface for selecting an operating system at startup.

**Benefits:**

- Allows you to choose your operating system on every startup, eliminating the hassle of holding the Option (⌥) key during startup.
- Directly boots both Linux and macOS, which is useful for dual-booting.
- Can resolve specific boot issues that other loaders struggle with.
- Some users find it faster than other boot loaders.

This guide helps you install the rEFInd Boot Manager in your T2 Mac in the safest possible way. Though there are various options to get rEFInd on your Mac, it is recommended to follow the instructions given below unless you know what you are doing.

# Installation

All steps given here have to be performed on **macOS**. You will also need to have [secure boot disabled](https://support.apple.com/en-us/HT208198).

1. With the help of disk utility, create a 100-200MB `MS-DOS FAT` partition and label it as `REFIND`.

2. Get a **binary zip file** of rEFInd from [here](https://www.rodsbooks.com/refind/getting.html).

3. The binary zip file of rEFInd shall be available in the downloads folder by the name of `refind-bin-<VERSION>.zip`, where `<VERSION>` represents the version of rEFInd you have downloaded, e.g.: if you have downloaded `0.13.2` version, it will be available as `refind-bin-0.13.2.zip`.

4. Now run the following in the terminal:

    ```bash
    IDENTIFIER=$(diskutil info REFIND | grep "Device Identifier" | cut -d: -f2 | xargs)
    cd ~/Downloads
    unzip refind-bin*
    rm refind-bin*.zip
    cd refind-bin*
    xattr -rd com.apple.quarantine .
    sed -i '' "s/sed -i 's/sed -i '' 's/g" refind-install
    diskutil unmount $IDENTIFIER
    sudo ./refind-install --usedefault /dev/$IDENTIFIER
    diskutil unmount $IDENTIFIER
    diskutil mount $IDENTIFIER
    sudo rmdir /tmp/refind_install
    rm -r ~/Downloads/refind-bin*
    ```

5. Now run:
  
    ```bash
    bless --folder /Volumes/REFIND/EFI/BOOT --label rEFInd
    ```
  
    This will change the label in the Mac Startup Manager for rEFInd from `EFI Boot` to `rEFInd`.
  
# Configuration

Though rEFInd has many configuration options, some basic configuration is required for a smoother experience on T2 Macs.

## Removing BIOS entries

Macs with T2 chip cannot BIOS boot. So it is advised to remove the BIOS entries. For that, open finder, and then open the `REFIND` volume. Add the line given below at the end of `EFI/BOOT/refind.conf` file by editing it with a text editor.

```plain
scanfor internal,external,optical,manual
```

In case you face the error saying **The document “refind.conf” could not be saved.**, copy the `refind.conf` file to any place in your home directory (Downloads folder for example) and do the editing over there. After editing replace the `refind.conf` file in the `REFIND` volume with the newly edited file.

## Hiding text on booting an OS using rEFInd (Optional)

In case you boot an OS other than macOS using rEFInd, it shows some debug text while booting it. In order to get a smooth boot experience similar to the Mac Startup Manager, add the following line to `EFI/BOOT/refind.conf`, just as you did to remove BIOS entries.

```plain
use_graphics_for osx,linux,windows,grub
```

## Preventing use of NVRAM (Likely to have been enabled already)

Preventing use of NVRAM is must as T2 doesn’t like someone to touch the NVRAM. In latest editions of rEFInd, preventing use of NVRAM is enabled by default. You may confirm this by checking presence of `use_nvram false` line somewhere in the middle of the `refind.conf` file (the one mentioned in above instructions). Make sure it is not commented (doesn’t have a `#` before the line). If it is then remove the `#`.

In case the line is missing, add it at the end of `refind.conf` file.

In case the line `use_nvram true` is present instead, change `true` to `false`.

# Making rEFInd default at startup

After correctly installing and configuring rEFInd, we need to make it boot by default on every startup. In order to do so, restart your Mac and press and hold down the **Option (Alt)** key. When the startup manager gets displayed, release the Option key. Now press and hold the **Control** key and without releasing the Control key, boot into the **rEFInd startup disk**. Now on every startup, rEFInd will get displayed by default.

!!! warning
    This step has to be performed every time you update macOS to a newer version, as this makes the macOS startup disk as the default startup disk.

# Fixing blank screen on booting macOS using rEFInd

Sometimes, while booting into macOS using rEFInd, users get stuck at a blank screen. This bug is observed only if you have performed a force/unsafe shutdown by pressing and holding the power button in the previous boot. Some users have also faced it in the first macOS boot using rEFInd on new rEFInd installations. In order to fix it, turn off your Mac and restart while holding down the **Option (Alt)** key. Release the Option key when the Mac Startup Manager gets displayed. Boot into macOS using the Mac Startup Manager. This shall fix the bug for subsequent boots.

# Using rEFInd as a replacement for GRUB, systemd-boot etc.

By default, rEFInd boots Linux indirectly by booting GRUB, systemd-boot etc. But we can also boot linux directly by using rEFInd. This can be useful in situations where other bootloaders are causing issues. In order to do so, follow the following steps:

1. Boot into Linux using the bootloader currently in use. If the bootloader is facing issues, you may also chroot into the installation using your distro's ISO and run the commands within the chroot.

2. Get a **binary zip file** of rEFInd from [here](https://www.rodsbooks.com/refind/getting.html).

3. The binary zip file of rEFInd shall be available in the downloads folder by the name of `refind-bin-<VERSION>.zip`, where `<VERSION>` represents the version of rEFInd you have downloaded, e.g.: If you have downloaded `0.13.2` version, it will be available as `refind-bin-0.13.2.zip`.

4. Move the zip into the `/boot` folder. If you are chrooting, the move the zip into the `/boot` folder of the **chroot**.

5. Now run:

    ```bash
    cd /boot
    sudo unzip refind-bin*
    sudo rm refind-bin*.zip
    cd refind-bin*
    sudo ./mkrlconf
    sudo sed -i 's/"Boot to single-user mode"/#"Boot to single-user mode"/g' /boot/refind_linux.conf
    sudo sed -i 's/"Boot with minimal options"/#"Boot with minimal options"/g' /boot/refind_linux.conf
    sudo rm -r /boot/refind-bin*
    ```

6. A file named `refind_linux.conf` shall be made in your **/boot** folder of your installation. A sample of this is given below.

    ```conf
    "Boot with standard options"  "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e"
    #"Boot to single-user mode"    "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e single"
    #"Boot with minimal options"   "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e"
    ```
  
    !!! note "Chroot"
        If you have run the in step 5 commands within a chroot, the `ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e` shall likely to be missing. In this case, manually edit the `refind_linux.conf` file in the `/boot` folder of your **chroot** to look like the sample and replace the **UUID** (`631c326a-fb48-46ba-b4aa-6dd2033fbb5e` in the sample) with the one of the partition in which your Linux is installed. You can get the UUID from `/etc/fstab` file of your **chroot** or using a disk utility software.

7. On the line with `"Boot with standard options"`, add the `intel_iommu=on iommu=pt pcie_ports=compat quiet splash` parameters. It is possible that some parameters are already added. In such case, add only the missing parameters. If you don't want a silent boot, you may omit out the `quiet splash` parameter. Finally, the `refind_linux.conf` file should look something like this.

    ```conf
    "Boot with standard options"  "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e intel_iommu=on iommu=pt pcie_ports=compat quiet splash"
    #"Boot to single-user mode"    "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e single"
    #"Boot with minimal options"   "ro root=UUID=631c326a-fb48-46ba-b4aa-6dd2033fbb5e"
    ```

8. Now, when you shall be in rEFInd, it should show an entry with the path of the image of your kernel and shall most probably have the icon of the Linux Penguin. That entry shall be the one which shall boot Linux directly using rEFInd.

9. If you want to use your distro's icon instead of Linux Penguin one, you may label the volume containing your kernel with the name of your distro. Following are some examples of commands for various filesystems, taking the distro as **Ubuntu** and partition in which kernel is in as `/dev/nvme0n1p3`.

    1. ext2, ext3 or ext4:
  
        ```bash
        sudo tune2fs -L "Ubuntu" /dev/nvme0n1p3
        ```
  
    2. btrfs:
  
        ```bash
        MOUNTPOINT=$(findmnt -n -o TARGET /dev/nvme0n1p3)
        sudo btrfs filesystem label $MOUNTPOINT "Ubuntu"
        ```
  
    More ways to set custom icons are described [here](https://www.rodsbooks.com/refind/configfile.html#icons).

# Uninstalling rEFInd

In case you wish to uninstall rEFInd, boot into **macOS** and follow the steps below:

1. Open the Disk Utility
2. Select the partition on which macOS is installed (it generally has the label `Macintosh HD` until you have renamed it manually).
3. Click on **Partition**.
4. Select the `REFIND` partition and click `-` to remove it. Your macOS partition should expand to fill the space that rEFInd was in.
5. Click on **Apply**. Disk Utility will remove the `REFIND` partition and expand your macOS partition. This may take a while, but **do not interrupt this process**.
6. Change the default startup disk to the OS you wish to be boot by default.
  
   If the OS you wish is **macOS** or **Windows**, follow [Apple's documentation](https://support.apple.com/en-in/guide/mac-help/mchlp1034/mac) where you have to follow the **Change your startup disk for every startup** section.
  
   If the OS you wish is **Linux**, follow the [Startup Manager Guide](https://wiki.t2linux.org/guides/startup-manager/#setting-linux-startup-disk-as-the-default-startup-disk).
  
# References and External links

[Reference](https://apple.stackexchange.com/questions/402289/refind-installation-wont-boot-due-to-t2-security-despite-t2-security-being-dis) - This guide has been inspired from here.

[rEFInd](https://www.rodsbooks.com/refind/) - Official website of rEFInd.

[Theming rEFInd](https://www.rodsbooks.com/refind/themes.html) - Useful guide to set custom themes for rEFInd.
