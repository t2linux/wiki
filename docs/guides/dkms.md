# Introduction

This page explains how to install the kernel modules for the Keyboard, Audio, Touchbar and the Ambient Light sensor with DKMS. You will need a patched kernel.

# Do you need to do this?

Are your keyboard and audio working? If no, then you'll need the BCE module.  
If you have a Touchbar, is it working? If no, then you'll need the apple-ibridge module.

To get started with this guide, first install the `dkms` package.

You may have been using an outdated kernel or your distribution may have been using kernel modules that do not match the ones listed below (check using `dkms status` or `ls -l /usr/src`). If the version of `apple-bce` in the output is `0.1`, you have to uninstall the old modules first to avoid any compatibility issues by running:

```sh
sudo dkms uninstall -m apple-bce -v 0.1
sudo dkms uninstall -m apple-ibridge -v 0.1
sudo rm -r /usr/src/apple-bce-0.1
sudo rm -r /usr/src/apple-ibridge-0.1
sudo rm -r /var/lib/dkms/apple-bce
sudo rm -r /var/lib/dkms/apple-ibridge
```

# Installing modules

1. Installing the BCE (Buffer Copy Engine) module for Keyboard and Audio

    - If you are on arch, you can use Aunali1's [apple-bce-dkms-git package](https://github.com/aunali1/apple-bce-arch/releases)
    - Otherwise, run `sudo git clone https://github.com/t2linux/apple-bce-drv /usr/src/apple-bce-0.2`

        -   Create a `dkms.conf` file in `/usr/src/apple-bce-0.2` and put in the following:

            ```conf
            PACKAGE_NAME="apple-bce"
            PACKAGE_VERSION="0.2"
            MAKE[0]="make KVERSION=$kernelver"
            CLEAN="make clean"
            BUILT_MODULE_NAME[0]="apple-bce"
            DEST_MODULE_LOCATION[0]="/kernel/drivers/misc"
            AUTOINSTALL="yes"
            ```

    - Now run `sudo dkms install -m apple-bce -v 0.2`. If on a live ISO, use `sudo dkms install -m apple-bce -v 0.2 -k x.x.x-mbp` instead and change `x.x.x-mbp` to the kernel that you have installed, as by default `dkms` will try to build the module for the kernel that the live iso is using, which will most likely be older.

2. Installing the Touchbar and Ambient Light sensor modules

    - If you are on a MacBook Pro (16 inch, 2019) or MacBook Pro (13 inch, 2020), and want keyboard backlight to work, run :

      `sudo git clone https://github.com/Redecorating/apple-ib-drv /usr/src/apple-ibridge-0.1`

      Else run :

      `sudo git clone https://github.com/t2linux/apple-ib-drv /usr/src/apple-ibridge-0.1`

    - Now run `sudo dkms install -m apple-ibridge -v 0.1`. If on a live ISO, use `sudo dkms install -m apple-ibridge -v 0.1 -k x.x.x-mbp` instead and change `x.x.x-mbp` to the kernel that you have installed, as by default `dkms` will try to build the module for the kernel that the live iso is using, which will most likely be older.

3. Load the modules into the kernel

    !!! note
        This is only necessary if you wish to use the modules right away. If you are installing modules from a live iso the commands will fail as the modules have only been installed for the kernel you specified.

    ```sh
    sudo modprobe apple_bce
    sudo modprobe apple_ib_tb
    sudo modprobe apple_ib_als
    ```

The Touchbar and keyboard should be working. For audio, you'll also need some config files, refer to the [Audio Config guide](https://wiki.t2linux.org/guides/audio-config).

# Make modules load on boot

!!! info "Ubuntu"
    Ubuntu users may skip this step as it's already set up in their distro. If the modules are still not loading on boot, then you may follow this section.

```sh
echo apple-bce >> /etc/modules-load.d/t2.conf
```

# Make modules load on early boot

Having the `apple-bce` module loaded early allows the use of the keyboard for decrypting encrypted volumes (LUKS).
It also is useful when boot doesn't work, and the keyboard is required for debugging.
To do this, one must ensure the `apple-bce` module *as well as its dependent modules* are included in the initial ram disk.
If your distro uses `initramfs-tools` (all debian-based distros), then `/etc/initramfs-tools/modules` stores a list of extra modules to be included and loaded at early boot time:

```sh
cat <<EOF >> /etc/initramfs-tools/modules
# Required modules for getting the built-in apple keyboard to work:
snd
snd_pcm
apple-bce
EOF
```

Other distros use a different initramfs module loading mechanism.
For example in Arch ensure that the `/etc/mkinitcpio.conf` file has:

```sh
MODULES="apple-bce"
```

And then run `sudo mkinitcpio -P`.
See your distro-specific instructions for configuring `apple-bce` to added to your initramfs.

# Setting up the Touch Bar

The Touch Bar can be set up by running [this script](../tools/touchbar.sh) **in Linux** using `bash /path/to/script`. Make sure your Linux kernel and macOS is updated before running this script.

If you are running **Ubuntu**, its recommended to run the following as well and rebooting :-

```sh
sudo rm /etc/modprobe.d/apple-touchbar.conf
sudo rm /etc/modules-load.d/apple-bce.conf
sudo rm /etc/modules-load.d/applespi.conf
echo apple-bce | sudo tee /etc/modules-load.d/t2.conf
```

After running this script, if you wish to change the default mode of the Touch Bar, run `sudo touchbar` and choose the mode you wish.

In case your Touch Bar is unable to change modes on pressing the fn key, you could try the following :-

1. Try adding `usbhid.quirks=0x05ac:0x8302:0x80000` as a Kernel Parameter using your Bootloader.

2. Try running the following and rebooting.
  
   ```sh
   echo -e "# delay loading of the touchbar driver\ninstall apple-ib-tb /bin/sleep 7; /sbin/modprobe --ignore-install apple-ib-tb" | sudo tee /etc/modprobe.d/delay-tb.conf >/dev/null
   ```
  
3. Boot into the [macOS Recovery](https://support.apple.com/en-gb/HT201314) and then restart into Linux.

4. Unplug all the external USB keyboards and mouse and then restart into Linux, keeping them unplugged.

If you still face an issue, mention it [here](https://github.com/t2linux/wiki/issues) or on the discord.

# Fixing Suspend

Copy [this script](../tools/rmmod_tb.sh) to `/lib/systemd/system-sleep/rmmod_tb.sh`

Now run :-

```sh
sudo chmod 755 /lib/systemd/system-sleep/rmmod_tb.sh
sudo chown root:root /lib/systemd/system-sleep/rmmod_tb.sh
```

It unloads the Touchbar modules as they can cause issues for suspend.

Your keyboard backlight may remain switched off on resuming and backlight controls may stop working. A restart fixes the backlight controls. You may also run `echo 60 > /sys/class/leds/apple::kbd_backlight/brightness` to turn on the backlight to the maximum level if you do not want to boot. Replace 60 with a lower number for lower brightness.

# Kernel panic when loading apple-ib-als

This was fixed in [this commit](https://github.com/t2linux/apple-ib-drv/commit/fc9aefa5a564e6f2f2bb0326bffb0cef0446dc05), please follow the [dkms guide](https://wiki.t2linux.org/guides/dkms/) to update.

# Use ambient light sensor to automatically change brightness (if not working already)

You can use [this script](https://gist.github.com/jbredall/52179d1fc2c91917d2fde118d2cb04aa). Make sure you have the `apple-ib-als` module loaded.
