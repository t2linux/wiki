# Updating Kernel

`linux-mbp` can be updated with `sudo pacman -Syu`, however it currently hasn't been updated for a while, so you may want to install a newer kernel that will work with OTP firmware selection.

Download the `.pkg.tar.zst` files from [here](https://github.com/Redecorating/mbp-16.1-linux-wifi/releases/latest) (you can skip the "docs" one), and run `sudo pacman -U path/to/pkg.tar.zsg path/to/other/pkg.tar.zst`. This kernel already includes apple-ibridge and apple-bce so the dkms versions of those modules are optional.

You can also use releases from [https://github.com/jamlam/mbp-16.1-linux-wifi](https://github.com/jamlam/mbp-16.1-linux-wifi) or [https://github.com/aunali1/linux-mbp-arch](https://github.com/aunali1/linux-mbp-arch)(Doesn't yet support OTP firmware selection). These won't have apple-bce and apple-ibridge included, so make sure dkms installs those modules for the new kernels if you need them (refer to the [dkms guide](https://wiki.t2linux.org/guides/dkms/) for this).

# Building Kernel

```sh
git clone https://github.com/Redecorating/mbp-16.1-linux-wifi
cd mbp-16.1-linux-wifi
makepkg -si
```

You can instead clone the other repos mentioned under [Updating Kernel](https://wiki.t2linux.org/distributions/arch/faq/#updating-kernel). You may need to change the folder you `cd` into.
