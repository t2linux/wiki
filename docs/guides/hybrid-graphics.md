# Introduction

This page describes how to use the iGPU, dGPU, or both. 13 inch MacBooks only have an iGPU, and do not need this. Using the iGPU means you can save power by putting the more powerful AMD dGPU in a low power state when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too. Make sure you have a t2 kernel of version greater than 6.1.12-2 (you can check this with `uname -r`).

## Enabling the iGPU

1.  Set up `apple-set-os-loader` to show the iGPU to linux:

    1.  Download apple-set-os-loader from [here](https://github.com/Redecorating/apple_set_os-loader/releases/tag/r33.9856dc4). You need to download the `bootx64.efi` file. 
    
        !!! Info "Silent Boot"
            If you want a silent version of this that doesn't wait for input, you can download the `bootx64_silent.efi` file instead.
        
    2. Copy apple-set-os-loader to the ESP. These instructions assume you mount your EFI partition at `/boot/efi`. If you mount the EFI partition somewhere else or use refind, you will need to replace /boot/efi with the mount point of the partition in which your bootloader is installed.

        ```sh
        sudo mv /boot/efi/EFI/BOOT/BOOTX64.efi /boot/efi/EFI/BOOT/bootx64_original.efi
        sudo cp ~/Downloads/bootx64*.efi /boot/efi/EFI/BOOT/BOOTX64.efi
        ```

2.  Configure the kernel to switch to the iGPU at boot

    Create `/etc/modprobe.d/apple-gmux.conf` with the following contents:

    ```plain
    # Enable the iGPU by default if present
    options apple-gmux force_igd=y
    ```


3.  Reboot to Linux

    1. Wait or press any key other than `z`


    2. `glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMD GPU (some things do this automatically). You will get more battery life now as your AMD GPU can be turned off when not needed.

    
# Setting AMD GPU Dynamic Power Management manually

    !!! Warning
        You should only use the `low` mode if you experience loud fans, excessive heat, or a very short battery life. If you want better performance for gaming and other GPU intensive tasks, then you should use the `high` mode.
        
    To apply the desired power mode, create the file `/etc/udev/rules.d/30-amdgpu-pm.rules` with the following contents (replace `MODE GOES HERE` with `high` or `low`):
    
    ```plain
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="MODE GOES HERE"
     ```

## MacBookPro16,4

Currently the Radeon 5600M AMD GPU on MacBookPro16,4 is [not working](https://lore.kernel.org/all/3AFB9142-2BD0-46F9-AEA9-C9C5D13E68E6@live.com/) with Linux. As a workaround:

1. Edit the kernel command line of when booting and add the `nomodeset` kernel parameter. This will enable you to access your Linux system in safe graphics mode.

2. Follow the instructions [above](#enabling-the-igpu).

3. You can now remove the `nomodeset` parameter from your kernel command line.

## Use on Windows

The iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers.

If you want to switch GPU for Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
