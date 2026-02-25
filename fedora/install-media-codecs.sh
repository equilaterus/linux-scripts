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
  if ask "🧹 Cleanup first: Do you want to remove the sound-and-video group before proceeding?"; then
    sudo dnf group remove "sound-and-video" -y

    if ask "🧹 Cleanup first: Do you also want to run dnf autoremove now?"; then
      sudo dnf autoremove -y
    fi
  fi

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
  sudo dnf group install "sound-and-video" --skip-broken -y

  # Fedy Installer
  if ask "🧩 WMV Codecs: Do you want to enable the Fedy COPR repo and install Fedy?"; then
    sudo dnf copr enable kwizart/fedy -y
    sudo dnf install fedy -y
    echo "✅ Run fedy in your terminal, then go to Utilities and install Multimedia codecs."
  fi

  # Additional apps
  if ask "🧩 VLC and Lollypop(music): Do you want to install from Flathub?"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub org.videolan.VLC
    sudo flatpak install -y flathub org.gnome.Lollypop
  fi

  # Remove common desktop multimedia apps and their local config/state
  if ask "🧹 Cleanup multimedia apps: Remove Elisa/Dragon/Video(Package: totem)/MusicBrainz/Qmmp and clean local files?"; then
    packages_to_remove=()
    rpm -q elisa-player &>/dev/null && packages_to_remove+=(elisa-player)
    rpm -q dragon &>/dev/null && packages_to_remove+=(dragon)
    rpm -q totem &>/dev/null && packages_to_remove+=(totem)
    rpm -q musicbrainz-picard &>/dev/null && packages_to_remove+=(musicbrainz-picard)
    rpm -q qmmp &>/dev/null && packages_to_remove+=(qmmp)
    rpm -q qmmp-qt6 &>/dev/null && packages_to_remove+=(qmmp-qt6)
    rpm -q audacious &>/dev/null && packages_to_remove+=(audacious)

    if ((${#packages_to_remove[@]} > 0)); then
      sudo dnf remove -y "${packages_to_remove[@]}"
    else
      echo "ℹ️ No target multimedia apps are installed."
    fi

    rm -rf \
      ~/.config/elisa* ~/.local/share/elisa* \
      ~/.config/dragon* \
      ~/.config/totem* ~/.local/share/totem* \
      ~/.config/MusicBrainz* ~/.local/share/MusicBrainz* \
      ~/.config/picard* ~/.local/share/picard* \
      ~/.config/qmmp* ~/.local/share/qmmp* \
      ~/.config/audacious* ~/.local/share/audacious*

    sudo dnf autoremove -y
    echo "✅ Multimedia app cleanup completed."
  fi
fi
