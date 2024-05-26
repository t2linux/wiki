<!-- markdownlint-disable MD046 MD038 -->
<!-- Rationale: Both rules break mkdocs-material's content tabs feature.  -->

# Frequently Answered Questions

## The LiveCD does not boot/only shows a blank screen

This situation occurred due to regressions in the bootloader, which the wider NixOS community was also affected.
The bug has been fixed. Make sure you are using ISOs tagged at or newer than `6.4.9-2`. Nevertheless, usage of [the latest ISO](https://github.com/t2linux/nixos-t2-iso/releases/latest) is recommended.

## In the Live environment, building the kernel/configuration runs out of disk space

Since `/tmp` is a subdirectory under `/`, which is mounted as a `tmpfs`, it is very easy to run out of space. This may not happen to you, but a solution is to bind mount `/tmp` to a real filesystem.

```shell
# sudo -s
# Assuming you have mounted your root partition (/dev/nvme0n1p?) at /mnt
mkdir /mnt/tmp -p
mount --bind /mnt/tmp /tmp
# See mount(8) for more information.
```

Setting `TMPDIR` *might* work but your mileage may vary.

Alternatively, follow [this section](#substituter-setup) to not build the kernel.

## Substituter Setup

There is a public [hydra instance](https://hydra.soopy.moe) acting as a [binary cache/substituter](https://zero-to-nix.com/concepts/caching) run by a community member. Using the substituter will cause Nix to not rebuild the kernel, as long as you haven't done funny stuff like enabling crash dumping.

### Installation Environment

In the installation environment, the hydra cache is not currently used by default. Configure Nix to use the substituter by one of the following methods.

=== "Editing `nix.conf`"
    Since you will be installing as root, edit the root user's `nix.conf` located at `/root/.config/nix/nix.conf` to include the following snippet.

    ```shell
    # since root is a trusted user, we do not need to add extra-trusted-substituters.
    extra-substituters = https://hydra.soopy.moe
    extra-trusted-public-keys = hydra.soopy.moe:IZ/bZ1XO3IfGtq66g+C85fxU/61tgXLaJ2MlcGGXU8Q=
    ```

=== "Passing additional flags"
    This method is repetitive but is useful if you cannot edit the config file.

    For each `nixos-{rebuild,install}` command, pass in the flags as shown below.

    ```shell
    nixos-install --option extra-substituters "https://hydra.soopy.moe" --option extra-trusted-public-keys "hydra.soopy.moe:IZ/bZ1XO3IfGtq66g+C85fxU/61tgXLaJ2MlcGGXU8Q="
    ```

=== "Using flakes"
    You can configure Nix via the `nixConfig` top-level attribute in your flake. Installing with this forego the pitfalls with channels. Note that this only apply to operations done with the flake.

    ```nix title="flake.nix" linenums="1" hl_lines="2-5"
    {
      nixConfig = {
        extra-substituters = ["https://hydra.soopy.moe"];
        extra-trusted-public-keys = ["hydra.soopy.moe:IZ/bZ1XO3IfGtq66g+C85fxU/61tgXLaJ2MlcGGXU8Q="];
      };
      inputs = ...;
      outputs = ...;
    }
    ```

    You may also use the flake template to not have to type everything out. Check [the Configuration section in the Installation Guide](./installation.md#configuration) for more information.

#### Channels users

If you are using the legacy setup with channels, you might still be building the kernel even if you have the substituter set up. This is because the ISO's nixpkgs flake input takes precedence over channels.

A set up with flakes is obviously still recommended as this problem would be circumvented, but if you cannot or don't want to use flakes, here are the steps to install with the substituter.

```bash
# Ensure you are using nixos-unstable.or the latest stable nixos release.
sudo nix-channel --list
# Update nix channels
sudo nix-channel --update
# Proceed to installation. NIX_PATH ensures we are using the channels revision and not the ISO flake registry's.
NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos nixos-install
```

### NixOS Environment

Configure Nix to use the substituter by adding a configuration module as shown below.

You do not have to perform this step if you use the flake template.

```nix linenums="1" hl_lines="2-7"
{ ... }: {
  nix.settings = {
    substituters = [ "https://hydra.soopy.moe" ];
    trusted-substituters = [ "https://hydra.soopy.moe" ]; # to allow building as a non-trusted user
    trusted-public-keys =
      [ "hydra.soopy.moe:IZ/bZ1XO3IfGtq66g+C85fxU/61tgXLaJ2MlcGGXU8Q=" ];
  };
}
```
