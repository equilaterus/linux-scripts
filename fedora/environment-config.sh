# Fedora
# Automated environment configuration 

sudo dnf install dnf-plugins-core
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
image.png
# VS Codium
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
sudo dnf install codium
# Set codium as default editor
xdg-mime default codium.desktop text/plain

# Brave
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser

# Git
sudo dnf install git-all

# Github Desktop
sudo rpm --import https://mirror.mwt.me/ghd/gpgkey
sudo sh -c 'echo -e "[shiftkey]\nname=GitHub Desktop\nbaseurl=https://mirror.mwt.me/ghd/rpm\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://mirror.mwt.me/ghd/gpgkey" > /etc/yum.repos.d/shiftkey-desktop.repo'
sudo dnf install github-desktop

# Docker
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
# Add user to docker group
# usermod -aG docker USERNAME

# Dotnet SDKs
sudo dnf install dotnet-sdk-6.0

# Sensors
sudo dnf install lm_sensors xsensors

# Scanner
sudo dnf install simple-scan sane-backends vlc tigervnc setroubleshoot

# Bottles gtk error:
sudo dnf install bottles
sudo dnf install gtksourceview5

# Video previews dolphin
sudo dnf install ffmpegthumbs

# Onlyoffice
sudo flatpak install flathub org.onlyoffice.desktopeditors
# Remove libreoffice
sudo dnf remove installed *libreoffice*

# Game apps
sudo dnf install steam lutris
sudo flatpak install flathub org.scummvm.ScummVM
sudo flatpak install flathub io.github.simple64.simple64

# Other apps
sudo flatpak install flathub com.spotify.Client
sudo flatpak install flathub org.telegram.desktop
sudo flatpak install flathub org.blender.Blender
sudo flatpak install flathub com.dropbox.Client

# Flatseal (admin flatpak permissions)
sudo flatpak install flathub com.github.tchx84.Flatseal
# ProtonUp QT (admin proton runners)
sudo flatpak install flathub net.davidotek.pupgui2

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Install Node.js
nvm install 14
nvm use 14

# Optimizations
sudo systemctl mask systemd-udev-settle
sudo systemctl disable NetworkManager-wait-online.service
# Disable check for updates at startup (KDE):
# sudo mkdir /etc/xdg/autostart.disabled
# sudo mv /etc/xdg/autostart/org.kde.discover.notifier.desktop /etc/xdg/autostart.disabled/org.kde.discover.notifier.desktop

# Recommended
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video

# TERMINAL
# zsh
sudo dnf install zsh
# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
zsh
# Set as main terminal
# usermod --shell /usr/bin/zsh root
# usermod --shell /usr/bin/zsh USERNAME
