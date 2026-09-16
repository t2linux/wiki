# Introduction

This page is a guide to help you set up Touch ID on Linux.

## Limitations

Before proceeding further, users should note certain limitations that are currently there for Touch ID support on Linux:

1. Only those fingers that have been enrolled in macOS can be used on Linux. If you delete a fingerprint from macOS, it will no longer be available on Linux as well.
2. If you force shut down the Mac, experience a kernel panic, or in some cases, suspend, Touch ID will stop working on Linux. You simply need to boot into macOS and login to re-enable them.

## Installation

Currently Touch ID support is available only for Ubuntu/Debian based distributions. Follow the instructions below to set up Touch ID.

### Ubuntu

1. Add the **t2-ubuntu-repo** apt repo by following the instructions given [here](https://github.com/AdityaGarg8/t2-ubuntu-repo?tab=readme-ov-file#apt-repository-for-t2-macs).

2. Now install the Touch ID daemon by running:

    ```bash
    sudo apt install t2-touchid
    ```

## Enrolling fingerprints

Once you have installed the Touch ID daemon, your DE will allow you to enroll new fingerprints. Follow your DE's instructions, and enroll only those fingers that have been enrolled in macOS. Any attempt to enroll some other finger will simply lead to failure of that finger to enroll.

## Optional configuration for the Touch ID daemon

The daemon can be further be optionally configured by editing the config file of the daemon. First create the config file by running:

```bash
sudo mkdir -p /etc/kait2en
sudo cp /usr/share/kait2en/t2-touchid.conf /etc/kait2en
```

### Autosync macOS fingerprints with Linux

Instead of manually enrolling your macOS fingerprints on Linux, you can choose to make them sync automatically for a user. For that:

1. Edit `/etc/kait2en/t2-touchid.conf`.
2. Replace `none` in `T2_TOUCHID_BIND_USER` with your username.
3. Run `sudo systemctl restart kait2en-t2-touchid.service`.

### Use fingerprints from a particular macOS user in case multiple macOS user accounts exist

In case multiple user accounts exist on a macOS installation with each account having fingerprints enrolled, you will have to specify the UID of the user whose fingerprints you wish to use on Linux. For that:

1. Boot into macOS. Over there open terminal and run `dscl . -list /Users UniqueID | awk '$2 >=500'`. An example output is:
  
    ```bash
    george                   501
    john                     502
    ```
  
    Here the UID of **george** is **501** and of **john** is **502**.

2. Now boot into Linux. Over there, edit `/etc/kait2en/t2-touchid.conf`.
3. Replace `auto` in `T2_TOUCHID_UID` with your UID you obtained from macOS.
4. Run `sudo systemctl restart kait2en-t2-touchid.service`.

## Credits

Support for Touch ID has been developed by André Eikmeyer from the [KaiT2en project](https://kait2en.org/).
