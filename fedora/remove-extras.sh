#!/usr/bin/env bash

# KDE PIM/Akonadi purge + NeoChat + lpf-spotify-client (Fedora KDE)
# 1) Dry-run: shows what will be removed
# 2) Apply: removes and then autoremove

PKGS=(
  akonadi-server akonadi-search akonadi-mime akonadi-contacts akonadi-calendar
  akonadi-import-wizard akonadi-server-mysql
  kdepim-runtime kdepim-runtime-libs kdepim-addons libkdepim
  kmail kmail-libs kmail-account-wizard mailcommon mailimporter mailimporter-akonadi messagelib
  korganizer korganizer-libs kontact kontact-libs kontactinterface
  kaddressbook kaddressbook-libs
  calendarsupport eventviews incidenceeditor kcalutils
  kmime kimap kidentitymanagement kldap ksmtp ktnef
  libkgapi libgravatar libksieve pimcommon pim-data-exporter pim-data-exporter-libs pim-sieve-editor
  neochat
  lpf-spotify-client
)

echo "==> Dry-run (no changes):"
sudo dnf remove --assumeno "${PKGS[@]}"

echo
read -rp "Proceed with removal? [y/N]: " ans
if [[ "${ans,,}" != "y" ]]; then
  echo "Aborted."
  exit 0
fi

echo "==> Removing packages..."
sudo dnf remove -y "${PKGS[@]}"

echo "==> Autoremove unused deps..."
sudo dnf autoremove -y

echo "==> Done."
