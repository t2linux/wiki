# Upgrade

Recommendations:

* Perform upgrade from LTS to LTS.

Warnings:

* If you have important data and workspace, make sure that you have backup.
* Make sure you have enough disk space.
* **Ensure that you met all the below requirements so that you can recover in case of failed upgrade.**

# Hardware Requirements

* USB-C to Ethernet adapter **OR** Smartphone capable of USB tethering to provide internet in case of emergency
* A cable that can connect one of the above objects to your Mac

# Kernel Requirements

Check the latest official Ubuntu release and find its kernel version. You need to install the same or higher custom kernel version for your current Ubuntu.

# Install Procedure

Most probably you are using a LTS version of the Ubuntu right now. If a newer LTS Ubuntu is released in April, you will not be notified until Canonical 
release the first point release (e.g. 22.04.1) which normally out around August. However, you can still upgrade to the final version before August.
1. Open a terminal and:

    1. If it's after first point release, do `sudo do-release-upgrade`.

    2. If it's before and the upgrade tool says there is no newer version, try `sudo do-release-upgrade -d`.
  
2. Follow the instruction given by the tool and answer if it asks question about some of the packages that you want to be upgraded, etc.
3. Let the tool download finish and begin the process. Have an eye in the screen to see how it is going. In the middle it might ask you to chose some options.
4. If the installation finish successfully, do a reboot and boot your Mac using the current custom kernel you installed before using the instructions available in the wiki. Otherwise, see the next section.

# Troubleshooting

1. In case the upgrade process gives error about broken packets, do not reboot. Try to resolve the problem first, and resume the process.
2. If your Mac is crashed and you must press and hold power button, then **probably** you will boot to a black screen with minimal console because gnome-shell (default desktop) package is not installed yet. Here you need to deal with all the errors. 
The goal is to install at least a GUI at first place so that you can get rid of the black screen with tiny text, then try to resolve other problems using GUI.

    1. Login with your user and password.

    2. Connect your Mac to the internet using USB-C to Ethernet adapter or use your smart phone's USB tethering.
        * `$ ifconfig -a`, it will show all the available network interfaces. remember the one appears when you connect the USB.
        * bring up the USB interface `$ sudo ifconfig <USB_INTERFACE> up`
        * Ask for an IP using `$ dhclient`
        * Ping `$ ping google.com` to make sure you have access to internet

    3. Try `$ sudo apt install --fix-broken`. If it succeeds, resume upgrade and `$ reboot`. If not, go to 4.
    4. Try `$ sudo apt install gnome-shell` if it succeeds, do `$ reboot`. If not:
        * Try to read the errors and find out the solution. For example if there is conflict between package version, try to remove the installed one by `$ sudo apt autoremove <PACKAGE_NAME>` and the try install gnome desktop again.
        * If you really stuck with installing gnome desktop, try other desktops like: `sudo apt install ubuntu-mate-desktop`

    4. Boot to newly installed desktop and do `sudo apt upgrade` and hope it would end up with success, otherwise try to understand the error and resolve them. Always google your errors.
