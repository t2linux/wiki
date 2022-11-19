# Introduction

This page describes how to use the iGPU on MacBookPro's with Hybrid Graphics (2 GPUs). 13 inch MacBooks only have an iGPU, and do not need this. Using the iGPU means you can save power by turning off the more powerful AMD dGPU when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

## Issues

1. Resume after suspend is broken, as the GMUX (graphics multiplexer) doesn't connect the iGPU to the display after resuming. For this to be fixed, a Linux driver for `acpi:APP000B:GPUC:` needs to be written (macOS uses AppleMuxControl2.kext). The extra battery life may make this a worthwhile trade-off (about 3 hours to almost 6 hours on a MacBookPro16,1)

2. If using `DRI_PRIME=1` on programs causes system crashes, with "[CPU CATERR](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e#gistcomment-3719941)" problem reports in macOS, disable dynamic power management with the `amdgpu.dpm=0` kernel argument, or `echo high | sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level`.

3. If apple-set-os is loaded, the iGPU will control display brightness, and if the iGPU isn't the boot gpu, the i915 Intel graphics driver will not load, and the display brightness cannot be changed (The exception to this is sometimes when rebooting from macOS Recovery etc, i915 loads fine).

4. Some users with MacBookPro16,1 and AMD gpu have reported issues like AMD gpu uses too much power with excessive high temperatures under normal conditions or sudden high speed fan noise then instant system shut down, getting the T2 chip reset.

    Posible workarounds:

    1. Set iGPU as main gpu.

    2. Set AMD gpu Dynamic Power Management from auto to low or high. Low can be safer option to void thermal issues or safe battery.

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

    3.  Press any key other than `z` or wait, and it should boot you into Linux. If you want a silent version of this that doesn't wait for input, you can use [this fork](https://github.com/Redecorating/apple_set_os-loader). Your display brightness controls may stop working, this is temporary.

    4.  `lspci -s 00:02.0` should list an Intel Graphics card. If it doesn't have the Intel card, then the next step will not work.

3.  Set the `gpu-power-prefs` NVRAM variable to make the iGPU the Boot GPU and install the apple-gmux driver.

    1.  Check `journalctl -k --grep=efi:`, if you don't have "efi: Apple Mac detected, using EFI v1.10 runtime services only" then you will need update your kernel (preferred) or refer this [older version](https://github.com/t2linux/wiki/blob/eb15b19c7e4d5ce79a59ff14a4bf4297a5f65edc/docs/guides/hybrid-graphics.md#enabling-the-igpu) of this page.

    2.  If `cat /proc/cmdline` has `efi=noruntime`, remove it from the kernel command line by editing and regenerating your bootloader config (the issue it was avoiding is fixed by newer kernels).

    3.  Install the `gpu-switch` script, and then you can set NVRAM and the boot GPU from Linux.

        ```sh
        curl https://raw.githubusercontent.com/0xbb/gpu-switch/master/gpu-switch > gpu-switch
        chmod +x gpu-switch
        sudo chown root:root gpu-switch
        sudo mv gpu-switch /usr/local/bin/
        sudo gpu-switch -i
        ```

    4.  Install the apple-gmux driver from [here](https://github.com/Redecorating/apple-gmux-t2).

    5.  Reboot into Linux. Display brightness should be working again if it wasn't, and `glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMDGPU (some things do this automatically). You will get more battery time now as your AMD GPU can be turned off when not needed.

!!! note
    As macOS expects the dedicated GPU to be activated at startup, to avoid various display and GPU related problems (like not outputting anything to the display after sleep), switch to the dedicated GPU using `sudo gpu-switch -d` before booting into MacOS.
    Because of this, if you want to use Linux with the iGPU again, you'll need to re run `sudo gpu-switch -i` on your Linux install and **reboot**.

## MacBookPro16,4

The AMD GPU on MacBookPro16,4 is not yet compatible with Linux. As a workaround :-

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

5. Install the apple-gmux driver from [here](https://github.com/Redecorating/apple-gmux-t2).

6. Reboot and in the grub menu, select "Enable iGPU". Your computer will shutdown. Power it back on and boot linux. If you boot macOS, this will be reset and you'll have to redo this step.

7. You can now remove the `nomodeset` parameter from your command line.

### If you are unable to edit your kernel command line :-

1. Boot into macOS and mount your Linux EFI partition over there. In most cases it should be `disk0s1` and can be mounted by running `sudo diskutil mount disk0s1` in the terminal. If you are using a separate EFI partition, the you can run `diskutil list` and find your partition in the output, and mount it accordingly.

2. Install apple-os-set loader from [here](https://github.com/Redecorating/apple_set_os-loader) using macOS in your Linux EFI partition.

3. Restart into macOS Recovery by immediately pressing and holding Command+R on startup. Open the terminal there and run `nvram fa4ce28d-b62f-4c99-9cc3-6815686e30f9:gpu-power-prefs=%01%00%00%00`.

4. Restart into Linux. You should now be able to access your Linux installation.

5. Its recommended to use GRUB as a bootloader. If you wish to use some other bootloader, you need to figure out how to get the steps requiring GRUB given further working with your bootloader.

6. Follow steps 4, 5 and 6 of the [If you are able to edit your kernel command line](https://wiki.t2linux.org/guides/hybrid-graphics/#if-you-are-able-to-edit-your-kernel-command-line-) section.

## Use on Windows

In one case (has anyone else tried this?), the iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers. There might be special iGPU drivers in the Bootcamp support software for single GPU MacBooks, which might help resolve this.

If you want to use the iGPU on Linux but not on Windows, you can switch back to the dGPU with `sudo gpu-switch -d` before booting to Windows.

If you want to switch GPU from Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
