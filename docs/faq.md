# General FAQ

## AMD GPUs crashing

Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but running the command `echo high| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding the `amdgpu.dpm=0` to the kernel commandline stops these crashes.

## The MacBook's screen freezes, fans run up, and then it turns off

This is a T2 panic; try a patched kernel (if you're not using one already), or boot macOS and check the crashlog. You may need a custom ISO. You can also try adding the ``efi=noruntime`` option to GRUB's command line paramaters.

## The WiFi GUI is not working

Try patched kernel `5.15.12` instead of later versions.

## How do I get backlight working?

There is no support for the MacBook Air 9,1, but there is a seperate fork here[https://github.com/Redecorating/apple-ib-drv](https://github.com/Redecorating/apple-ib-drv) for the MBP 16,x. Follow [the dkms guide](https://wiki.t2linux.org/guides/dkms) to install this fork. Other models with backlight should work out of the box.

## How do I force-shutdown the computer?

Press and hold the Touch ID button, or the button at the back of the device (iMacs, MacMinis, and MacPros).

## How do I show the Startup Manager?

Hold option during startup.

## How do I set a default device for booting?

Press control while clicking the entry for EFI Boot.

## Linux with Bootcamp

- If you already have Bootcamp installed, you might notice that the boot option for Bootcamp instead boots you into Linux. This is because GRUB automatically shares with a Windows installation. Follow [this guide on triple booting](https://wiki.t2linux.org/guides/windows/#if-windows-is-installed-first) to get Windows working again.
