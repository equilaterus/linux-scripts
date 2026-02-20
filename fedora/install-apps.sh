#!/usr/bin/env bash
set -e

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "📦 Fedora Apps Installer"

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Sensors
if ask "🌡️ Install sensors tools (lm_sensors, xsensors, Coolero)?"; then
  sudo dnf install -y lm_sensors
  sudo dnf install -y xsensors
  sudo flatpak install -y flathub org.coolero.Coolero
fi

# Office
if ask "🧾 Install office apps (OnlyOffice)?"; then
  sudo flatpak install -y flathub org.onlyoffice.desktopeditors

  if ask "🗑️ Remove LibreOffice?"; then
    sudo dnf remove -y "libreoffice*"
  fi
fi

# Scanner
if ask "🖨️ Install scanner tools (simple-scan, sane-backends)?"; then
  sudo dnf install -y simple-scan
  sudo dnf install -y sane-backends
fi

# VNC
if ask "🖥️ Install VNC tools (tigervnc)?"; then
  sudo dnf install -y tigervnc
fi

# Creative and Productivity Apps
if ask "🎨 Install creative/productivity apps section?"; then
  sudo flatpak install -y flathub com.spotify.Client
  sudo flatpak install -y flathub org.telegram.desktop
  sudo flatpak install -y flathub org.signal.Signal
  sudo flatpak install -y flathub org.blender.Blender
  sudo flatpak install -y flathub com.dropbox.Client
  sudo flatpak install -y flathub org.mozilla.Thunderbird
  sudo flatpak install -y flathub org.gimp.GIMP
  sudo flatpak install -y flathub org.inkscape.Inkscape
  sudo flatpak install -y flathub org.audacityteam.Audacity
  sudo flatpak install -y flathub io.github.achetagames.epic_asset_manager
  sudo flatpak install -y flathub org.kde.kcolorchooser
  sudo flatpak install -y flathub org.musescore.MuseScore
  sudo flatpak install -y flathub com.obsproject.Studio
fi

# Converter
if ask "🎞️ Install converter apps section (HandBrake)?"; then
  sudo flatpak install -y flathub fr.handbrake.ghb
fi

# Downloaders
if ask "⬇️ Install downloaders section (JDownloader, qBittorrent, Video Downloader)?"; then
  sudo flatpak install -y flathub org.jdownloader.JDownloader
  sudo flatpak install -y flathub org.qbittorrent.qBittorrent
  sudo flatpak install -y flathub com.github.unrud.VideoDownloader
fi

# Hardware Specific
if ask "🖱️ Install hardware-specific tools (Solaar for Logitech)?"; then
  sudo dnf install -y solaar
fi

echo "✅ Apps installation flow completed."
