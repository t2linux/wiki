# Suspend

Suspend is working on all T2 Macs since early 2026, but not on all of them out of the box.
On some hardware we need workarounds because of upstream driver/ACPI or Apple firmware issues.

## Thunderbolt / slow resume times

We can either have fast resume from suspend, or we can have Thunderbolt support. Not both.
Linux by default masquerades as macOS to make certain features accessible.
Thunderbolt is one of those.
On the other hand, masquerading as macOS makes resume from suspend extremely slow.
Depending on the number of cores your CPU has, it can take up to three minutes on a I9,
while it takes around 20 seconds on a I5 because `smpboot`-times rise exponentially per core.

To stop masquerading as macOS and to make the CPU cores wake within milliseconds,
you need to add the kernel arguments

```bash
acpi_osi=!Darwin acpi_osi='Windows 2012'
```

How to add kernel parameter is described in [postinstall](postinstall.md/#add-necessary-kernel-parameters).
But note this will break Thunderbolt support. This needs to be fixed in the Linux
mainline ACPI driver and is a trade-off we have to make for now.

## iGPU black screen on resume

If using the iGPU causes the screen to be black after waking up from suspend, then try one of these workarounds:

- Add `i915.enable_guc=3` to [your kernel parameters](postinstall.md/#add-necessary-kernel-parameters). If that has a problem, try setting the value to 2 instead of 3.
- Turn the screen off and on after the backlight turns on. For GNOME: type your password then press enter, press Command + L to lock (this should turn off the backlight), then press any key.

## MacBook Pro 15,1 black screen on resume

The MacBook Pro 15,1 suffers the issue to come up with a black screen on resume
because the SMU dies when the driver suspends the hardware. The cause for this is
known and being worked on. As a temporary workaround you can make the iGPU primary
as described in the [hybrid graphics guide](hybrid-graphics.md) and unload/reload the dGPU driver on
suspend using systemd.
Paste and run the following code block to create and enable this service:

```bash
sudo tee /etc/systemd/system/amdgpu-suspend.service >/dev/null <<'EOF'
[Unit]
Description=Unload and Reload amdgpu for Suspend and Resume
Before=sleep.target
StopWhenUnneeded=yes

[Service]
User=root
Type=oneshot
RemainAfterExit=yes

ExecStart=-/usr/bin/modprobe -r amdgpu

ExecStop=-/usr/bin/modprobe amdgpu

[Install]
WantedBy=sleep.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable amdgpu-suspend.service
```

## Broadcom 4377

Opposite to the Broadcom 4364 and 4365, which use dedicated chips and firmwares
for Bluetooth and Wifi, the 4377 uses a single chip and a single unified firmware.
The bluetooth part of the firmware is holding back the 4377 chip from transitioning
from `D0` to `D3cold`. While the 4364 and 4365 don't even need or use the Bluetooth firmware
on Linux, a 4377 user can't choose to not use the BT firmware. What you can do though,
is unloading the Linux drivers on suspend and reloading them on resume using a systemd service.

You will know that you are on affected hardware, when `journalctl -b --grep=4377` returns
something `brcmfmac` related.

If so, simply run the following terminal command:

```bash
sudo tee /etc/systemd/system/brcmfmac-suspend.service >/dev/null <<'EOF'
[Unit]
Description=Unload and Reload brcmfmac for Suspend and Resume
Before=sleep.target
StopWhenUnneeded=yes

[Service]
User=root
Type=oneshot
RemainAfterExit=yes

ExecStart=-/usr/bin/modprobe -r brcmfmac_wcc
ExecStart=-/usr/bin/modprobe -r brcmfmac
ExecStart=-/usr/bin/modprobe -r hci_bcm4377


ExecStop=-/usr/bin/modprobe hci_bcm4377
ExecStop=-/usr/bin/modprobe brcmfmac
ExecStop=-/usr/bin/modprobe brcmfmac_wcc

[Install]
WantedBy=sleep.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable brcmfmac-suspend.service
```
