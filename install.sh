#!/bin/bash

# omarchy-aether-wallpapers installer
# https://github.com/dleerdefi/omarchy-aether-wallpapers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$SCRIPT_DIR/bin" || ! -d "$SCRIPT_DIR/menus" ]]; then
  echo "Error: bin/ and menus/ directories not found. Run from the project root." >&2
  exit 1
fi

BIN_DIR="$HOME/.local/bin"
MENU_DIR="$HOME/.config/elephant/menus"
WALKER_CONFIG="$HOME/.config/walker/config.toml"
HYPR_BINDINGS="$HOME/.config/hypr/bindings.conf"

# Install scripts
echo "Installing scripts to $BIN_DIR..."
mkdir -p "$BIN_DIR"
for SCRIPT in "$SCRIPT_DIR"/bin/*; do
  cp "$SCRIPT" "$BIN_DIR/"
  chmod +x "$BIN_DIR/$(basename "$SCRIPT")"
done

# Install menus
echo "Installing menus to $MENU_DIR..."
mkdir -p "$MENU_DIR"
for MENU in "$SCRIPT_DIR"/menus/*.lua; do
  cp "$MENU" "$MENU_DIR/"
done

# Configure Walker
if [[ -f "$WALKER_CONFIG" ]]; then
  # Add loading placeholder for save menu
  if ! grep -q "aetherSaveToTheme" "$WALKER_CONFIG" 2>/dev/null; then
    sed -i '/"default" = { input.*list = "No Results" }/a "menus:aetherSaveToTheme" = { input = " Search...", list = "Loading wallpapers..." }' "$WALKER_CONFIG"
  fi

  # Add remove menu actions
  if ! grep -q "aetherRemoveFromTheme" "$WALKER_CONFIG" 2>/dev/null; then
    echo "Adding Walker action config..."
    if grep -q '^\[providers\.actions\]' "$WALKER_CONFIG" 2>/dev/null; then
      # Append to existing [providers.actions] section
      sed -i '/^\[providers\.actions\]/a\
"menus:aetherRemoveFromTheme" = [\
  { action = "activate", label = "deactivate/reactivate", default = true, bind = "Return", after = "Close" },\
  { action = "delete", label = "delete permanently", bind = "ctrl d", after = "Close" },\
]' "$WALKER_CONFIG"
    elif grep -q '^\[\[emergencies\]\]' "$WALKER_CONFIG" 2>/dev/null; then
      # Insert new section before [[emergencies]]
      sed -i '/^\[\[emergencies\]\]/i\
[providers.actions]\
"menus:aetherRemoveFromTheme" = [\
  { action = "activate", label = "deactivate/reactivate", default = true, bind = "Return", after = "Close" },\
  { action = "delete", label = "delete permanently", bind = "ctrl d", after = "Close" },\
]\
' "$WALKER_CONFIG"
    else
      # Append to end
      cat >> "$WALKER_CONFIG" << 'EOF'

[providers.actions]
"menus:aetherRemoveFromTheme" = [
  { action = "activate", label = "deactivate/reactivate", default = true, bind = "Return", after = "Close" },
  { action = "delete", label = "delete permanently", bind = "ctrl d", after = "Close" },
]
EOF
    fi
  fi
fi

# Configure Hyprland keybindings
if [[ -f "$HYPR_BINDINGS" ]]; then
  ADDED=false
  if ! grep -q "aetherSaveToTheme" "$HYPR_BINDINGS" 2>/dev/null; then
    echo >> "$HYPR_BINDINGS"
    echo "bindd = SUPER SHIFT, S, Save wallpaper to theme, exec, omarchy-launch-walker -m menus:aetherSaveToTheme --width 800 --minheight 400" >> "$HYPR_BINDINGS"
    ADDED=true
  fi
  if ! grep -q "aether-cycle-theme" "$HYPR_BINDINGS" 2>/dev/null; then
    echo "bindd = SUPER SHIFT ALT, S, Cycle wallpaper, exec, ~/.local/bin/aether-cycle-theme" >> "$HYPR_BINDINGS"
    ADDED=true
  fi
  if ! grep -q "aetherRemoveFromTheme" "$HYPR_BINDINGS" 2>/dev/null; then
    echo "bindd = SUPER SHIFT, R, Remove wallpaper from theme, exec, omarchy-launch-walker -m menus:aetherRemoveFromTheme --width 800 --minheight 400" >> "$HYPR_BINDINGS"
    ADDED=true
  fi
  if ! grep -q "omarchythemes" "$HYPR_BINDINGS" 2>/dev/null; then
    echo "bindd = SUPER SHIFT ALT, W, Switch theme, exec, omarchy-launch-walker -m menus:omarchythemes --width 800 --minheight 400" >> "$HYPR_BINDINGS"
    ADDED=true
  fi
  if $ADDED; then
    echo "Keybindings added to $HYPR_BINDINGS"
  fi
fi

# Restart Elephant to pick up new menus
pkill -x elephant 2>/dev/null

echo
echo "Installed. Keybindings:"
echo "  Super+Shift+S        Save wallpaper to theme"
echo "  Super+Shift+Alt+S    Cycle wallpaper"
echo "  Super+Shift+R        Remove/manage wallpapers (Ctrl+D to delete)"
echo "  Super+Shift+Alt+W    Switch theme"
