#!/usr/bin/env bash
# Copyright (c) 2022 Aditya Garg

echo "Setting up the Touch Bar"
echo -e "# display f* key in touchbar\noptions apple-ib-tb fnmode=1" | sudo tee /etc/modprobe.d/apple-tb.conf >/dev/null
echo -e "# blacklist the touchbar driver for delayed loading\nblacklist apple_ib_tb" | sudo tee /etc/modprobe.d/blacklist-tb.conf >/dev/null
echo -e "#!/usr/bin/env bash\n\nmodprobe apple-ib-tb" | sudo tee /usr/local/bin/tb-load.sh >/dev/null

echo '
#!/usr/bin/env bash

echo "Select Touch Bar mode"
echo
echo "0: Only show F1-F12"
echo "1: Show media and brightness controls, use the fn key to switch to F1-12"
echo "2: Show F1-F12, use the fn key to switch to media and brightness controls"
echo "3: Only show media and brightness controls"
echo "4: Only show the escape key"
read tb
echo "# display f* key in touchbar" > /etc/modprobe.d/apple-tb.conf
echo "options apple-ib-tb fnmode=$tb" >> /etc/modprobe.d/apple-tb.conf
brightness=$(cat /sys/class/leds/apple::kbd_backlight/brightness)
modprobe -r apple-ib-tb
modprobe apple-ib-tb
echo $brightness > /sys/class/leds/apple::kbd_backlight/brightness' | sudo tee /usr/local/bin/touchbar >/dev/null

sudo chmod a+x /usr/local/bin/touchbar
sudo chown root:root /usr/local/bin/touchbar

cat <<EOF | sudo tee /etc/systemd/system/touchbar.service >/dev/null
[Unit]
Description=Systemd service to delay loading of the touchbar module.

[Service]
ExecStart=/bin/bash /usr/local/bin/tb-load.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable touchbar.service
echo "Run sudo touchbar to change default Touch Bar mode in subsequent boots"
echo "Reboot to finish setting up Touch Bar"
