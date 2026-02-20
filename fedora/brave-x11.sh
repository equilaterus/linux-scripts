# Force Brave to use X11 instead of Wayland to avoid errors and improve performance.
# Useful on Fedora 43 with AMD GPUs.
# This may change in the future but if you experience crashes with Brave this is the way to go.

#!/usr/bin/env bash

set -e

DESKTOP_SYSTEM="/usr/share/applications/brave-browser.desktop"
DESKTOP_USER="$HOME/.local/share/applications/brave-browser.desktop"

FLAG="--ozone-platform=x11"

echo "🔍 Checking Brave launcher..."

# Decide which launcher file to use
if [[ -f "$DESKTOP_USER" ]]; then
    DESKTOP_FILE="$DESKTOP_USER"
    LOCATION="user"
elif [[ -f "$DESKTOP_SYSTEM" ]]; then
    DESKTOP_FILE="$DESKTOP_SYSTEM"
    LOCATION="system"
else
    echo "❌ Brave .desktop file not found."
    exit 1
fi

echo "📄 Using $LOCATION launcher:"
echo "   $DESKTOP_FILE"
echo

# Check flag
if grep -q  -- "$FLAG" "$DESKTOP_FILE"; then
    echo "✅ Brave is already patched (X11 forced)."
    exit 0
fi

echo "⚠️  Brave is NOT patched."
echo
read -rp "👉 Do you want to patch it now? [y/N]: " ANSWER

if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "🚪 Leaving without changes."
    exit 0
fi

# If system file, require sudo
if [[ "$LOCATION" == "system" ]]; then
    echo "🔐 Sudo required to patch system launcher."
    sudo cp "$DESKTOP_FILE" "$DESKTOP_FILE.bak"
    sudo sed -i "s|^Exec=.*|& $FLAG|" "$DESKTOP_FILE"
else
    cp "$DESKTOP_FILE" "$DESKTOP_FILE.bak"
    sed -i "s|^Exec=.*|& $FLAG|" "$DESKTOP_FILE"
fi

echo "🛠️  Patched successfully."
echo "📦 Backup created:"
echo "   $DESKTOP_FILE.bak"
echo
echo "🚀 Restart Brave for changes to apply."
