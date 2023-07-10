# NixOS Installation

!!! note "Pre-Installation Guide"
    This guide assumes that you have followed the [pre-installation guide](https://wiki.t2linux.org/guides/preinstall).

1. Partition your disk using `cfdisk` or the tool of your preference, initialize the partitions with the `mkfs` command of the filesystem you want (`mkswap` is for swap) and mount them under `/mnt`.

    **Note**: You might want to leave a little part of your disk as a FAT32 partition to be able to transfer files easily between MacOS and Linux.

2. To connect to internet, you should load the firmware with these commands first:

    ```sh
    sudo mkdir -p /lib/firmware/brcm
    sudo cp /mnt/boot/firmware/* /lib/firmware/brcm
    sudo modprobe -r brcmfmac && sudo modprobe brcmfmac
    ```

    Then run `systemctl start wpa_supplicant` and then connect to internet using `wpa_cli`.
    When running the commands, don't forget to change `/mnt/boot` to the place you mounted your ESP at (for example `/mnt/boot/efi`).

3. Generate your configuration using `sudo nixos-generate-config --root /mnt`.
4. Edit `/mnt/etc/nixos/configuration.nix`:
    * Add `"${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/apple/t2"` to `imports`.
    * Copy the WiFi/Bluetooth firmware to `/mnt/etc/nixos/firmware/brcm` and add this snippet to your `configuration.nix`:

        ```nix
        hardware.firmware = [
          (pkgs.stdenvNoCC.mkDerivation {
            name = "brcm-firmware";

            buildCommand = ''
              dir="$out/lib/firmware"
              mkdir -p "$dir"
              cp -r ${./files/firmware}/* "$dir"
            '';
          })
        ];
        ```

    * Add a bootloader, `systemd-boot` works quite well. If you want to use `GRUB`, don't forget to set `boot.grub.efiInstallAsRemovable`, `boot.grub.efiSupport` to `true` and `boot.grub.device` to `"nodev"`.
5. Run `sudo nixos-install`.

And the installation is complete!
Note that you should probably transition to a more structured configuration [using flakes](https://github.com/NixOS/nixos-hardware/blob/master/README.md#using-nix-flakes-support), that is omitted here for brevity.
