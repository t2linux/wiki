# Introduction

This guide shall help you install the rEFInd Boot Manager in your T2 Mac in the safest possible way. Though there are various options to get rEFInd on your Mac, it is recommended to follow the instructions given below unless you know what you are doing.

# Installation

All steps given here have to be performed on **macOS**. You will also need to have [secure boot disabled](https://support.apple.com/en-us/HT208198).

1. With the help of disk utility, create a 100-200MB `MS-DOS FAT` partition and label it as `REFIND`.

2. Get a **binary zip file** of rEFInd from [here](https://www.rodsbooks.com/refind/getting.html).

3. The binary zip file of rEFInd shall be available in the downloads folder by the name of `refind-bin-<VERSION>.zip`, where `<VERSION>` represents the version of rEFInd you have downloaded. For eg:- If you have downloaded `0.13.2` version, it will be available as `refind-bin-0.13.2.zip`.

4. Extract the zip file (can be done by double clicking on it). The contents shall be extracted in a folder named `refind-bin-<VERSION>`. Here `<VERSION>` means the same as described in step 3.

5. Open the terminal and run `diskutil list` to get the disk identifier of the `REFIND` volume created in step 1. A sample output is given below:-

    ```plain
    /dev/disk0 (internal, physical):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      GUID_partition_scheme                        *500.3 GB   disk0
    1:                        EFI ⁨EFI⁩                     314.6 MB   disk0s1
    2:                 Apple_APFS ⁨Container disk1⁩         284.0 GB   disk0s2
    3:       Microsoft Basic Data ⁨Windows⁩                 215.9 GB   disk0s3
    4:       Microsoft Basic Data ⁨REFIND⁩                  103.8 MB   disk0s4
    
    /dev/disk1 (synthesized):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      APFS Container Scheme -                      +284.0 GB   disk1
                                    Physical Store disk0s2
    1:                APFS Volume ⁨macOS⁩                   15.3 GB    disk1s1
    2:              APFS Snapshot ⁨com.apple.os.update-...⁩ 15.3 GB    disk1s1s1
    3:                APFS Volume ⁨macOS - Data⁩            33.9 GB    disk1s2
    4:                APFS Volume ⁨Preboot⁩                 567.1 MB   disk1s3
    5:                APFS Volume ⁨Recovery⁩                626.1 MB   disk1s4
    6:                APFS Volume ⁨VM⁩                      20.5 KB    disk1s5
    ```
  
    Here, the disk indentifier of `REFIND` volume is `disk0s4`.

6. Now run the following in the terminal. Make sure you replace `disk0s4` (found in 4th, 5th, 6th and 7th line of the command given below) with the disk identifier you got in the output as described in step 5 and `refind-bin-0.13.2` (found in 1st line of the command given below) with the name of folder which was created in step 4.

    ```plain
    cd ~/Downloads/refind-bin-0.13.2
    xattr -rd com.apple.quarantine .
    sed -i '' "s/sed -i 's/sed -i '' 's/g" refind-install
    diskutil unmount disk0s4
    sudo ./refind-install --usedefault /dev/disk0s4
    diskutil unmount disk0s4
    diskutil mount disk0s4
    sudo rmdir /tmp/refind_install
    ```

7. Now run:-
  
    ```plain
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

In case you boot an OS other than macOS using rEFInd, it shows some debug text while booting it. In order to get a smooth boot experience simiar to the Mac Startup Manager, add the following line to `EFI/BOOT/refind.conf`, just as you did to remove BIOS entries.

```plain
use_graphics_for osx,linux,windows,grub
```

## Preventing use of NVRAM (Likely to have been enabled already)

Preventing use of NVRAM is must as T2 doesn’t like someone to touch the NVRAM. In latest editions of rEFInd, preventing use of NVRAM is enabled by default. You may confirm this by checking presence of `use_nvram false` line somewhere in the middle of the `refind.conf` file (the one mentioned in above instructions). Make sure it is not commented (doesn’t have a `#` before the line). If it is then remove the `#`.

In case the line is missing, add it at the end of `refind.conf` file.

In case the line `use_nvram true` is present instead, change `true` to `false`.

# Making rEFInd default at startup

After correctly installing and configuring rEFInd, we need to make it boot by default on every startup. In order to do so, restart your Mac and press and hold down the **Option** key. When the startup manager gets displayed, release the Option key. Now press and hold the **Control** key and without releasing the Control key, boot into the **rEFInd startup disk**. Now on every startup, rEFInd will get displayed by default.

Note :- This step has to be performed every time you update macOS to a newer version, as this makes the macOS startup disk as the default startup disk.

# Fixing blank screen on booting macOS using rEFInd

Sometimes, while booting into macOS using rEFInd, users get stuck at a blank screen. This bug is observed only if you have performed a force/unsafe shutdown by pressing and holding the power button in the previous boot. Some users have also faced it in the first macOS boot using rEFInd on new rEFInd installations. In order to fix it, turn off your Mac and restart while holding down the **Option** key. Release the Option key when the Mac Startup Manager gets displayed. Boot into macOS using the Mac Startup Manager. This shall fix the bug for subsequent boots.

# Uninstalling rEFInd

In case you wish to uninstall rEFInd, boot into **macOS** and follow the steps below :-

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
