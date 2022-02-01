#!/usr/bin/env bash
# Copyright (c) 2022 Aditya Garg

echo "Setting up the Touch Bar"
echo -e "# display f* key in touchbar\noptions apple-ib-tb fnmode=1" | sudo tee /etc/modprobe.d/apple-tb.conf >/dev/null
echo -e "# delay loading of the touchbar driver\ninstall apple-ib-tb /bin/sleep 7; /sbin/modprobe --ignore-install apple-ib-tb" | sudo tee /etc/modprobe.d/delay-tb.conf >/dev/null

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
echo "Changing default mode ..."
echo "# display f* key in touchbar" > /etc/modprobe.d/apple-tb.conf
echo "options apple-ib-tb fnmode=$tb" >> /etc/modprobe.d/apple-tb.conf
rm /etc/modprobe.d/delay-tb.conf
brightness=$(cat /sys/class/leds/apple::kbd_backlight/brightness)
modprobe -r apple-ib-tb
modprobe apple-ib-tb
echo "# delay loading of the touchbar driver" > /etc/modprobe.d/delay-tb.conf
echo "install apple-ib-tb /bin/sleep 7; /sbin/modprobe --ignore-install apple-ib-tb" >> /etc/modprobe.d/delay-tb.conf
echo $brightness > /sys/class/leds/apple::kbd_backlight/brightness
echo "Done!"' | sudo tee /usr/local/bin/touchbar >/dev/null

sudo chmod a+x /usr/local/bin/touchbar
sudo chown root:root /usr/local/bin/touchbar

echo "Run sudo touchbar to change default Touch Bar mode in subsequent boots"
echo "Reboot to finish setting up Touch Bar"
