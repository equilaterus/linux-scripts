#!/usr/bin/env bash
set -e

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "🚀 Fedora Optimization Script"

# 1. Disable systemd-udev-settle
if ask "🔧 Do you want to mask systemd-udev-settle to reduce boot time?"; then
  sudo systemctl mask systemd-udev-settle
fi

# 2. Disable NetworkManager-wait-online
if ask "🔧 Do you want to disable NetworkManager-wait-online.service?"; then
  sudo systemctl disable NetworkManager-wait-online.service
fi

# 3. KDE Tweaks
if command -v plasmashell &>/dev/null; then
  echo "🧠 KDE environment detected."

  # Disable Discover notifier
  if [ -f "/etc/xdg/autostart/org.kde.discover.notifier.desktop" ] && \
     ask "🛑 Do you want to disable the Discover update notifier on KDE login?"; then
    sudo mkdir -p /etc/xdg/autostart.disabled
    sudo mv /etc/xdg/autostart/org.kde.discover.notifier.desktop \
         /etc/xdg/autostart.disabled/
  fi

  # Disable calendar reminder
  if [ -f "/etc/xdg/autostart/org.kde.kalendarac.desktop" ] && \
     ask "📅 Do you want to disable the KDE calendar reminder?"; then
    mkdir -p ~/.config/autostart
    cp /etc/xdg/autostart/org.kde.kalendarac.desktop ~/.config/autostart
    sed -i 's/X-KDE-autostart-condition=kalendaracrc:General:Autostart:true/X-KDE-autostart-condition=kalendaracrc:General:Autostart:false/' \
        ~/.config/autostart/org.kde.kalendarac.desktop
  fi
fi

# 4. DNF Optimization
if ask "⚙️ Do you want to optimize DNF (faster downloads, clean cache, autoremove unused packages)?"; then
  DNF_CONF="/etc/dnf/dnf.conf"
  
  # Add performance tuning options
  if ! grep -q "^max_parallel_downloads=" "$DNF_CONF"; then
    sudo tee -a "$DNF_CONF" >/dev/null <<EOF

# 🍃 Performance optimizations
max_parallel_downloads=10
fastestmirror=True
EOF
    echo "✅ DNF config updated."
  else
    echo "ℹ️ DNF already has optimization entries."
  fi

  echo "🧹 Removing unused packages (autoremove)..."
  sudo dnf autoremove

  echo "🧽 Cleaning all DNF cache..."
  sudo dnf clean all

  echo "🔄 Rebuilding DNF metadata cache..."
  sudo dnf makecache

  echo "✅ DNF optimization complete."
fi

# 5. Final summary
cat <<EOF

✅ All selected optimizations completed.

🎮 Tip: For gaming, launch Steam titles with:
     gamemoderun %command%

🧠 KDE tweaks are applied only if you opted in.
🧭 Revert changes by moving files back or editing ~/.config/autostart

More info: https://thescienceofcode.com/fedora-linux-optimize/

EOF
