# Introduction

This guide shall help you perform 2 tasks. Firstly you shall be able to set the correct label for your Linux startup disk on Mac startup manager and replace the `EFI Boot` label, and give it an icon. Secondly you shall be able to make Linux startup disk as the default startup disk in case you wish to do so.

The steps to perform the above tasks vary as per the way you have installed Linux, and thus check out the guide under the heading that applies to your case.

# Setting labels

## Setting label in case you are using the EFI partition available by default in Mac and are on a dual boot system

In this case, boot into macOS, open a terminal window and run:

```bash
sudo diskutil mount disk0s1
bless --folder /Volumes/EFI/EFI/BOOT --label "<YOUR DISTRO'S NAME>"
```

Replace `<YOUR DISTRO'S NAME>` with your distro's name. E.g.: If you are using Ubuntu, run:

```bash
sudo diskutil mount disk0s1
bless --folder /Volumes/EFI/EFI/BOOT --label "Ubuntu"
```

## Setting label in case you are using the same EFI partition for Windows and Linux

More details about this can be found in the [triple boot guide](https://wiki.t2linux.org/guides/windows/#using-the-same-efi-partition).

In this case the Windows startup disk is used to boot both Windows and Linux. Thus, it is not recommended to set special labels for Linux as it may cause errors with the Windows startup disk.

## Setting label in case you are using a seperate EFI partition for Linux

More details about this can be found in the [triple boot guide](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions).

In this case, boot into macOS, open a terminal window and run:

```bash
IDENTIFIER=$(diskutil info <NAME OF SEPERATE EFI PARTITION> | grep "Device Identifier" | cut -d: -f2 | xargs)
sudo diskutil mount $IDENTIFIER
bless --folder /Volumes/<NAME OF SEPERATE EFI PARTITION>/EFI/BOOT --label "<YOUR DISTRO'S NAME>"
```

Replace `<NAME OF SEPERATE EFI PARTITION>` with the label you set using in the above triple boot guide and `<YOUR DISTRO'S NAME>` with your distro's name. E.g.: If you are using Ubuntu and you set the label to `EFI2`, run:

```bash
IDENTIFIER=$(diskutil info EFI2 | grep "Device Identifier" | cut -d: -f2 | xargs)
sudo diskutil mount $IDENTIFIER
bless --folder /Volumes/EFI2/EFI/BOOT --label "Ubuntu"
```

# Setting the boot option icons in macOS Startup Manager

In case you are using the same EFI partition for Windows and Linux, then your Windows startup disk already has an icon. Thus you needn't set any boot icon.

In other cases, put an `icns` image file with your desired icon in the top directory of the disk that the bootloader of the menu entry is on, and call it `.VolumeIcon.icns`. It will now appear as that disk's boot option's icon.

# Setting Linux startup disk as the default startup disk

!!! warning
    In case you upgrade macOS to a newer version, the default startup disk gets changed to the macOS startup disk. Thus you will have to follow the instructions to make the Linux startup disk as default every time after you upgrade macOS.

## Case of common EFI partition for Windows and Linux

In this case you will have to set the Windows startup disk as the default startup disk. It is recommended to follow [Apple's documentation](https://support.apple.com/en-in/guide/mac-help/mchlp1034/mac) where you have to follow the **Change your startup disk for every startup** section.

If this method is not working for you, then follow the instructions given in [Case of seperate EFI partition for Linux as well as case of using the EFI partition available by default in Mac and are on a dual boot system](https://wiki.t2linux.org/guides/startup-manager/#case-of-seperate-efi-partition-for-linux-as-well-as-case-of-using-the-efi-partition-available-by-default-in-mac-and-are-on-a-dual-boot-system) section, where you have to consider the Windows startup disk as the Linux startup disk.

## Case of seperate EFI partition for Linux as well as case of using the EFI partition available by default in Mac and are on a dual boot system

In these cases, start your Mac and press and hold down the Option key. When the startup manager gets displayed, release the option key. Now press and hold the Control key and without releasing the Control key, boot into the Linux startup disk as you usually do. This will make it the default startup disk.
