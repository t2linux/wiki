
# Option 1: Docker - All Linux Distros
First, you need to ensure that docker isn't using `overlay` or `overlay2` filesystems. This can be verified by running `docker info`. And will be shown next to `Storage Driver`.

In the event that you are running `overlay`, [Look at this docker documentation](https://docs.docker.com/storage/storagedriver/vfs-driver/) on how to switch to VFS.

*Note, this doesn't work on OSX or Windows, I am working closely with the Manjaro Devs on this one.*

**Quick Docker Install Script - For Linux**
```
sh -c "$(curl -fsSL "https://raw.githubusercontent.com/JPyke3/mbp-manjaro/master/build-in-docker.sh")"
```

**Docker Command**

```
docker run --privileged \
          -v ~/manjaro-mbp-iso:/root/out \
          -v {PATH-TO-REPO}:/root/iso-profiles\
          --env KERNEL=linux57-mbp\
          --env EDITION=gnome\
          jpyke3/mbp-manjaro-buildiso
```

## Command Breakdown
 - `--privileged`
   - This is required for allowing the filesystems to be created. (This is a security risk! Read for yourself the documentation on this flag)
 - `-v`
   - Create a folder on your host filesystem to retrieve the compiled files from the container
   - Ensure that `{PATH-TO-REPO}` is replaced by the absolute path to this repo's files.
 - `--env`
   - There are two environment variables:
     - `KERNEL`: This is used for defining which kernel version to use. All packages will follow the `-mbp` naming scheme.
     - `EDITION`: This is used for defining which edition of manjaro you would like to install.


# Option 2: Manually on an existing Manjaro Install

First Install Manjaro Tools:
```
pamac install manjaro-tools-iso git
```

Clone the repository to your home directory
```
git clone https://github.com/JPyke3/mbp-manjaro ~/iso-profiles
```
run a command corrisponding to your preferred version of Manjaro:

```
buildiso -f -p {edition} -k linux57-mbp
```

*Available Options are:*
```
architect  gnome  kde nxd  xfce awesome  bspwm-mate  cinnamon  i3    lxqt  openbox  webdad bspwm    budgie      deepin    lxde  mate  ukui
```

## File Locations 
Navigate to the directory for your iso file. If Using a official edition go to:
```
cd /var/cache/manjaro-tools/iso/manjaro/{NAME_OF_EDITION}/20.0.3/
```
If using a community edition to:
```
cd /var/cache/manjaro-tools/iso/community/{NAME_OF_EDITION}/20.0.3/
```
