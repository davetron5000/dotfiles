#!/usr/bin/env bash

set -e

# This list must have all the keybindings in it
gsettings set org.gnome.settings-daemon.plugins.media-keys \
          custom-keybindings \
          "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/gpaste/']"

# Toggle ULauncher
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/ \
          name 'Ulauncher Toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/ \
          command 'ulauncher-toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/ \
          binding '<Shift><Alt>space'

# Toggle GPaste
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/gpaste/ \
          name 'GPaste Toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/gpaste/ \
          command 'gpaste-client ui'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/gpaste/ \
          binding '<Ctrl><Alt>c'

# In theroy, 0100-map-caps-to-escape.sh did part of this, but I don't want to undo it
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape', 'compose:ralt']"


# Remove the "windows key zooms everything out" feature
gsettings set org.gnome.mutter overlay-key ''


# Fix
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Alt><Shift>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Alt>h']"

# Monitor Movement

gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Super><Shift>Left', '<Super><Shift>h']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Super><Shift>Right', '<Super><Shift>l']"




# was: org.gnome.mutter.keybindings toggle-tiled-left ['<Super>Left']
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Alt><Shift>h']"
# was: org.gnome.mutter.keybindings toggle-tiled-right ['<Super>Right']
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Alt><Shift>l']"



# To disable
# was: org.gnome.desktop.wm.keybindings activate-window-menu ['<Alt>space']
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"
# was: org.gnome.settings-daemon.plugins.media-keys logout ['<Control><Alt>Delete']
gsettings set org.gnome.settings-daemon.plugins.media-keys logout "[]"
# was: org.gnome.settings-daemon.plugins.media-keys magnifier ['<Alt><Super>8']
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier "[]"
# was org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static ['<Super>o', 'XF86RotationLockToggle']
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
# was: org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-in ['<Alt><Super>equal']
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-in "[]"
# was: org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-out ['<Alt><Super>minus']
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-out "[]"
