# Download a latest release

[See releases](https://github.com/JPyke3/mbp-manjaro/releases)

# Hardware Requirements

* USB-C to ethernet cable adapter.
    * Whilst you can install this over WiFi, it would make it alot easier to use an Adapter. If you would like to use the WiFi to set up Manjaro then refer to the "In order to get WiFi working" Section after you have booted Manjaro
* USB-C to USB Adapter

# Install Procedure

1. Partition your drive in macOS ready for a linux install. You can either use Disk Utility or use Bootcamp, important thing is, is that you have two partitions (Your macOS partition and your new linux one) (It isn't recommended that you totally delete macOS as firmware updates are applied through it).
2. Flash your iso to a USB Stick, If you want a easy way to do this. Use [Balena Etcher](https://www.balena.io/etcher/). For a more command line way of doing this, use dd.
3. Disable macOS secure boot. [Apple's Documentation](https://support.apple.com/en-au/HT208330)

   a. Turn on your Mac, then press and hold Command (⌘)-R immediately after you see the Apple logo to start up from macOS Recovery.  

   b. When you see the macOS Utilities window, choose Utilities > Startup Security Utility from the menu bar.

   c. When you're asked to authenticate, click Enter macOS Password, then choose an administrator account and enter its password.

   d. Set the first option to "No Security", and the second to "Allow booting from External Media".

   e. Reboot your Mac.

4. Once Secure boot is diabled, fully shutdown your Computer and Power it on again whilst holding the Option (⌥) key.
5. Select the yellow EFI System using the arrow keys and hit enter.
6. Scroll down to `Boot x86 64 {Your Edition}` using the arrow keys and press enter.
7. After booting into Manjaro, open a terminal window and run the following commands:

    ```bash
    systemctl start systemd-timesyncd.service
    sudo sed -i 's/https:\/\/jacobpyke.xyz/https:\/\/mbp-repo.jacobpyke.xyz/' /etc/pacman.conf
    sudo pacman -R calamares
    sudo pacman -S calamares-mbp
    ```

    In case you face error stating 'Calamares initialisation failed', turn off your Mac and follow step 5 and 6 again. Then open a terminal window and run these commands instead of the one given above :-

    ```bash
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

8. Open the installer and proceed normally until you hit the partitioning stage. (Installer will automatically start if you have used the second set of commands given above)
9. Click Manual Partitioning
10. Click on `/dev/nvme0n1p1` then press edit at the bottom of the install window, change the Change the Mount Point: `/boot/efi`, after that click okay.
11. Usually, the macOS partition is mounted to `/dev/nvme0n1p2` (Double check this, the Installer should recognize this partition as an `Apple APFS` Partition). Ignore the macOS partition.
12. Delete the partition you created before, this is usually mounted to `/dev/nvme0n1p3`.
13. These next steps involve partitioning the `/boot`(boot), `/`(Root) and `/home`(Home) partitions of your Linux filesystem, if you know what you are doing feel free to skip to the next step (15).

    * Create a `2000 MiB` partition with `ext4` as the file system. Change the mount point to `/boot` and click okay.
    * Create a `51200 MiB` partition with `ext4` as the file system. Change the mount point to `/` and click okay.
    * Use the remaining disk space to create an `ext4` file system. Change the mount point to `/home`.

14. Continue the rest of the setup as normal. Once the setup process is complete, restart your computer remembering to remove the install medium once powered off
15. Once again, Power on your computer whilst holding the Option (⌥) key. Then select EFI Boot
16. Welcome to Manjaro :)
