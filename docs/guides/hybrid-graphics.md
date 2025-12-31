# Introduction

This page describes how to use the iGPU on MacBook Pros with Hybrid Graphics (2 GPUs). 13-inch MacBooks only have an iGPU and do not need this. Using the iGPU means you can save power by putting the more powerful AMD dGPU in a low power state when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

Make sure you have a T2 kernel of version greater than 6.9.8-1 (you can check this with `uname -r`).

## Issues

If you experience system freezes, then the laptop's fans become loud, before the whole computer shuts off (CPU CATERR), or if the amdgpu is making the computer too hot, consider trying:

1.  Set the iGPU as main gpu (instructions below)

2.  Set the AMD GPU Dynamic Power Management from auto to low or high. Low can be safer option to avoid thermal issues or save battery.

    You can test it quickly with: `echo low | sudo tee /sys/bus/pci/drivers/amdgpu/0000:0?:00.0/power_dpm_force_performance_level`

    To apply the low level automatically, create `/etc/udev/rules.d/30-amdgpu-pm.rules` file with the following contents (on NixOS, use `services.udev.extraRules` in your configuration):

    ```plain
    SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
    ```

    You can also control the AMD GPU DPM with GUI tools such as [radeon-profile](https://github.com/emerge-e-world/radeon-profile). For GPU intensive tasks like playing games, machine learning or rendering you can try setting the DPM to high instead.

## Enabling the iGPU

1.  Configure apple-gmux to switch to the iGPU at boot

    1.  Create `/etc/modprobe.d/apple-gmux.conf` with the following contents:

        ```plain
        # Enable the iGPU by default if present
        options apple-gmux force_igd=y
        ```

`glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMD GPU (some things do this automatically). You will get more battery time now as your AMD GPU can be turned off when not needed.

### Suspend workaround

If using the iGPU causes the screen to be black after waking up from suspend, then try one of these workarounds:

- Add `i915.enable_guc=3` to [your kernel parameters](https://wiki.t2linux.org/guides/postinstall/#add-necessary-kernel-parameters). If that has a problem, try setting the value to 2 instead of 3.
- Turn the screen off and on after the backlight turns on. For GNOME: type your password then press enter, press Command + L to lock (this should turn off the backlight), then press any key.

## Use on Windows

The iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers.

If you want to switch GPU for Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
