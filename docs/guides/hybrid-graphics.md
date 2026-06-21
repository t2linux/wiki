# Introduction

This page describes how to use the iGPU on MacBook Pros with Hybrid Graphics (2 GPUs). 13-inch MacBooks only have an iGPU and do not need this. Using the iGPU means you can save power by putting the more powerful AMD dGPU in a low power state when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

Make sure you have a T2 kernel of version greater than 6.9.8-1 (you can check this with `uname -r`).

## Issues

If you experience system freezes followed by high fan speeds and sudden shutdowns (CPU CATERR), or if the AMD GPU is causing excessive heat, try the following solutions:

1.  Set the iGPU as the main GPU (instructions below)

2.  Set the AMD GPU Dynamic Power Management level from auto to low or high. Low can be safer option to avoid thermal issues or save battery. *Note this will not work on MacBookPro15,1 as the `amdgpu` driver does not support runtime PM on Polaris cards.*

    You can test it quickly with: `echo low | sudo tee /sys/bus/pci/drivers/amdgpu/0000:0?:00.0/power_dpm_force_performance_level`

    To apply the low level automatically, create `/etc/udev/rules.d/30-amdgpu-pm.rules` file with the following contents (on NixOS, use `services.udev.extraRules` in your configuration):

    ```plain
    SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
    ```

    You can also control the AMD GPU DPM with GUI tools such as [radeon-profile](https://github.com/emerge-e-world/radeon-profile). For GPU intensive tasks like playing games, machine learning or rendering you can try setting the DPM to high instead.

## Making the iGPU the primary display adapter

By default T2 Macs with hybrid graphics use the dGPU as primary display adapter, which in return requires the dGPU to be always powered on. 
To save energy and reduce battery consumption, we can force the iGPU to be the primary display adapter and default graphics accelerator in a first step.

1.  Configure apple-gmux to switch to the iGPU at boot

    1.  Create `/etc/modprobe.d/apple-gmux.conf` with the following contents:

        ```plain
        # Enable the iGPU by default if present
        options apple-gmux force_igd=y
        ```
    2.  Or alternatively, add kernel parameter `apple_gmux.force_igd=1`

After reboot `glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMD GPU. On Gnome, by right clicking an application you can choose to run it using dedicated graphics.

## Disabling the dGPU

We can take this a step further and save substantial amounts of energy by deactivating the discrete graphics card.

1. We will create a systemd unit that will use `vgaswitcheroo` to disable the discrete graphics card on boot. Enter the full codeblock below and execute it.

    ``` 
    sudo tee /etc/systemd/system/amdgpu-off.service >/dev/null <<'EOF'
    [Unit]
    Description=Disable AMD dGPU via vgaswitcheroo
    After=systemd-modules-load.service
    Before=display-manager.service


    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c 'for i in $(seq 1 30); do [ -e /sys/kernel/debug/vgaswitcheroo/switch ] && exec sh -c "echo OFF > /sys/kernel/debug/vgaswitcheroo/switch"; sleep 1; done; exit 1'

    [Install]
    WantedBy=multi-user.target
    EOF

    sudo systemctl daemon-reload
    sudo systemctl enable amdgpu-off.service
    ```
    We can now run `sudo systemctl enable amdgpu-off.service` and reboot to disable our dGPU. This will decrease power draw on a MacBook significantly from around 20 to 9 Watts on idle using 50% display brightness, resulting in much longer battery life.
    Enabling the dGPU again is done using `sudo systemctl disable amdgpu-off.service` and reboot. A more convenient solution using aliases is explained in the next step.

2. We can quickly disable, enable and check the current status of the dGPU by creating aliases. Simply execute the following block:

    ``` 
    alias dgpu-off='sudo systemctl enable disable-amdgpu.service; sleep 2; sudo reboot'
    alias dgpu-on='sudo systemctl disable disable-amdgpu.service; sleep 2; sudo reboot'
    alias dgpu-status='sudo cat /sys/kernel/debug/vgaswitcheroo/switch'
    ```
    From now on you can check the status of the dGPU by simply entering `dgpu-status` :

    ```
    $ dgpu-status
    0:DIS-Audio: :DynOff:0000:01:00.1
    1:IGD:+:Pwr:0000:00:02.0
    2:DIS: :Off:0000:01:00.0
    ``` 
    `IGD` is the iGPU and `DIS` is the dGPU. The position of the `+` shows the GPU currently in use as the display adapter, while `Pwr` and `Off` refer to their respective power status.
    Executing the aliases `dgpu-off` and `dgpu-on` will enable and disable our `amdgpu-off` systemd service and reboot the computer.
    
    **Example:** Given the status above, executing `dgpu-on` will reboot your Mac. After reboot `dgpu-status` should be:

    ```
    $ dgpu-status
    0:DIS-Audio: :DynAuto:0000:01:00.1
    1:IGD:+:Pwr:0000:00:02.0
    2:DIS: :Pwr:0000:01:00.0
    ``` 



### Suspend workaround

If using the iGPU causes the screen to be black after waking up from suspend, then try one of these workarounds:

- Add `i915.enable_guc=3` to [your kernel parameters](https://wiki.t2linux.org/guides/postinstall/#add-necessary-kernel-parameters). If that has a problem, try setting the value to 2 instead of 3.
- Turn the screen off and on after the backlight turns on. For GNOME: type your password then press enter, press Command + L to lock (this should turn off the backlight), then press any key.

## Using iGPU as primary gpu (Mutter)

Mutter-based desktop environments (e.g. GNOME) pick one GPU to use as the "primary GPU", and it's not necessarily the same as the one connected to the display. Even if apple-gmux is configured with `force_igd=y`, Mutter's primary GPU might be the AMD GPU, which makes the AMD GPU active when screen contents change.

See [Mutter Multi-GPU documentation](https://gitlab.gnome.org/GNOME/mutter/-/blob/main/doc/multi-gpu.md) for more info, including how to change the primary GPU.

## Use on Windows

The iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers.

If you want to switch GPU for Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
