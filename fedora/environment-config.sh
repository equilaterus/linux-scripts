#!/usr/bin/env bash
set -e

# Fedora 40 - 42
# Automated environment configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

# Basic config and flatpak
if ask "Proceed with Basic config and Flatpak?"; then
  sudo dnf install -y dnf-plugins-core
  sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo dnf install -y setroubleshoot
  sudo flatpak install -y flathub com.github.tchx84.Flatseal
  echo "Installed Flatseal to customize Flatpak permissions."
fi

# Brave
if ask "Proceed with Brave install?"; then
  sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
  sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
  sudo dnf install -y brave-browser
fi

# Bottles
if ask "Proceed with Bottles tools?"; then
  ## Bottles via flatpak
  sudo flatpak install -y flathub com.usebottles.bottles
  ## ProtonUp-Qt (manage Proton runners)
  sudo flatpak install -y flathub net.davidotek.pupgui2
  
  echo "Installed Bottles (Windows apps) and ProtonUp-Qt (manage Proton-GE versions)."
fi

# Game apps
if ask "Proceed with base Game apps (Steam + Lutris)?"; then
  sudo dnf install -y steam
  sudo flatpak install -y flathub lutris
fi

# Additional config steps?
if ask "Proceed with additional config steps section?"; then
  # Install qview as default image viewer (more stable and minimal than default)?
  if ask "Run install-qview.sh?"; then
    bash "$SCRIPT_DIR/install-qview.sh"
  fi

  # Install apps?
  if ask "Run install-apps.sh?"; then
    bash "$SCRIPT_DIR/install-apps.sh"
  fi

  # Install media codecs?
  if ask "Run install-media-codecs.sh?"; then
    bash "$SCRIPT_DIR/install-media-codecs.sh"
  fi

  # Install games?
  if ask "Run install-games.sh?"; then
    bash "$SCRIPT_DIR/install-games.sh"
  fi

  # Install dev?
  if ask "Run install-dev.sh?"; then
    bash "$SCRIPT_DIR/install-dev.sh"
  fi

  # optimize (run these after updating your system)
  if ask "Run optimize.sh?"; then
    bash "$SCRIPT_DIR/optimize.sh"
  fi

  # Brave with X11
  if ask "Set Brave to use X11 (recommended if brave crashes)?"; then
    bash "$SCRIPT_DIR/brave-x11.sh"
  fi
fi
