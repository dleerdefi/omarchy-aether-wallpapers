# omarchy-aether-wallpapers

Per-theme wallpaper management for [Omarchy](https://omarchy.org) + [Aether](https://github.com/bjarneo/aether). Add Aether favorites to themes, cycle wallpapers, deactivate or delete — all via Walker menus and keybindings.

## Requirements

- [Omarchy](https://omarchy.org)
- [Aether](https://github.com/bjarneo/aether)
- `jq`, `curl`

## Install

```bash
git clone https://github.com/dleerdefi/omarchy-aether-wallpapers.git
cd omarchy-aether-wallpapers
./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

Your downloaded wallpapers and theme background assignments are preserved.

## Keybindings

| Keybind | Action |
|---------|--------|
| `Super+Shift+S` | Add Aether wallpaper to current theme |
| `Super+Shift+Alt+S` | Cycle to next wallpaper |
| `Super+Shift+R` | Manage theme wallpapers |
| `Super+Shift+Alt+W` | Switch theme |

In the remove menu (`Super+Shift+R`):

| Key | Action |
|-----|--------|
| `Enter` | Deactivate (or reactivate if `[inactive]`) |
| `Ctrl+D` | Permanently delete |

## How it works

**Save** (`Super+Shift+S`) — Wallpapers you favorite in Aether become available to add to any Omarchy theme. This menu lists your favorites with full-res previews (downloaded in the background on first open). Wallpapers already added to the current theme are marked `[saved]`.

![Save to theme](screenshots/save-to-theme.png)

**Cycle** (`Super+Shift+Alt+S`) rotates through bundled and user-added theme wallpapers.

**Manage** (`Super+Shift+R`) lists active and deactivated wallpapers in the current theme. Deactivated wallpapers are hidden from cycling but restorable. If the active wallpaper is removed, the next one is shown automatically.

![Remove from theme](screenshots/remove-from-theme.png)

**Switch theme** (`Super+Shift+Alt+W`) opens the Omarchy theme picker with previews.

![Switch theme](screenshots/switch-theme.png)

## License

MIT
