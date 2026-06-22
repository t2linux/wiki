# Introduction
This page is a step by step guide on a workaround to fix the GPU sporadically failing to come up on boot with errno -62. It basically keeps restarting the amdgpu driver until it works.

Tested on an iMac 20,1.

## Install

First, clone the repo and cd to it:

```bash
git clone https://github.com/RishonDev/t2amdpatch
cd t2amdpatch
```

Next, run the installer as root:

```bash
chmod +x install.sh
sudo ./install.sh
```

The installer:

- installs the binder service
- updates `/etc/default/grub`
- regenerates `grub.cfg` automatically


### Options

```bash
sudo ./install.sh --help
```

- `--nomodeset on|off` enables or disables `nomodeset` in GRUB
- `--revert` remains available as a compatibility alias for `--nomodeset on`
- `--skip-firmware` skips the firmware and DRM driver installation step
