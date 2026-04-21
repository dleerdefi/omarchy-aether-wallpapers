--
-- Aether Remove from Theme - Elephant/Walker menu
-- Lists all wallpapers in the current theme (bundled + user-added + inactive).
-- Enter = deactivate (or reactivate if inactive), Ctrl+D = permanently delete.
--
-- Part of omarchy-aether-wallpapers: https://github.com/dleerdefi/omarchy-aether-wallpapers
--
Name = "aetherRemoveFromTheme"
NamePretty = "Remove Wallpaper from Theme"
Cache = false
HideFromProviderlist = true
SearchName = true

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function FormatName(filename)
  local name = filename:gsub("%.[^%.]+$", "")
  name = name:gsub("-", " ")
  return name
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")

  -- Read current theme name
  local theme_name_file = io.open(home .. "/.config/omarchy/current/theme.name", "r")
  local theme_name = theme_name_file and theme_name_file:read("*l") or nil
  if theme_name_file then
    theme_name_file:close()
  end

  if not theme_name then
    return entries
  end

  local user_bg_dir = home .. "/.config/omarchy/backgrounds/" .. theme_name
  local theme_bg_dir = home .. "/.local/share/omarchy/themes/" .. theme_name .. "/backgrounds"
  local inactive_dir = user_bg_dir .. "/.inactive"

  -- Determine current active wallpaper
  local current_bg = nil
  local bg_link = io.popen("readlink -f " .. ShellEscape(home .. "/.config/omarchy/current/background") .. " 2>/dev/null")
  if bg_link then
    current_bg = bg_link:read("*l")
    bg_link:close()
  end

  -- List active wallpapers from both bundled and user directories
  local dirs = { theme_bg_dir, user_bg_dir }
  local seen = {}

  for _, dir in ipairs(dirs) do
    local handle = io.popen(
      "find " .. ShellEscape(dir)
        .. " -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.webp' \\) 2>/dev/null | sort"
    )
    if handle then
      for wallpaper in handle:lines() do
        local filename = wallpaper:match("([^/]+)$")
        if filename and not seen[filename] then
          seen[filename] = true
          local label = FormatName(filename)
          if current_bg and wallpaper == current_bg then
            label = label .. " [active]"
          end

          table.insert(entries, {
            Text = label,
            Value = wallpaper,
            Actions = {
              activate = home .. "/.local/bin/aether-remove-from-theme " .. ShellEscape(wallpaper),
              delete = home .. "/.local/bin/aether-remove-from-theme --delete " .. ShellEscape(wallpaper),
            },
            Preview = wallpaper,
            PreviewType = "file",
          })
        end
      end
      handle:close()
    end
  end

  -- List inactive wallpapers
  local inactive_handle = io.popen(
    "find " .. ShellEscape(inactive_dir)
      .. " -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.webp' \\) 2>/dev/null | sort"
  )
  if inactive_handle then
    for wallpaper in inactive_handle:lines() do
      local filename = wallpaper:match("([^/]+)$")
      if filename then
        local label = FormatName(filename) .. " [inactive]"

        table.insert(entries, {
          Text = label,
          Value = wallpaper,
          Actions = {
            activate = home .. "/.local/bin/aether-reactivate-wallpaper " .. ShellEscape(wallpaper),
            delete = home .. "/.local/bin/aether-remove-from-theme --delete " .. ShellEscape(wallpaper),
          },
          Preview = wallpaper,
          PreviewType = "file",
        })
      end
    end
    inactive_handle:close()
  end

  return entries
end
