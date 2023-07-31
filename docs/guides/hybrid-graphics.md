# Introduction

This page describes how to use the iGPU on MacBookPro's with Hybrid Graphics (2 GPUs). 13 inch MacBooks only have an iGPU, and do not need this. Using the iGPU means you can save power by putting the more powerful AMD dGPU in a low power state when you don't need it.

This has been tested on the MacBookPro16,1 and the MacBookPro15,1. The 15,3 and 16,4 models are very similar and should work too.

Make sure you have a t2 kernel of version greater than 6.1.12-2 (you can check this with `uname -r`).

## Issues

If you experience system freezes, then the laptop's fans becoming loud, before the whole computer shuts off (CPU CATERR), or if the amdgpu is making the computer too hot, consider trying:

1.  Set iGPU as main gpu (instructions below)

2.  Set AMD GPU Dynamic Power Management from auto to low or high. Low can be safer option to avoid thermal issues or save battery.

    You can test it quickly with: `echo low | sudo tee /sys/bus/pci/drivers/amdgpu/0000:0?:00.0/power_dpm_force_performance_level`

    To apply the low level automatically, create `/etc/udev/rules.d/30-amdgpu-pm.rules` file with the following contents:

    ```plain
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
    ```

    To check which card is the amdgpu, we can run:

    ```sh
    basename /sys/bus/pci/drivers/amdgpu/0000:0?:00.0/drm/card?
    ```

    You can also control the AMD GPU DPM with GUI tools such as [radeon-profile](https://github.com/emerge-e-world/radeon-profile). For GPU intensive tasks like playing games, machine learning or rendering you can try setting the DPM to high instead.

## Enabling the iGPU

These are general instructions that applies to most distros. For NixOS, please skip ahead to the separate section further down,

1.  Configue apple-gmux to switch to the IGPU at boot

    1.  Create `/etc/modprobe.d/apple-gmux.conf` with the following contents:

        ```plain
        # Enable the iGPU by default if present
        options apple-gmux force_igd=y
        ```

2.  Set up apple-set-os-loader to make Apple's firmware show the iGPU so apple-gmux will be able to switch to it:

    1.  Compile apple-set-os loader. These instructions assume you have `gnu-efi` installed, and mount your EFI partition on `/boot/efi`. If you mount the EFI partition somewhere else or use refind, you will need to replace /boot/efi with the mount point of the partition in which your bootloader is installed.

        - Ubuntu and Debian: `sudo apt install gnu-efi build-essential`
        - Arch, EndeavorOS, and Manjaro: `sudo pacman -Syu base-devel gnu-efi`
        - Fedora: `sudo dnf install "@C Development Tools and Libraries" gnu-efi`

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

`glxinfo | grep "OpenGL renderer"` should show an Intel GPU. Running programs with `DRI_PRIME=1` will make them render on your AMD GPU (some things do this automatically). You will get more battery time now as your AMD GPU can be turned off when not needed.

### NixOS

OBS! These instructions assumes a systemd bootloader. If using something else you will need to make some minor tweaks to assure the .efi file ends up in correct dir and gets set as default.

1.  Create a new file in `/etc/nixos/` called `hybrid_graphics.nix`:

    ```plain
    { config, pkgs, ... }:
    let
    my-efi-app = pkgs.stdenv.mkDerivation rec {
        name = "hybrid-graphics-1.0";

        src = pkgs.fetchFromGitHub {
        owner = "Redecorating";
        repo = "apple_set_os-loader";
        rev = "r33.9856dc4";
        sha256 = "hvwqfoF989PfDRrwU0BMi69nFjPeOmSaD6vR6jIRK2Y=";
        };

        buildInputs = [ pkgs.gnu-efi ];

        buildPhase = ''
        substituteInPlace Makefile --replace "/usr" '$(GNU_EFI)'
        export GNU_EFI=${pkgs.gnu-efi}
        make
        '';

        installPhase = ''
        install -D bootx64_silent.efi $out/bootx64.efi
        '';
    };
    in
    {
    system.activationScripts.my-efi-app = {
        text = ''
        mkdir -p /boot/efi/EFI/hybrid_graphics
        cp ${my-efi-app}/bootx64.efi /boot/efi/EFI/hybrid_graphics/bootx64.efi
        cp /boot/efi/EFI/BOOT/BOOTX64.EFI /boot/efi/EFI/BOOT/bootx64_original.efi
        '';
    };

    environment.etc."modprobe.d/apple-gmux.conf".text = ''
    # Enable the iGPU by default if present
    options apple-gmux force_igd=y
    '';

    environment.systemPackages = with pkgs; [ my-efi-app ];
    }
    ```

2.  Add it to the imports in `/etc/nixos/configuration.nix`.

3.  ```sh
    sudo nixos-rebuild switch
    ```
4.  Use `efibootmgr` to create a new default entry point for `/boot/efi/EFI/hybrid_graphics/bootx64.efi` (see https://nixos.wiki/wiki/Bootloader for more details). It will then automatically load `/boot/efi/EFI/BOOT/bootx64_original.efi` so carefully check to make sure that file has been generated correctly. If not then adjust the relevant lines in `hybrid_graphics.nix`.

Please note that this is using the silent version meaning there will be no info + countdown at boot. If you prefer the verbose version simply remove `silent` from the `install -D bootx64_silent.efi $out/bootx64.efi` row.

## MacBookPro16,4

Currently the Radeon 5600M AMD GPU on MacBookPro16,4 is [not working](https://lore.kernel.org/all/3AFB9142-2BD0-46F9-AEA9-C9C5D13E68E6@live.com/) with Linux. As a workaround :-

### If you are able to edit your kernel command line :-

1. Edit the kernel command line of this boot and add the `nomodeset` kernel parameter. This will enable you to access your Linux system in safe graphics.

2. Follow the instructions [above](#enabling-the-igpu).

3. You can now remove the `nomodeset` parameter from your kernel command line.

### If you are unable to edit your kernel command line :-

1. Boot into macOS

    1. Mount your Linux EFI partition over there. In most cases it should be `disk0s1` and can be mounted by running `sudo diskutil mount disk0s1` in the terminal. If you are using a separate EFI partition, the you can run `diskutil list` and find your partition in the output, and mount it accordingly.

    2. Install apple-os-set loader from [here](https://github.com/Redecorating/apple_set_os-loader) using macOS, and put it in your Linux EFI partition.

2. Restart into macOS Recovery by immediately pressing and holding Command+R on startup.

    1. Open the terminal there and run `nvram fa4ce28d-b62f-4c99-9cc3-6815686e30f9:gpu-power-prefs=%01%00%00%00`.

3. Restart into Linux. You should now be able to access your Linux installation.

4. Follow the instructions [above](#enabling-the-igpu).

## Use on Windows

The iGPU only works on Windows if there's no driver for it installed. Windows likes installing drivers.

If you want to switch GPU for Windows, use 0xbb's [gpu-switch](https://github.com/0xbb/gpu-switch#windows-810-usage) script.

## VFIO GPU passthrough

Refer to [this gist](https://gist.github.com/Redecorating/956a672e6922e285de83fdd7d9982e5e) for quirks required to pass through the dGPU to a Windows Virtual Machine, while having Linux use the iGPU.
