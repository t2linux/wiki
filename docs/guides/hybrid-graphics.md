# Introduction

This page describes how to use the iGPU on MacBookPro's with Hybrid Graphics (2 GPUs). 13 inch MacBooks only have an iGPU, and do not need this. Using the iGPU means you can save power by turning off the more powerful AMD dGPU when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

Make sure you have a t2 kernel of version greater than 6.2 (you can check this with `uname -r`).

## Issues

If you experience system freezes, then the laptop's fans becoming loud, before the whole computer shuts off (CPU CATERR), or if the amdgpu is making the computer too hot, consider trying:

1.  Set iGPU as main gpu.

2.  Set AMD gpu Dynamic Power Management from auto to low or high. Low can be safer option to void thermal issues or safe battery.

    You can test it quickly with: `echo low | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level`

    To apply the low level permanently, create `/etc/udev/rules.d/30-amdgpu-pm.rules` file with the following contents:

    ```plain
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
    ```

    To check card0 is the amdgpu, we can run:

    ```sh
    udevadm info --attribute-walk /sys/class/drm/card0 | grep "amdgpu"
    result: DRIVERS=="amdgpu"
    ```

    You can also control the AMD gpu DMP with GUI tools such as [radeon-profile](https://github.com/emerge-e-world/radeon-profile). For GPU intensive tasks like play Games, Machine Learning or Rendering, you can try setting the DPM to high.

## Enabling the iGPU

!!! note
    Aside from step 1, these instructions should be followed in Linux.

1.  Update macOS. Big Sur and above can boot when the iGPU is set as the boot GPU, but this has not been tested on Catalina, and [on older MacBooks](https://github.com/Dunedan/mbp-2016-linux/issues/6#issuecomment-286200226), setting the iGPU as the boot GPU has stopped macOS from booting properly with graphics, and it is unknown when this was fixed (you might want to turn ssh on in macOS if you are worried about this).

2.  Set up apple-set-os-loader to make Apple's firmware show the iGPU

    1.  Compile apple-set-os loader. These instructions assume you have `gnu-efi` installed, and mount your EFI partition on `/boot/efi`. If you mount the EFI partition somewhere else or use refind, you will need to replace /boot/efi with the mount point of the partition in which your bootloader is installed.

        ```sh
        git clone https://github.com/aa15032261/apple_set_os-loader
        cd apple_set_os-loader
        make
        sudo mv /boot/efi/efi/boot/bootx64.efi /boot/efi/efi/boot/bootx64_original.efi
        sudo cp ./bootx64.efi /boot/efi/efi/boot/bootx64.efi
        ```

    2.  Reboot to Linux, you should see this at boot (the GPUs listed might be different):

        ```plain
        ================== apple_set_os loader v0.5 ==================
        SetOsProtocol Handle Count: 1
        AppleSetOs will be loaded, press Z to disable.
        
        ----------------------- Ready to boot ------------------------
        Plug in your eGPU then press any key.
        Booting bootx64_original.efi in 6 second(s)
        
        Connected Graphics Cards:
        1002 7340 AMD - Navi 14 [Radeon RX 5500/5500M]
        8086 3E9B INTEL - UHD Graphics 630 (Mobile)
        ```

    3.  Press any key other than `z` or wait, and it should boot you into Linux. If you want a silent version of this that doesn't wait for input, you can use [this fork](https://github.com/Redecorating/apple_set_os-loader).

    4.  `lspci -s 00:02.0` should list an Intel Graphics card. If it doesn't have the Intel card, then the next step will not work.

3.  Configue apple-gmux to switch to the IGPU at boot

    1.  Create `/etc/modprobe.d/apple-gmux.conf` with the following contents:

        ```plain
        # Enable the iGPU by default if present
        options apple-gmux force_igd=y
        ```

    2.  Reboot into Linux.

`glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMDGPU (some things do this automatically). You will get more battery time now as your AMD GPU can be turned off when not needed.

## MacBookPro16,4

The AMD GPU on MacBookPro16,4 is [not compatible](https://lore.kernel.org/all/3AFB9142-2BD0-46F9-AEA9-C9C5D13E68E6@live.com/) with Linux. As a workaround :-

### If you are able to edit your kernel command line :-

1. This workaround recommends GRUB as the bootloader. If you want to use some other bootloader, you need to figure out how to get an equivalent of step 4 and 6 working with your bootloader.

2. Edit the command line of your boot and add the `nomodeset` kernel parameter the the command line. This will enable you to access your Linux system in safe graphics.

3. Boot into Linux and install apple-os-set loader from [here](https://github.com/Redecorating/apple_set_os-loader).

4. Setup this tool to allow changing the boot GPU from GRUB:

    ```sh
    git clone https://github.com/Redecorating/efi-gpu-power-prefs
    cd efi-gpu-power-prefs
    make #you will need efi.h to compile this, which is installed in the gnu-efi package in most distros
    make install
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ```

5. Reboot and in the grub menu, select "Enable iGPU". Your computer will shutdown. Power it back on and boot linux. If you boot macOS, this will be reset and you'll have to redo this step.

6. You can now remove the `nomodeset` parameter from your command line.

### If you are unable to edit your kernel command line :-

1. Boot into macOS and mount your Linux EFI partition over there. In most cases it should be `disk0s1` and can be mounted by running `sudo diskutil mount disk0s1` in the terminal. If you are using a separate EFI partition, the you can run `diskutil list` and find your partition in the output, and mount it accordingly.

2. Install apple-os-set loader from [here](https://github.com/Redecorating/apple_set_os-loader) using macOS in your Linux EFI partition.

3. Restart into macOS Recovery by immediately pressing and holding Command+R on startup. Open the terminal there and run `nvram fa4ce28d-b62f-4c99-9cc3-6815686e30f9:gpu-power-prefs=%01%00%00%00`.

4. Restart into Linux. You should now be able to access your Linux installation.

5. Its recommended to use GRUB as a bootloader. If you wish to use some other bootloader, you need to figure out how to get the steps requiring GRUB given further working with your bootloader.

6. Follow steps 4, 5 and 6 of the [If you are able to edit your kernel command line](https://wiki.t2linux.org/guides/hybrid-graphics/#if-you-are-able-to-edit-your-kernel-command-line-) section.

## Use on Windows

The iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers.

If you want to switch GPU for Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
