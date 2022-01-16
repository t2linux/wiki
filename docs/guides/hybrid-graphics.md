# Introduction

This page describes how to use the iGPU on MacBookPro's with Hybrid Graphics (2 GPUs). 13 inch MacBooks only have an iGPU, and do not need this. Using the iGPU means you can save power by turning off the more powerful AMD dGPU when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

## Issues

1. Resume after suspend is broken, as the GMUX (graphics multiplexer) doesn't connect the iGPU to the display after resuming. For this to be fixed, a Linux driver for `acpi:APP000B:GPUC:` needs to be written (macOS uses AppleMuxControl2.kext). The extra battery life may make this a worthwhile trade-off (about 3 hours to almost 6 hours on a MacBookPro16,1)
2. If using `DRI_PRIME=1` on programs causes system crashes, with "[CPU CATERR](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e#gistcomment-3719941)" problem reports in macOS, disable dynamic power management with the `amdgpu.dpm=0` kernel argument, or `echo high | sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level`.
3. If apple-set-os is loaded, the iGPU will control display brightness, and if the iGPU isn't the boot gpu, the i915 Intel graphics driver will not load, and the display brightness cannot be changed (The exception to this is sometimes when rebooting from macOS Recovery etc, i915 loads fine).

# Enabling the iGPU

!!! note
    Aside from step 1, these instructions should be followed in Linux.

1.  Update macOS. Big Sur and above can boot when the iGPU is set as the boot GPU, but this has not been tested on Catalina, and [on older MacBooks](https://github.com/Dunedan/mbp-2016-linux/issues/6#issuecomment-286200226), setting the iGPU as the boot GPU has stopped macOS from booting properly with graphics, and it is unknown when this was fixed (you might want to turn ssh on in macOS if you are worried about this).

2.  Set up apple-set-os-loader to make Apple's firmware show the iGPU

    1.  Compile apple-set-os loader. These instructions assume you have `gnu-efi` installed, and mount your EFI partition on `/boot/efi`. If you mount the EFI partition somewhere else, you will need to modify the last two commands.

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

5.  Check `journalctl -k --grep=efi:`, if you don't have "efi: Apple Mac detected, using EFI v1.10 runtime services only" then you will need update your kernel (preferred) or refer this [older version](https://github.com/t2linux/wiki/blob/eb15b19c7e4d5ce79a59ff14a4bf4297a5f65edc/docs/guides/hybrid-graphics.md#enabling-the-igpu) of this page.

    If you do have that line in journalctl, then you can set NVRAM and the boot GPU from Linux:
    
    ```sh
    curl https://raw.githubusercontent.com/0xbb/gpu-switch/master/gpu-switch > gpu-switch
    chmod +x gpu-switch
    sudo chown root:root gpu-switch
    sudo mv gpu-switch /usr/local/bin/
    sudo gpu-switch -i
    ```
    
    Reboot into Linux. Display brightness should be working again if it wasn't, and `glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMDGPU (some things do this automatically). You will get more battery time now as your AMD GPU can be turned off when not needed.

# Use on Windows

In one case (has anyone else tried this?), the iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers. There might be special iGPU drivers in the Bootcamp support software for single GPU MacBooks, which might help resolve this.

If you want to use the iGPU on Linux but not on Windows, you can switch back to the dGPU with `sudo gpu-switch -d` before booting to Windows.

3. If you want to switch GPU from Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

# VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
