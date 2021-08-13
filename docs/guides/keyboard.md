# Tweaks to keyboard layout

Based on https://wiki.archlinux.org/title/Apple_Keyboard you can change the modifier keys layout:

## Switching Cmd and Alt/AltGr

This will switch the left Alt and Cmd key as well as the right Alt/AltGr and Cmd key.

### Temporary and immediate solution:

`echo "1" > /sys/module/hid_apple/parameters/swap_opt_cmd`

Permanent change, taking place at next reboot:

`/etc/modprobe.d/hid_apple.conf`

`options hid_apple swap_opt_cmd=1`

You then need to regenerate the initramfs.

## Swap the Fn and left Control keys

This will switch the Fn and left Control keys.

Temporary and immediate solution:

`echo "1" > /sys/module/hid_apple/parameters/swap_fn_leftctrl`

Permanent change, taking place at next reboot:

`/etc/modprobe.d/hid_apple.conf`

`options hid_apple swap_fn_leftctrl=1`
