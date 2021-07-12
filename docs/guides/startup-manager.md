# Introduction

This guide shall help you to perform 2 tasks. Firstly you shall be able to set the correct label for your linux startup disk after installation on Mac startup manager and replace the EFI Boot label. Secondly you shall be able to make linux startup disk as the default startup disk in case you wish to do so.

The steps to perform the above tasks vary as per the way you have installed linux, and thus check out the guide under the heading that applies to your case.

# Setting labels

## Setting label in case you are using the EFI partition available by default in Mac and are on a dual boot system.

In this case, boot into macOS, open a terminal window and run :-

`bless --folder /Volumes/EFI/EFI/BOOT --label <YOUR DISTRO'S NAME>`.

Replace `<YOUR DISTRO'S NAME>` with your distro's name. Eg :- If you are using Ubuntu, run :-

`bless --folder /Volumes/EFI/EFI/BOOT --label Ubuntu`

## Setting label in case you are using the same EFI partition for Windows and Linux.

More details about this can be found on the [triple boot guide](https://wiki.t2linux.org/guides/windows/)

In this case the Windows startup disk is used to boot both Windows and Linux. Thus, it is not recommended to set special labels for Linux as it may cause errors with the Windows startup disk.

## Setting label in case you are using a seperate EFI partition for Linux.

More details about this can be found on the [triple boot guide](https://wiki.t2linux.org/guides/windows/#using-seperate-efi-partitions)

In this case, boot into macOS, open a terminal window and run :-

`bless --folder /Volumes/<NAME OF SEPERATE EFI PARTITION>/EFI/BOOT --label <YOUR DISTRO'S NAME>`.

Replace `<NAME OF SEPERATE EFI PARTITION>` with the label you set using in the above triple boot guide and `<YOUR DISTRO'S NAME>` with your distro's name. Eg :- If you are using Ubuntu and you set the label to `EFI2`, run :-

`bless --folder /Volumes/EFI2/EFI/BOOT --label Ubuntu`

# Setting Linux startup disk as the default startup disk

## Case of common EFI partition for Windows and Linux

In this case you will have to set the Windows startup disk as the default startup disk. It is recommended to follow [Apple's documentation](https://support.apple.com/en-in/guide/mac-help/mchlp1034/mac) where you have to follow the 'Change your startup disk for every startup' section.

If this method is not working for you, then follow the instruction given in 'Case of seperate EFI partition section for Linux as well as using the EFI partition available by default in Mac and are on a dual boot system' where you have to consider the Windows startup disk as the Linux startup disk.

## Case of seperate EFI partition section for Linux as well as case of using the EFI partition available by default in Mac and are on a dual boot system.

In this case, start your Mac and press and hold down the Option key. Until the startup manager gets displayed. Now press and hold the Control key and without releasing the Control key, boot into the linux startup disk as you usually do. This will make it the default startup disk.
