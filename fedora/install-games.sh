#!/usr/bin/env bash
set -e

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "🎮 Fedora Games Installer"

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Emulator pack
if ask "🕹️ Install emulator pack (ScummVM, simple64, DOSBox-X, FS-UAE)?"; then
  sudo flatpak install -y flathub org.scummvm.ScummVM
  sudo flatpak install -y flathub io.github.simple64.simple64
  sudo flatpak install -y flathub com.dosbox_x.DOSBox-X
  sudo flatpak install -y flathub net.fsuae.FS-UAE
fi

# Morrowind
if ask "🧙 Install OpenMW?"; then
  sudo flatpak install -y flathub org.openmw.OpenMW
fi

# Settlers 2
if ask "🏰 Install The Settlers II: Return to the Roots?"; then
  sudo flatpak install -y flathub info.rttr.Return-To-The-Roots
  cat <<'EOF'
✅ Settlers II installed.
Configuration:
- Copy your original Settlers II game files to: ~/.s25rttr/S2/
EOF
fi

# RollerCoaster Tycoon 2
if ask "🎢 Install OpenRCT2 (Flatpak)?"; then
  sudo flatpak install -y flathub io.openrct2.OpenRCT2
  cat <<'EOF'
✅ OpenRCT2 installed.
Configuration:
- Recommended: install RCT2 through Lutris/Wine for better compatibility.
- If you already have game files, point OpenRCT2 to your RollerCoaster Tycoon 2 data directory on first launch.
EOF
fi

echo "✅ Games installation flow completed."
