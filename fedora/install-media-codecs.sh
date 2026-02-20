# Install additional media codecs and video previews for Fedora
# Important: For WMV support, open Fedy and install codecs from the app.

#!/usr/bin/env bash
set -e

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "🎵 Fedora Media Codecs Installer"

if ask "🎵 Codecs: Do you want to install full multimedia codec support (RPM Fusion)?"; then
  # Check if RPM Fusion repos are already installed
  if rpm -q rpmfusion-free-release &>/dev/null && rpm -q rpmfusion-nonfree-release &>/dev/null; then
    echo "✅ RPM Fusion repos are already installed."
  else
    echo "🌐 Installing RPM Fusion free & nonfree repos..."
    sudo dnf install -y \
      https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  fi

  sudo dnf install ffmpegthumbs
  sudo dnf group install "multimedia" --setopt=install_weak_deps=False --exclude=PackageKit-gstreamer-plugin --skip-broken -y
  sudo dnf group install --with-optional "sound-and-video" --skip-broken -y

  # Fedy Installer
  if ask "🧩 WMV Codecs: Do you want to enable the Fedy COPR repo and install Fedy?"; then
    sudo dnf copr enable kwizart/fedy -y
    sudo dnf install fedy -y
    echo "✅ Run fedy in your terminal, then go to Utilities and install Multimedia codecs."
  fi

  # VLC
  if ask "🧩 Additional Codecs: Do you want to install VLC and extra codecs?"; then
    sudo dnf install vlc vlc-plugin-gstreamer vlc-plugin-ffmpeg -y --skip-broken -y
  fi
fi
