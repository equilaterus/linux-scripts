# Install qView and set it as the default image viewer

#!/usr/bin/env bash

set -e

APP="io.github.qview.QView"
DESKTOP="$APP.desktop"

echo "📦 Installing qView (Flatpak)..."
flatpak install -y flathub $APP

echo "🖼️ Setting qView as default image viewer..."

# Common image MIME types
MIME_TYPES=(
  "image/jpeg"
  "image/png"
  "image/webp"
  "image/gif"
  "image/bmp"
  "image/tiff"
  "image/heif"
  "image/svg+xml"
)

for mime in "${MIME_TYPES[@]}"; do
    echo " → Assigning $mime to $DESKTOP"
    xdg-mime default "$DESKTOP" "$mime"
done

echo "🔄 Updating MIME cache..."
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "✅ Done. qView is now your default image viewer."
