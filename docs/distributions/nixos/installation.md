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

Follow the [Pre-Installation guide](../../guides/preinstall.md). You may not be able to complete some steps without doing so, like [Partitioning](#partitioning).

### Partitioning

After booting to the live environment, partition the disk (usually `/dev/nvme0n1`) using `cfdisk` or other tools of your preference.
If you have followed the pre-installation guide, there should be another partition created just for Linux.

- Remove that and allocate new partitions accordingly - there are no hard rules. Just make sure to not delete the EFI partition and the macOS partition. See the [NixOS Installation Manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-UEFI) for examples.
- Format the newly provisioned partitions with `mkfs.<filesystem>` commands and `mkswap` a swap partition (if any).
- Mount the partitions under `/mnt`, and create directories as necessary. Then, enable the swap partition by using `swapon`. You should finally have something that looks similar to this:

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

### Configuration and Installation

Before doing anything else in this section, make sure partitions are **created and mounted** to `/mnt`. Check that with tools like `lsblk` and `findmnt -R /mnt`.

Generate a configuration the following command:

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
    Nix flakes is a new system that is designed to replace nix channels and to improve reproducibility. It is still in an experimental stage and is locked behind a number of feature flags.

    Flakes support in the ISO is enabled since the v6.4.9-3 ISO. You can validate if you're using that by running `nix run nixpkgs#hello`. If it outputs "Hello, world!", you can continue without modifying commands. If it errors, you are not.

    To use flakes, pass `--extra-experimental-features "flakes nix-command"` to nix commands in the live environment. Nix commands with hyphens (`-`, i.e. `nixos-rebuild`, `nix-store`) in them generally do not require this since they were not built with flakes in mind.

    Below are the setup steps. Adapt the locations as needed.

    0. You should have ran `nixos-generate-config`. If not, [do that](#configuration-and-installation).
    * Make a new file at `/mnt/etc/nixos/flake.nix`, or use `nix flake init` while being in `/mnt/etc/nixos`
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

            nixos-rebuild build .#        # when building
            sudo nixos-rebuild switch .#  # when switching

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

It is now time to install the system.

=== "Legacy Method"
    Simply run `sudo nixos-install` and hope that it works.

=== "Flakes"
    Run `sudo nixos-install --flake .#<your host>`, where `<your host>` is the `nixosConfiguration` attribute name defined above.

    With the example, the command would be as thus.

        sudo nixos-install --flake .#replaceThisWithAnything

Finally, reboot and the installation is complete! If it did not work out as expected, feel free to ask in our Discord server. Provide as much detail as possible about what's not working so less time is wasted for all participants.

To change the system configuration after installation, simply edit `configuration.nix` and run `sudo nixos-rebuild switch`.

If you would like to organize your configuration a little better, check out other people's configuration or read the [Nix manuals](https://nixos.org/learn).

---

## Wi-Fi and Bluetooth setup

### Imperative Setup

The imperative setup is useful for temporary situations like the Live environment.

The following commands should get you up and running. You should have acquired the firmware script from the pre-installation guide. Note that `/lib/firmware` has to be manually created because NixOS does not come with that.

    sudo mkdir -p /lib/firmware
    sudo /mnt/boot/firmware.sh
    #    ^~~~~~~~~ change this if the EFI partition is mounted elsewhere

Then run `systemctl start wpa_supplicant` and then connect to internet using `wpa_cli`. Consult documentations such as the [Arch Linux wiki](https://wiki.archlinux.org/title/Wpa_supplicant#Connecting_with_wpa_cli) for command usage.

---

### Declarative Setup

The declarative setup is suitable for long-term use after you have installed NixOS.

=== "Legacy Method"
    <!-- TODO: extend the firmware script to short-circuit the installation and just give users a usable .tar -->
    This step currently requires the completion of the firmware [imperative setup](#imperative-setup).

    Assuming your `configuration.nix` is at `/mnt/etc/nixos/`, copy the existing firmware files at `/lib/firmware` to `/mnt/etc/nixos/firmware`. Then add this snippet to your `configuration.nix`:

    ```nix linenums="1" hl_lines="2-11" title="configuration.nix"
    {pkgs, ...}: {
      hardware.firmware = [
        (stdenvNoCC.mkDerivation (final: {
          name = "brcm-firmware";
          src = ./firmware/brcm;
          installPhase = ''
            mkdir -p $out/lib/firmware/brcm
            cp ${final.src}/* "$out/lib/firmware/brcm"
          '';
        }))
      ]
    }
    ```

=== "Flakes"
    <!-- TODO -->
    We're working on a flake output! That should make this easier. In the meantime, the "legacy" option also apply to flakes.
