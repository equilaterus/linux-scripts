#!/usr/bin/env bash
set -e

# Versions/defaults (edit if needed)
DOTNET_SDK_DEFAULT="8.0"
NVM_VERSION="v0.39.5"
NODE_VERSION_DEFAULT="20"
DEFAULT_SHELL_PATH="/usr/bin/zsh"

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

append_if_missing() {
  local file="$1"
  local line="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf "%s\n" "$line" >> "$file"
  fi
}

setup_nvm_profiles() {
  local profiles=("$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bashrc")
  local line1='export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
  local line2='[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'

  for profile in "${profiles[@]}"; do
    append_if_missing "$profile" "$line1"
    append_if_missing "$profile" "$line2"
  done
}

echo "🛠️ Fedora Development Installer"

if ask "📦 Install VSCodium?"; then
  sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
  printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h\n" | sudo tee /etc/yum.repos.d/vscodium.repo >/dev/null
  sudo dnf install -y codium
  if ask "📝 Set VSCodium as default text editor (text/plain)?"; then
    xdg-mime default codium.desktop text/plain
  fi
fi

if ask "🔧 Install Git?"; then
  sudo dnf install -y git-all
fi

if ask "🐙 Install GitHub Desktop (Flatpak)?"; then
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo flatpak install -y flathub io.github.shiftey.Desktop
fi

if ask "🐳 Install Docker Engine + CLI + Compose plugin?"; then
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  if ask "👥 Add user '$USER' to docker group?"; then
    sudo usermod -aG docker "$USER"
    echo "✅ User added to docker group. Log out and log back in to apply it."
  fi
fi

if ask "🧱 Install .NET SDK?"; then
  echo "🔎 Available .NET SDK packages:"
  dnf list --available "dotnet-sdk-*" 2>/dev/null || true
  read -rp "Enter .NET SDK version (example: 8.0) [${DOTNET_SDK_DEFAULT}]: " dotnet_version
  dotnet_version="${dotnet_version:-$DOTNET_SDK_DEFAULT}"
  sudo dnf install -y "dotnet-sdk-${dotnet_version}"
fi

if ask "🖥️ Install terminal tools (zsh + Powerlevel10k)?"; then
  sudo dnf install -y zsh
  if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
  fi
  append_if_missing "$HOME/.zshrc" 'source ~/powerlevel10k/powerlevel10k.zsh-theme'

  if ask "🔁 Set ${DEFAULT_SHELL_PATH} as default shell for '$USER'?"; then
    chsh -s "$DEFAULT_SHELL_PATH"
    echo "✅ Default shell updated. Re-login to apply."
  fi
fi

if ask "🟢 Install NVM and Node.js?"; then
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  setup_nvm_profiles

  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  read -rp "Enter Node.js version to install with nvm [${NODE_VERSION_DEFAULT}]: " node_version
  node_version="${node_version:-$NODE_VERSION_DEFAULT}"
  nvm install "$node_version"
  nvm use "$node_version"
fi

echo "✅ Development install flow completed."
