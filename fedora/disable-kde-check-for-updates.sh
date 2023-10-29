# You may need to re-apply this commands after some system updates that restore some KDE settings to defaults.
# In case that you’ve wanted to go back, just restore the files from the backup directory autostart.disabled.
# More info: 
# https://thescienceofcode.com/fedora-linux-optimize/

sudo mkdir /etc/xdg/autostart.disabled
sudo mv /etc/xdg/autostart/org.kde.discover.notifier.desktop /etc/xdg/autostart.disabled/org.kde.discover.notifier.desktop
