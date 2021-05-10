# Upgrading to a new kernel for Ubuntu Linux

We will need two things, a tar of the Linux kernel, and aunali1's linux-mbp-arch patches.
The kernel can be downloaded from [here.](https://mirrors.edge.kernel.org/pub/linux/kernel) Make sure to get the right version for the current linux-mbp-arch version.

After downloading the kernel, we can start.

1. Make a folder for the Linux kernel and the patches to go into. For this guide, we'll make a folder in the home directory called `kernel`.

    * `mkdir ~/kernel && cd ~/kernel`

2. Move the Linux kernel archive to this new folder and extract it

    * `mv /path/to/linux-[INSERT VERSION NUMBER HERE].tar.gz ~/kernel`
    * `tar -xf linux-[INSERT VERSION NUMBER HERE].tar.gz`

3. Git clone the [linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch) repo to the directory where the kernel is located and change the directory to the Linux kernel

    * `git clone https://github.com/aunali1/linux-mbp-arch.git`
    * `cd linux-[INSERT VERSION NUMBER HERE]`

4. Manually apply the patches to the Linux kernel

    * `for i in /path/to/linux-mbp-arch-master/*.patch; do patch -p1 --verbose < $i; done`

5. Configure the kernel then compile it. This will take a while

    * Make sure you have `libncurses-dev libssl-dev flex bison` installed
    * `make menuconfig`
    * SAVE, OK, then EXIT
    * `make -j8`
    * `sudo make modules_install -j8`
    * `sudo make install -j8`

6. Make the kernel lighter, then update initramfs

    * `sudo find . -name *.ko -exec strip --strip-unneeded {} +`
    * `sudo update-initramfs -u`

7. Make sure the new initrd.img, vmlinuz, and config are in /boot

    * `cd /boot && ls`

8. Reboot your computer

    * `sudo reboot`

9. Verify the kernel upgraded successfully

    * `uname -r`

If it reports the kernel you wanted to upgrade to, you are successful!
