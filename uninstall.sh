#!/bin/bash

# omarchy-aether-wallpapers uninstaller
# https://github.com/dleerdefi/omarchy-aether-wallpapers

BIN_DIR="$HOME/.local/bin"
MENU_DIR="$HOME/.config/elephant/menus"
WALKER_CONFIG="$HOME/.config/walker/config.toml"
HYPR_BINDINGS="$HOME/.config/hypr/bindings.conf"

# Remove scripts
for SCRIPT in aether-save-to-theme aether-remove-from-theme aether-reactivate-wallpaper aether-cycle-theme aether-download-and-save; do
  rm -f "$BIN_DIR/$SCRIPT"
done
echo "Removed scripts"

# Remove menus
rm -f "$MENU_DIR/aether_save_to_theme.lua"
rm -f "$MENU_DIR/aether_remove_from_theme.lua"
echo "Removed menus"

# Clean Walker config
if [[ -f "$WALKER_CONFIG" ]]; then
  sed -i '/"menus:aetherSaveToTheme"/d' "$WALKER_CONFIG"
  sed -i '/"menus:aetherRemoveFromTheme"/,/^]/d' "$WALKER_CONFIG"
  echo "Cleaned Walker config"
fi

# Clean Hyprland bindings
if [[ -f "$HYPR_BINDINGS" ]]; then
  sed -i '/menus:aetherSaveToTheme/d' "$HYPR_BINDINGS"
  sed -i '/aether-cycle-theme/d' "$HYPR_BINDINGS"
  sed -i '/menus:aetherRemoveFromTheme/d' "$HYPR_BINDINGS"
  sed -i '/menus:omarchythemes.*Switch theme/d' "$HYPR_BINDINGS"
  echo "Cleaned Hyprland bindings"
fi

pkill -x elephant 2>/dev/null

echo
echo "Uninstalled. Wallpapers and theme backgrounds were not removed."
