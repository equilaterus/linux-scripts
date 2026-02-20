#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ask() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "🔄 Post-update Fedora tasks"

if ask "Run brave-x11.sh to force Brave on X11?"; then
  bash "$SCRIPT_DIR/brave-x11.sh"
fi

if ask "Run optimize.sh for post-update optimizations?"; then
  bash "$SCRIPT_DIR/optimize.sh"
fi

echo "✅ Post-update tasks completed."
