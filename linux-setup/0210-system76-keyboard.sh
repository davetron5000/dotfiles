#!/usr/bin/env bash

set -e

3384:0005
sudo apt update
sudo apt install --yes evtest

echo "you need to sudo edit this file (which may not exist):"
echo
echo "   /etc/udev/hwdb.d/90-system76-keyboard-remap.hwdb"
echo 
echo "To swap Cmd and Alt, add this to the file:"
echo
echo "evdev:input:b0003v3384p0005*"
echo " KEYBOARD_KEY_700e3=leftalt"
echo " KEYBOARD_KEY_700e2=leftmeta"
echo
echo "These values can be discovered via 'sudo evtest' and pressing keys.  evtest will show"
echo "/dev/input/eventNN devices names, so choose the one that is the system76 keyboard with"
echo "the ' Keyboard' suffix."
echo
echo "Once the file has been edited, restart whatever:"
echo
echo "  sudo systemd-hwdb update && sudo udevadm trigger"
echo
echo "This may not work, so you can also do:"
echo
echo "  sudo udevadm trigger --action=add /dev/input/event25 # '25' is what you chose in evtest above"
echo
echo "Cool."

echo
echo
