--
-- Aether Save to Theme - Elephant/Walker menu
-- Lists Aether favorites and local wallpapers for saving to the current Omarchy theme.
-- Favorites not yet downloaded show without preview and are fetched on selection.
-- A background download is kicked off so previews appear on the next open.
--
-- Part of omarchy-aether-wallpapers: https://github.com/dleerdefi/omarchy-aether-wallpapers
--
Name = "aetherSaveToTheme"
NamePretty = "Save Wallpaper to Theme"
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
  local aether_dir = home .. "/.local/share/aether/wallpapers"
  local favorites_path = home .. "/.config/aether/favorites.json"

  os.execute("mkdir -p " .. ShellEscape(aether_dir))

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

  -- Track what's already saved to theme
  local saved = {}
  local saved_handle = io.popen(
    "find " .. ShellEscape(user_bg_dir)
      .. " -maxdepth 1 -type f 2>/dev/null"
  )
  if saved_handle then
    for path in saved_handle:lines() do
      local fname = path:match("([^/]+)$")
      if fname then
        saved[fname] = true
      end
    end
    saved_handle:close()
  end

  -- Scan local wallpapers
  local local_files = {}
  local local_handle = io.popen(
    "find " .. ShellEscape(aether_dir)
      .. " -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.webp' \\) 2>/dev/null | sort"
  )
  if local_handle then
    for wallpaper in local_handle:lines() do
      local filename = wallpaper:match("([^/]+)$")
      if filename then
        local_files[filename] = wallpaper
      end
    end
    local_handle:close()
  end

  -- Parse favorites JSON using jq
  local fav_entries = {}
  local fav_handle = io.popen(
    "jq -r '.[] | [.id, .path] | @tsv' "
      .. ShellEscape(favorites_path) .. " 2>/dev/null"
  )
  if fav_handle then
    for line in fav_handle:lines() do
      local id, url = line:match("^([^\t]+)\t([^\t]+)$")
      if id and url then
        table.insert(fav_entries, { id = id, url = url })
      end
    end
    fav_handle:close()
  end

  -- Kick off background download for missing favorites (non-blocking)
  local to_download = {}
  for _, fav in ipairs(fav_entries) do
    local filename = fav.url:match("([^/]+)$")
    if filename and not local_files[filename] then
      table.insert(to_download, { url = fav.url, path = aether_dir .. "/" .. filename })
    end
  end

  if #to_download > 0 then
    local curl_cmd = "curl -sL --parallel --connect-timeout 10 --max-time 120"
    for _, d in ipairs(to_download) do
      curl_cmd = curl_cmd .. " -o " .. ShellEscape(d.path) .. " " .. ShellEscape(d.url)
    end
    -- Run in background so menu appears instantly
    os.execute("(" .. curl_cmd .. ") >/dev/null 2>&1 &")
  end

  -- Build entries from favorites first (preserves favorite order)
  local seen = {}
  for _, fav in ipairs(fav_entries) do
    local filename = fav.url:match("([^/]+)$")
    if filename and not seen[filename] then
      seen[filename] = true
      local label = FormatName(filename)
      if saved[filename] then
        label = label .. " [saved]"
      end

      local local_path = local_files[filename]

      if local_path then
        -- Already downloaded: preview available, save directly
        table.insert(entries, {
          Text = label,
          Value = local_path,
          Actions = {
            activate = home .. "/.local/bin/aether-save-to-theme " .. ShellEscape(local_path),
          },
          Preview = local_path,
          PreviewType = "file",
        })
      else
        -- Not yet downloaded: no preview, download on selection
        table.insert(entries, {
          Text = label .. " [downloading]",
          Value = fav.url,
          Actions = {
            activate = home .. "/.local/bin/aether-download-and-save " .. ShellEscape(fav.url) .. " " .. ShellEscape(filename),
          },
        })
      end
    end
  end

  -- Add any local wallpapers not in favorites
  for filename, wallpaper in pairs(local_files) do
    if not seen[filename] then
      seen[filename] = true
      local label = FormatName(filename)
      if saved[filename] then
        label = label .. " [saved]"
      end

      table.insert(entries, {
        Text = label,
        Value = wallpaper,
        Actions = {
          activate = home .. "/.local/bin/aether-save-to-theme " .. ShellEscape(wallpaper),
        },
        Preview = wallpaper,
        PreviewType = "file",
      })
    end
  end

  return entries
end
