#!/usr/bin/env bash
# Copyright (c) 2022 Aditya Garg

set -euo pipefail

if [[ `uname -s` != "Linux" ]] ; then
    echo "This script is intended to be run from Linux. Aborting!"
    exit 1
fi

echo "Setting up the Touch Bar"
echo -e "# display f* key in touchbar\noptions apple-ib-tb fnmode=1" | sudo tee /etc/modprobe.d/apple-tb.conf >/dev/null

cat << EOF | sudo tee /usr/local/bin/touchbar >/dev/null
#!/usr/bin/env bash

set -euo pipefail

echo "Select Touch Bar mode"
echo
echo "0: Only show F1-F12"
echo "1: Show media and brightness controls, use the fn key to switch to F1-F12"
echo "2: Show F1-F12, use the fn key to switch to media and brightness controls"
echo "3: Only show media and brightness controls"
echo "4: Only show the escape key"
read tb
if [[ \$tb != 0 && \$tb != 1 && \$tb != 2 && \$tb != 3 && \$tb != 4 ]]
then
echo "Invalid input. Aborting!"
exit 1
fi
echo "Changing default mode ..."
echo "# display f* key in touchbar" > /etc/modprobe.d/apple-tb.conf
echo "options apple-ib-tb fnmode=\$tb" >> /etc/modprobe.d/apple-tb.conf
bash -c "echo \$tb > /sys/class/input/*/device/fnmode"
echo "Done!"
EOF

sudo chmod a+x /usr/local/bin/touchbar
sudo chown root:root /usr/local/bin/touchbar

echo "Run sudo touchbar to change the default Touch Bar mode"
