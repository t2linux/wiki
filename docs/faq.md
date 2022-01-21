# General FAQ

- AMD GPUs: Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding the `amdgpu.dpm=0` to the kernel commandline stops these crashes.
- If the MacBook's screen freezes, fans run up, and then it turns off: this is a T2 panic; try a patched kernel, or boot macOS and check the crashlog.
- If the WiFi GUI is not working: try kernel `5.15.12` instead of later versions.
- Backlight: no support for the MacBook Air 9,1, but there is a seperate fork here[https://github.com/Redecorating/apple-ib-drv](https://github.com/Redecorating/apple-ib-drv) for the MBP 16,x. Follow [the dkms guide](https://wiki.t2linux.org/guides/dkms) to install this fork. Other models with backlight should work out of the box.
- How do I force-shutdown the computer? Press and hold the Touch ID button, or the button at the back of the device (iMacs, MacMinis, and MacPros).
- How do I show the boot menu? Hold option during startup.
- How do I set a default device for booting? Press control while clicking the entry for EFI Boot.
