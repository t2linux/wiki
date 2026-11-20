# Introduction

This page describes how to use the iGPU on MacBook Pros with Hybrid Graphics (2 GPUs). 13-inch MacBooks only have an iGPU and do not need this. Using the iGPU means you can save power by putting the more powerful AMD dGPU in a low power state when you don't need it.

This has been tested on All T2 MacBook Pros with Hybrid Graphics.

Make sure you have a T2 kernel of version greater than 7.3.3 (you can check this with `uname -r`).

## Making the iGPU the primary display adapter

By default T2 Macs with hybrid graphics use the dGPU as primary display adapter, which in return requires the dGPU to be always powered on.
To save energy and reduce battery consumption, we can force the iGPU to be the primary display adapter and default graphics accelerator in a first step.

1. Configure the MacBook to switch to the iGPU at boot.
    1. You can use the **T2-Hybrid-gpu-control** app provided by KaiT2en: https://github.com/kaiT2en/KaiT2en-Fedora/tree/main/apps/t2-hybrid-gpu-control

    2. Alternatively, you can manually set the EFI variable `gpu-power-prefs-fa4ce28d-b62f-4c99-9cc3-6815686e30f9` on every boot (5th byte: `1` = IGD, `0` = DIS).

After reboot `glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMD GPU. On Gnome, by right clicking an application you can choose to run it using dedicated graphics.

There is a significant performance decrease when gaming or rendering with `DRI_PRIME=1` and the iGPU set as the primary GPU, compared to using the dGPU as the primary GPU.

Also, there is no need to permanently disable the dGPU. With the new kernel, the dGPU automatically goes to sleep when not in use and wakes up when needed, such as when using `DRI_PRIME=1` or other applications that require it.

### Suspend workaround

If using the iGPU causes the screen to be black after waking up from suspend, then try one of these workarounds:

- Add `i915.enable_guc=3` to [your kernel parameters](https://wiki.t2linux.org/guides/postinstall/#add-necessary-kernel-parameters). If that has a problem, try setting the value to 2 instead of 3.
- Turn the screen off and on after the backlight turns on. For GNOME: type your password then press enter, press Command + L to lock (this should turn off the backlight), then press any key.

## Using iGPU as primary gpu (Mutter)

Mutter-based desktop environments (e.g. GNOME) pick one GPU to use as the "primary GPU", and it's not necessarily the same as the one connected to the display. Even if apple-gmux is configured with `force_igd=y`, Mutter's primary GPU might be the AMD GPU, which makes the AMD GPU active when screen contents change.

See [Mutter Multi-GPU documentation](https://gitlab.gnome.org/GNOME/mutter/-/blob/main/doc/multi-gpu.md) for more info, including how to change the primary GPU.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
