# Download a latest release

[See releases](https://github.com/JPyke3/mbp-manjaro/releases)

# Hardware Requirements

* USB-C to Ethernet cable adapter.
    * While you can install Manjaro over WiFi, it would be a lot easier to use an Adapter during the installation process.
* USB-C to USB Adapter
* USB drive

# Install Procedure

1. Partition your drive in macOS so you can install Linux. You can either use Disk Utility or use Bootcamp, but the important thing is that you have two partitions (your macOS partition and your new linux one). It isn't recommended that you completely delete macOS as firmware updates are applied through it.
2. Flash your Manjaro ISO to a USB Stick. If you want an easier way to do this. Use [Balena Etcher](https://www.balena.io/etcher/). Terminal users can also use dd.
3. Disable macOS secure boot. [Apple's Documentation](https://support.apple.com/en-au/HT208330)

    1. Turn on your Mac, then press and hold Command (⌘)-R immediately after you see the Apple logo to start up from macOS Recovery.
    2. When you see the macOS Utilities window, choose Utilities > Startup Security Utility from the menu bar.
    3. When you're asked to authenticate, click Enter macOS Password, then choose an administrator account and enter its password.
    4. Set the first option to "No Security", and the second to "Allow booting from External Media".
    5. Reboot your Mac.

4. Once Secure boot is diabled, fully shutdown your Computer and Power it on again whilst holding the Option (⌥) key.
5. Select the yellow EFI System option using the arrow keys and hit enter.
6. Scroll down to `Boot x86 64 {Your Edition}` using the arrow keys and press enter.
7. After booting into Manjaro, open a terminal window and run the following commands. If asked to enter a password, use `manjaro` as the password.

    ```sh
    systemctl start systemd-timesyncd.service
    sudo sed -i 's/https:\/\/jacobpyke.xyz/https:\/\/mbp-repo.jacobpyke.xyz/' /etc/pacman.conf
    sudo pacman -R calamares
    sudo pacman -Sy calamares-mbp
    ```

    In case you get the error 'Calamares initialisation failed', turn off your Mac and follow steps 5 and 6 again. Then open a terminal window and run these commands instead:

    ```sh
    systemctl start systemd-timesyncd.service
    sudo sed -i 's/https:\/\/jacobpyke.xyz/https:\/\/mbp-repo.jacobpyke.xyz/' /etc/pacman.conf
    sudo pacman -R calamares
    sudo pacman -Sy cmake extra-cmake-modules pkgconfig
    sudo pacman -Sy lib32-glibc gcc
    wget https://github.com/KDE/kpmcore/archive/v4.2.0.tar.gz
    tar -xvf v4.2.0.tar.gz
    cd kpmcore-4.2.0
    mkdir build
    cd build
    cmake ..
    sudo make install
    sudo pacman -Sy calamares-mbp
    sudo calamares
    ```

8. Open the installer and proceed normally until you arrive at the partitioning stage (the Installer will automatically start if you have used the second set of commands given above).
9. Click Manual Partitioning.
10. Click on `/dev/nvme0n1p1`, then press edit at the bottom of the install window, change the mount point to `/boot/efi`, and then click ok.
11. Usually, the macOS partition is mounted to `/dev/nvme0n1p2` (the `Apple APFS` Partition). Ignore this partition.
12. Delete the partition you created before - this is usually mounted to `/dev/nvme0n1p3`.
13. These next steps involve partitioning the `/boot`(boot), `/`(Root) and `/home`(Home) partitions of your Linux filesystem. If you know what you're doing, feel free to skip to step 15.

    * Create a `2000 MiB` partition with `ext4` as the file system. Change the mount point to `/boot` and click ok.
    * Create a `51200 MiB` partition with `ext4` as the file system. Change the mount point to `/` and click ok.
    * Use the remaining disk space to create an `ext4` file system. Change the mount point to `/home`.

14. Continue the rest of the setup as normal. Once the setup process is complete, restart your computer. Make sure you remove the install medium once powered off.
15. Once again, power on your computer whilst holding the Option (⌥) key. Then select EFI Boot.
16. Welcome to Manjaro :)
