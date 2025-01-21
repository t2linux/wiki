<!-- markdownlint-disable MD046 MD038 -->
<!-- Rationale: Both rules break mkdocs-material's content tabs feature.  -->

# NixOS Installation Guide

You will need:

- A Mac device with a T2 chip
- A spare USB stick or other reasonably large storage medium (>2G recommended)
- Some experience with the command line
- Sufficient mental energy to find and fix errors

## Installation Steps

### Preparation

Follow the [Pre-Installation guide](../../guides/preinstall.md). If you intend to use Wi-Fi or Bluetooth, additional steps will need to be done. Check the [Wi-Fi pre-installation setup section](#pre-installation-steps) below for instructions, then come back.

Note that you may not be able to complete some steps like [Partitioning](#partitioning) without first completing the pre-installation guide.

### Partitioning

After booting to the live environment, partition the disk (usually `/dev/nvme0n1`) using `cfdisk` or other tools of your preference.
If you have followed the pre-installation guide, there should be another partition created just for Linux.

1. List the current partitions, e.g. with `fdisk -l` or `lsblk`. (If you have created a new partition with diskutil on macOS, in normal circumstances, you will see 3 partitions under `nvme0n1`.)
2. Make sure to NOT delete the EFI partition. That is the one with a size of `300M`. If `fdisk -l` was used to list the partitions in the previous step, this partition's `TYPE` shows `EFI System`. (If you have created a new partition with diskutil on macOS, in normal circumstances that should be `nvme0n1p1`.)
3. Make sure to NOT delete the macOS partition. To identify it you should remember the size you allocated to it during the Pre-Installation steps. (If you have created a new partition with diskutil on macOS, in normal circumstances that should be `nvme0n1p2`.)
4. Remove the partition that you created for Linux during the Pre-Installation steps. You can recognize it by the size you allocated for it before. (If you have created a new partition with diskutil on macOS, in normal circumstances that should be `nvme0n1p3`.)
5. Allocate new partitions accordingly to your needs - there are no hard rules. Just make sure to not delete the EFI partition and the macOS partition. See the [NixOS Installation Manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-UEFI) for examples.
6. Format the newly provisioned partitions with `mkfs.<filesystem>` commands and `mkswap` a swap partition (if any).
7. Mount the partitions under `/mnt`, and create directories as necessary. Then, enable the swap partition by using `swapon`. You should finally have something that looks similar to this:

```console
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0 972.5M  0 loop /nix/.ro-store
sda           8:0    1  14.5G  0 disk
├─sda1        8:1    1  1021M  0 part
└─sda2        8:2    1     3M  0 part
nvme0n1     259:0    0 465.9G  0 disk
├─nvme0n1p1 259:1    0   300M  0 part  /mnt/boot  # EFI partition
├─nvme0n1p2 259:2    0  83.9G  0 part             # APFS/macOS partition
├─nvme0n1p3 259:3    0     1G  0 part  /mnt/macos_share  # optional
├─nvme0n1p4 259:4    0     8G  0 part  [SWAP]     # Swap Partition
└─nvme0n1p5 259:5    0 372.8G  0 part  /mnt       # Linux Partition
```

This is just an example and does not have to be done this way.

!!! tip
    You might want to leave a little part of your disk as a FAT32 partition to be able to transfer files easily between MacOS and Linux. You would not have the chance to do so later, so do it now if needed.

### Internet Setup

If you wish to use Ethernet, no additional actions should be needed apart from an adapter.

If you wish to use Wi-Fi, follow the [Imperative firmware setup section](#imperative-setup) and come back.

### Configuration

Before doing anything else in this section, make sure partitions are **created and mounted** to `/mnt`. Check that with tools like `lsblk` and `findmnt -R /mnt`.

Generate a configuration with the following command:

    sudo nixos-generate-config --root /mnt

This will generate `configuration.nix` and `hardware-configuration.nix`. The former contains some default settings to get you started while the latter contain filesystems mounted at `/mnt` during generation.

You might want to also configure a display manager and a desktop environment. Check out available options at the [NixOS Options Search](https://search.nixos.org/options), and simply edit `configuration.nix` before installation.

=== "Legacy Method"
    Edit `/mnt/etc/nixos/configuration.nix`

    * Add the following snippet to the nixos config's `imports`
        ```nix title="configuration.nix" linenums="1" hl_lines="4"
        # Keep the generated configuration.nix! You need that, so just merge options here into that one.
        {...}: {
          imports = [
            "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/apple/t2"
          ];
        }
        ```

=== "Flakes"
    Nix flakes is a new system that is designed to replace Nix channels and to improve reproducibility. It is still in an experimental stage and is locked behind a number of feature flags.

    Flakes support in the ISO is enabled since the v6.4.9-3 ISO. You can validate if you're using that by running `nix run nixpkgs#hello`. If it outputs "Hello, world!", you can continue without modifying commands. If it errors, you are not.

    To use flakes, pass `--extra-experimental-features "flakes nix-command"` to nix commands in the live environment. Legacy Nix commands with hyphens (`-`, i.e. `nixos-rebuild`, `nix-store`) in them generally do not require and won't recognize the flag.

    Below are the setup steps. Adapt the locations as needed.

    === "Template"
        There is a flake template which should do most of the boilerplating work for you. This will also use the [substituter](./faq.md#substituter-setup) by default.

        ```shell
        # 0. If you haven't run nixos-generate-config, do it now. See above for steps.
        # 1. Change directory to /mnt/etc/nixos. 
        #    This will be where you store your flake, but you can move it later.
        cd /mnt/etc/nixos

        # 2. Initialize the flake directory with the template. 
        #    Accept *both* settings if you would like to use the substituter.
        nix flake init -t github:soopyc/nixos-t2-flake

        # 3. Edit flake.nix, delete the section as specified. 
        #    Also, rename yourHostname to something else.
        $EDITOR flake.nix

        # 4. Update the flake.lock
        nix flake update
        ```

    === "Manual"
        0. You should have run `nixos-generate-config`. If not, [do that](#configuration).
        * Create a new file at `/mnt/etc/nixos/flake.nix`, or use `nix flake init` while being in `/mnt/etc/nixos`
        * Add a flake input: `github:NixOS/nixos-hardware`
        * Add the apple-t2 NixOS module from `nixos-hardware` to your NixOS config.
        * For reasons stated above, add "flakes" and "nix-command" to nix's `experimental-features`.
        * Add a nixosConfigurations output, in which add a new attribute with any valid name. The common standard is to use the hostname. This will be used to activate your system.
        * Set the value of the attribute as a call to the lib.nixosSystem function (from the nixpkgs input) with a new attribute set, which contains the items outlined in the example below.

        !!! quote "Example Configuration"

            ```nix title="flake.nix" linenums="1"
            {
              inputs = {
                nixpkgs.url = "nixpkgs/nixos-unstable";
                nixos-hardware.url = "github:nixos/nixos-hardware";
              };
              outputs = {nixpkgs, nixos-hardware, ...}: {
                nixosConfigurations.replaceThisWithAnything = nixpkgs.lib.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    ./configuration.nix
                    nixos-hardware.nixosModules.apple-t2
                  ];
                };
              };
            }
            ```

            ```nix title="configuration.nix (snippet)" linenums="1"
            # Keep the generated configuration.nix! You need that, so just merge options here into that one.
            {...}: [
              imports = [./hardware-configuration.nix];  # this should already be present
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            ]
            ```

    !!! tip
        You do not need to keep your flake at `/etc/nixos` if you use this approach. You may safely copy the entire `/etc/nixos` directory to your home directory with whatever name you like. Then, [re]building the system is easy as running

            nixos-rebuild build --flake .#        # when building
            sudo nixos-rebuild switch --flake .#  # when switching

        within the flake directory.

        It is recommended to make the flake a git repo. Do so inside the flake with `git init`.

Then add a bootloader, `systemd-boot` works quite well and is recommended. `GRUB` is also available, but its usability has not been tested.
<!-- TODO: test that lol -->

=== "systemd-boot"
    ```nix title="configuration.nix" linenums="1"
    {...}: {
      boot.loader = {
        efi.efiSysMountPoint = "/boot"; # make sure to change this to your EFI partition!
        systemd-boot.enable = true;
      };
    }
    ```

=== "GRUB"
    ```nix title="configuration.nix" linenums="1"
    {...}: {
      boot.loader = {
        efi.efiSysMountPoint = "/boot"; # make sure to change this to your EFI partition!
        grub = {
          efiInstallAsRemovable = true;
          efiSupport = true;
          device = "nodev";
        };
      };
    }
    ```

If you want to use Wi-Fi and/or Bluetooth after installation, now is the time to [set up the firmware declaratively.](#declarative-setup)

### Installation

=== "Legacy Method"
    Simply run `sudo nixos-install` and hope that it works.

=== "Flakes"
    Within your flake, run `sudo nixos-install --flake .#<your host>`, where `<your host>` is the `nixosConfiguration` attribute name defined above.

    With the manual setup example, the command would be as thus.

        sudo nixos-install --flake .#replaceThisWithAnything

Finally, reboot and the installation is complete! If it did not work out as expected, feel free to ask in our Discord server. Provide as much detail as possible about what's not working so less time is wasted for all participants.

To change the system configuration after installation, simply edit `configuration.nix` and run `sudo nixos-rebuild switch`.

If you would like to organize your configuration a little better, check out other people's configuration or read the [Nix manuals](https://nixos.org/learn).

---

## Wi-Fi and Bluetooth setup

### Pre-Installation Steps

Choose a method below and carefully read the notes. Afterwards, follow the [Wi-Fi and Bluetooth Guide](../../guides/wifi-bluetooth.md#setting-up) (firmware guide) and come back.

The methods outlined below corresponds to the ones listed in the guide.

!!! question "What is `get-apple-firmware`?"
    This is the firmware script packaged as a runnable command in the ISO.

    For simplicity, this guide assumes you are using the latest ISO version while following the steps. If you are not in the Live environment or are not using a recent enough ISO, download the script yourself and replace every instance of `get-apple-firmware` with the location of your firmware script.

=== ":fontawesome-solid-check: Method 1"
    Method 1 requires you to run the firmware script twice, both in macOS and Linux.

    While this method is easier to set up than Method 2, it does not necessarily mean it is simpler to maintain.

=== ":fontawesome-solid-check: Method 2"
    This method creates a tarball with the renamed firmware files on macOS. No scripts will need to be run on Linux. This method is more robust than Method 1, but requires some manual configuration.

=== ":fontawesome-solid-ban: Method 3"
    !!! danger
        This method is not supported on NixOS as the distribution does not use a conventional package format. A similar setup can be done by following the [Declarative Setup](#declarative-setup) section, but you will need to follow some other method first.

=== ":fontawesome-solid-check: Method 4"
    This method obtains the firmware directly from the recovery image in the macOS partition. If you use a supported ISO version (see below), networking is not required.

    !!! warning
        If you have removed macOS, this method would not be useful to you.

=== ":fontawesome-solid-check: Method 5"
    This method is similar to Method 1, but instead of requiring macOS to be installed, the firmware files are extracted from recovery images downloaded directly from Apple. This is useful if you have removed macOS or the partition is not accessible for any reason.

    Note that a ~650MB recovery image will be downloaded on each invocation of this method. Make sure you are not on a metered connection before proceeding.

### Imperative Setup

The imperative setup is useful for temporary situations like the installation environment.

For long-term usage, imperative setups are **not recommended**. It is suggested to move to a [declarative setup](#declarative-setup) after installation or during configuration.

=== "Method 1"
    The following commands should get you up and running. Note that `/lib/firmware/brcm` must be manually created because NixOS does not come with that.

    ```shell
    sudo mkdir -p /lib/firmware/brcm
    sudo get-apple-firmware
    ```

=== "Method 2"
    1. Copy the firmware package tarball to somewhere accessible.
    2. Create the directory tree `/lib/firmware/brcm`.
    3. Unpack the firmware package tarball at that specific directory.
    4. Reload kernel modules to load the firmware.

    ```shell
    # Run everything here with sudo or as root.
    # Create the required directory tree
    mkdir -p /lib/firmware/brcm
    # Extract the firmware files
    tar -xf /path/to/your/firmware.tar -C /lib/firmware/brcm
    # Reload modules so the firmware changes take effect.
    modprobe -r brcmfmac_wcc; modprobe -r brcmfmac; modprobe brcmfmac; modprobe -r hci_bcm4377; modprobe hci_bcm4377
    ```

=== "Method 4"
    This method requires at least v6.9.3 of the ISO, or the `linux-apfs-rw` kernel module installed. It is recommended to use the latest ISO wherever possible.

    ??? question "How to install `linux-apfs-rw` on an existing system?"
        If you use the latest `nixos-hardware`, this module is already included in the patches and no further steps are needed.

        If you are not using the latest `nixos-hardware` revision, this package is included in nixpkgs. To make it available, modify your configuration to include the following.

        ```nix linenums="1" title="configuration.nix" hl_lines="2-5"
        {pkgs, ...}: {
            boot.extraModulePackages = [
                # change linux_6_9 to your kernel version
                linuxKernel.packages.linux_6_9.apfs
            ];
        }
        ```

    This method is relatively simpler than the others if you still have macOS installed.

    ```shell
    # Create the required directory tree.
    sudo mkdir -p /lib/firmware/brcm
    # Run the firmware script.
    sudo get-apple-firmware # pick the option "retrieve the firmware directly from macOS."
    ```

=== "Method 5"
    This method requires an existing Internet connection, as extra dependencies are required to run the script and to download the recovery image.

    ```shell
    # Create the required directory tree.
    sudo mkdir -p /lib/firmware/brcm
    # Run the script with required dependencies.
    sudo nix shell nixpkgs#{dmg2img,curl} -c get-apple-firmware
    # OR:
    # sudo nix shell nixpkgs#{dmg2img,curl} -c bash /path/to/firmware.sh
    ```

Then run `systemctl start wpa_supplicant` and then connect to internet using `wpa_cli`. Consult documentations such as the [Arch Linux wiki](https://wiki.archlinux.org/title/Wpa_supplicant#Connecting_with_wpa_cli) for command usage.

---

### Declarative Setup

The declarative setup is suitable for long-term use after you have installed NixOS.

=== "Method 1"
    First follow the steps in the [imperative setup.](#imperative-setup) The firmware files should then be located in `/lib/firmware/brcm`.

    Afterwards, copy `/lib/firmware` to your configuration directory.

    Finally add the following snippet to your configuration. Use your logic to edit the source directory.

    ```nix linenums="1" hl_lines="2-11" title="configuration.nix"
    {pkgs, ...}: {
      hardware.firmware = [
        (pkgs.stdenvNoCC.mkDerivation (final: {
          name = "brcm-firmware";
          src = ./firmware/brcm;
          installPhase = ''
            mkdir -p $out/lib/firmware/brcm
            cp ${final.src}/* "$out/lib/firmware/brcm"
          '';
        }))
      ];
    }
    ```

=== "Method 2"
    Copy the firmware tarball to your configuration directory, then add the following snippet.

    ```nix linenums="1" hl_lines="2-14" title="configuration.nix"
    {pkgs, ...}: {
      hardware.firmware = [
        (pkgs.stdenvNoCC.mkDerivation (final: {
          name = "brcm-firmware";
          src = ./firmware.tar;

          dontUnpack = true;
          installPhase = ''
            mkdir -p $out/lib/firmware/brcm
            tar -xf ${final.src} -C $out/lib/firmware/brcm
          '';
        }))
      ];
    }
    ```

=== "Method 4"
    The declarative setup for this method is exactly the same as in Method 1. Please first follow the above imperative setup guide, then select Method 1 and follow those instructions.

=== "Method 5"
    The declarative setup for this method is exactly the same as in Method 1. Please first follow the above imperative setup guide, then select Method 1 and follow those instructions.

#### NixOS Module

We are working on it, which should allow you to set up Wi-Fi and Bluetooth by just specifying a tarball.
