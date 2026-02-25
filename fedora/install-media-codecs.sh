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

  # VLC (Flatpak)
  if ask "🧩 VLC: Do you want to install VLC from Flathub?"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub org.videolan.VLC
  fi

  # Remove default KDE media players
  if ask "🧹 KDE Players: Do you want to remove Elisa and Dragon and clean their config files?"; then
    packages_to_remove=()
    rpm -q elisa-player &>/dev/null && packages_to_remove+=(elisa-player)
    rpm -q dragon &>/dev/null && packages_to_remove+=(dragon)

    if ((${#packages_to_remove[@]} > 0)); then
      sudo dnf remove -y "${packages_to_remove[@]}"
    else
      echo "ℹ️ Elisa and Dragon are not installed."
    fi

    rm -rf ~/.config/elisa* ~/.local/share/elisa* ~/.config/dragon*
    echo "✅ Elisa/Dragon config cleanup completed."
  fi
fi
