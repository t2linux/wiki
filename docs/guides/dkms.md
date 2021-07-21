# Introduction

This page explains how to install the kernel modules for the Keyboard, Audio, Touchbar and the Ambient Light sensor with DKMS. You will need a patched kernel.

# Do you need to do this?

Is your keyboard working? If no, then you'll need the BCE module.
If you have a Touchbar, is it working? If no, then you'll need the apple-ibridge module.

In some distros like Ubuntu you might need to uninstall the pre-installed BCE module and apple-ibridge module and install the ones given here as the pre-installed ones are not compatible with newer kernels (5.10+) but the ones given here are.

To uninstall, run :-

```sh
sudo dkms uninstall -m apple-bce -v 0.1
sudo dkms uninstall -m apple-ibridge -v 0.1
sudo rm -r /usr/src/apple-bce-0.1
sudo rm -r /usr/src/apple-ibridge-0.1
sudo rm -r /var/lib/dkms/apple-bce
sudo rm -r /var/lib/dkms/apple-ibridge
```

# Installing modules

1. Install the `dkms` package
2. Installing the BCE (Buffer Copy Engine) module for Keyboard and Audio

    - If you are on arch, you can use Aunali1's [apple-bce-dkms-git package](https://github.com/aunali1/apple-bce-arch/releases)
    - Otherwise, `sudo git clone https://github.com/t2linux/apple-bce-drv /usr/src/apple-bce-r183.c884d9c`

        -   Create a `dkms.conf` file in `/usr/src/apple-bce-r183.c884d9c` and put in the following:

            ```conf
            PACKAGE_NAME="apple-bce"
            PACKAGE_VERSION="r183.c884d9c"
            MAKE[0]="make KVERSION=$kernelver"
            CLEAN="make clean"
            BUILT_MODULE_NAME[0]="apple-bce"
            DEST_MODULE_LOCATION[0]="/kernel/drivers/misc"
            AUTOINSTALL="yes"
            ```

    - Use `sudo dkms install -m apple-bce -v r183.c884d9c -k x.x.x-mbp`, change `x.x.x-mbp` to the kernel that you have installed, as by default `dkms` will try to build the module for the kernel that the live iso is using, which will most likely be older. If you are not on a live iso, then you can omit this bit.

3. Installing the Touchbar and Ambient Light sensor modules

    - `sudo git clone https://github.com/t2linux/apple-ib-drv /usr/src/apple-ibridge-0.1`
    - Use `sudo dkms install -m apple-ibridge -v 0.1 -k x.x.x-mbp`, change `x.x.x-mbp` to the kernel that you have installed, as by default `dkms` will try to build the module for the kernel that the live iso is using, which will most likely be older. If you are not on a live iso, then you can omit this bit.

4. Load the modules into the kernel

    ```sh
    sudo modprobe apple_bce
    sudo modprobe apple_ib_tb
    sudo modprobe apple_ib_als
    ```

The Touchbar and keyboard should work, for audio, you'll need some config files, refer to the [Audio Config guide](https://wiki.t2linux.org/guides/audio-config).

# Make modules load on boot

```sh
echo "apple-bce
apple-ib_tb
apple-ib-als
brcmfmac" >> /etc/modules-load.d/t2.conf
```

If you don't want (for example) the touch bar modules, you can ommit them from this command. `brcmfmac` is needed to use the internal wifi chip, refer to the [wifi guide](https://wiki.t2linux.org/guides/wifi/) for details on how to set that up.

# Module configuration

The Touchbar module offers some modes to set. In `/etc/modprobe.d/apple-tb.conf`, set `fnmode` (`options apple-ib-tb fnmode=x`) to one of the following options:

- 0: Only show F1-F12
- 1: Show media and brightness controls, use the `fn` key to switch to F1-12
- 2: Show F1-F12, use the `fn` key to switch to media and brightness controls
- 3: Only show media and brightness controls
- 4: Only show the escape key

# Fixing Suspend

Copy [this script](https://github.com/marcosfad/mbp-ubuntu/blob/master/files/suspend/rmmod_tb.sh) to `/lib/systemd/system-sleep/rmmod_tb.sh`

Now run :-

```sh
sudo chmod 755 /lib/systemd/system-sleep/rmmod_tb.sh
sudo chown root:root /lib/systemd/system-sleep/rmmod_tb.sh
```

It unloads the Touchbar modules as they can cause issues for suspend.

# Issues

The `apple_ib_als` module can cause issues, if you find your computer hanging at shutdown, or having BCE errors at boot, try blacklisting it `sudo sh -c "echo blacklist apple-ib-als" >> /etc/modprobe.d/blacklist.conf` or removing it from `/etc/modules-load.d/t2.conf`.
