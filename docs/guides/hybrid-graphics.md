# Introduction

This page describes how to use the iGPU on Macbook Pros with Hybrid Graphics (2 GPUs). 13 inch Macbooks only have an iGPU, and do not need this. Using the iGPU means you can save power by turning off the more powerful AMD dGPU when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,4 and 16,4 models are very similar and should work.

## Issues

1. Resume after suspend is broken, as the GMUX (graphics multiplexer chip) doesn't connect the iGPU to the display after resuming. For this to be fixed, the method that the t2 chip uses to control GMUX needs to be determined (likely through SMC keys). The extra battery life may make this a worthwhile tradeoff (about 3 hours to almost 6 hours on a 16,1)
2. Sometimes when playing games (i.e. tabletop simulator, genshin impact login screen), system crashes occur, the error report macOS shows calls it a [CPU CATERR](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e#gistcomment-3719941). Switching back to the dGPU fixes this. 

# Enabling the iGPU

1.  Update macOS. BigSur can boot fine when the iGPU is set as the boot GPU, but this has not been tested on Catalina, and [on older macbooks](https://github.com/Dunedan/mbp-2016-linux/issues/6#issuecomment-286200226), setting the iGPU as the boot GPU has stopped macOS from booting properly with graphics, and it is unknown when this was fixed (you might want to turn ssh on in macOS if you are worried about this).
2.  Compile apple-set-os loader, which spoofs macOS so that the iGPU gets enabled:

    ```sh
    git clone https://github.com/aa15032261/apple_set_os-loader
    cd apple_set_os-loader
    make #you might need a package like gnu-efi to compile this
    sudo mv /boot/efi/efi/boot/bootx64.efi /boot/efi/efi/boot/bootx64_original.efi
    sudo cp ./bootx64.efi /boot/efi/efi/boot/bootx64.efi
    ```

3.  Reboot to Linux, you should see this at boot (the GPUs listed might be different):

    ```
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

    Press any key other than `z` or wait, and it should boot you into Linux. If you want a silent version of this that doesn't wait for input, you can use [this fork](https://github.com/Redecorating/apple_set_os-loader). Your brightness control should stop working, *for now*. `lspci` should have an Intel Graphics card at address `00:02.0`, which won't be initialised currently.
4.  In macOS Recovery, run `nvram fa4ce28d-b62f-4c99-9cc3-6815686e30f9:gpu-power-prefs=%01%00%00%00`. If you boot macOS, this will be reset and you'll have to redo this step. You display should be now connected to your Intel iGPU when booting Linux and brightness should work again (probably with `/sys/class/backlight/acpi_video0`).
5.  Try `DRI_PRIME=1 glxinfo | grep "OpenGL renderer"&&glxinfo | grep "OpenGL renderer"`, you should get both AMD and Intel. Running things with `DRI_PRIME=1` will make them render on your AMDGPU (some things do this automatically). You will get more battery time now, as your AMD gpu can be turned off when not needed.

# Use on/with Windows

In one case (has anyone else tried this?), the iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers. There might be special iGPU drivers in the Bootcamp support software for single GPU Macbooks, which might help resolve this.

If you want to use the iGPU on Linux but not on Windows, you can reset the nvram variable in Linux by deleting it as described below (Writing to nvram panics the t2, but reading and deleting is fine), and then boot Windows with the dGPU. In Windows, you can use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script to set it to boot from the iGPU when you want to return to Linux.

## Switching to dGPU from Linux

1. If you have it, remove `efi=noruntime` from `/etc/default/grub`, regenerate your grub config (`sudo grub-mkconfig -o /boot/grub/grub.cfg`), and reboot. Put this line in `/etc/fstab` to make efivars/nvram read only instead of deactivated:

   ```
   efivarfs                     /sys/firmware/efi/efivars efivarfs ro,remount 0 0
   ```

2. When you want to switch to windows run:

   ```
   # remount nvram with write access
   sudo mount efivarfs /sys/firmware/efi/efivars/ -o rw,remount -t efivarfs
   # remove the immutable bit from the variable
   sudo chattr -i /sys/firmware/efi/efivars/gpu-power-prefs-fa4ce28d-b62f-4c99-9cc3-6815686e30f9
   # delete it
   sudo rm /sys/firmware/efi/efivars/gpu-power-prefs-fa4ce28d-b62f-4c99-9cc3-6815686e30f9
   # remount nvram read only
   sudo mount efivarfs /sys/firmware/efi/efivars/ -o ro,remount -t efivarfs
   ```

   And reboot into Windows.

3. If you want to enable the iGPU again, from Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script (or you can do `nvram fa4ce28d-b62f-4c99-9cc3-6815686e30f9:gpu-power-prefs=%01%00%00%00` in macOS recovery).

# VFIO GPU passthtough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks.
