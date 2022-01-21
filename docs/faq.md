# General FAQ

- AMD GPUs: Changing resolution, using DRI_PRIME and doing various other things can cause crashes, but `echo high| sudo tee /sys/bus/pci/drivers/amdgpu/0000:??:??.?/power_dpm_force_performance_level` or adding the `amdgpu.dpm=0` to the kernel commandline stops these crashes.
- MacBook fans running up, screen freezing, then it turns off: T2 panic; try a patched kernel.
- WiFi GUI not working: try kernel `5.15.12`.
- When should I use the Big Sur kernel and when should I use the Mojave kernel? idk answer this for me
- Backlight: no support for the MacBook Air 9,1, but there is a seperate fork here[https://github.com/Redecorating/apple-ib-drv](https://github.com/Redecorating/apple-ib-drv). Uninstall the old DKMS modules and install the new ones using this repo using [the dkms guide](https://wiki.t2linux.org/guides/dkms) instead of the other one.
- How do I force-shutdown the computer? Press and hold the Touch ID button.
- How do I show the boot menu? Press option during startup.
- How do I set a default device for booting? Press control while clicking the entry for EFI Boot.
