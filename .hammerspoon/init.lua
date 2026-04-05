-- ─── Helpers ──────────────────────────────────────────────────
local function yabai(args)
  hs.task.new("/opt/homebrew/bin/yabai", nil, args):start()
end

local function menuOrKey(items, key)
  return function()
    local app = hs.application.frontmostApplication()
    local found = false
    for _, item in ipairs(items) do
      if app:selectMenuItem(item) then
        found = true
        break
      end
    end
    if not found then
      hs.eventtap.keyStroke({"cmd"}, key)
    end
  end
end

-- ─── Sistema ──────────────────────────────────────────────────
hs.hotkey.bind({"cmd"}, "q", function()
  local win = hs.window.focusedWindow()
  if win then win:close() end
end)
hs.hotkey.bind({"cmd"}, "w", function() end)  -- noopi

hs.hotkey.bind({"cmd"}, "a", function()
  os.execute("open 'raycast://extensions/Caramel/raycast-new-instance/index'")
end)

-- ─── App Launchers ────────────────────────────────────────────
hs.hotkey.bind({"cmd"}, "t", function()
  hs.task.new("/usr/bin/open", nil, {"-n", "-a", "Alacritty"}):start()
end)

hs.hotkey.bind({"cmd"}, "b", function()
  hs.task.new("/usr/bin/open", nil, {"-n", "-a", "Google Chrome"}):start()
end)


-- ─── Window Management ────────────────────────────────────────
hs.hotkey.bind({"cmd"},          "f", function() yabai({"-m", "window", "--toggle", "zoom-fullscreen"})    end)
hs.hotkey.bind({"cmd", "shift"}, "f", function() yabai({"-m", "window", "--toggle", "native-fullscreen"}) end)
hs.hotkey.bind({"cmd", "shift"}, "t", function() yabai({"-m", "window", "--toggle", "float"})             end)

-- ─── Center Window ────────────────────────────────────────────
hs.hotkey.bind({"cmd"}, "c", function()
  local win = hs.window.focusedWindow()
  if win then
    local screen = win:screen():frame()
    local f = win:frame()
    f.x = screen.x + (screen.w - f.w) / 2
    f.y = screen.y + (screen.h - f.h) / 2
    win:setFrame(f)
  end
end)

-- ─── Focus Navigation ─────────────────────────────────────────
hs.hotkey.bind({"cmd"}, "h",     function() yabai({"-m", "window", "--focus", "west"})  end)
hs.hotkey.bind({"cmd"}, "j",     function() yabai({"-m", "window", "--focus", "south"}) end)
hs.hotkey.bind({"cmd"}, "k",     function() yabai({"-m", "window", "--focus", "north"}) end)
hs.hotkey.bind({"cmd"}, "l",     function() yabai({"-m", "window", "--focus", "east"})  end)
hs.hotkey.bind({"cmd"}, "left",  function() yabai({"-m", "window", "--focus", "west"})  end)
hs.hotkey.bind({"cmd"}, "down",  function() yabai({"-m", "window", "--focus", "south"}) end)
hs.hotkey.bind({"cmd"}, "up",    function() yabai({"-m", "window", "--focus", "north"}) end)
hs.hotkey.bind({"cmd"}, "right", function() yabai({"-m", "window", "--focus", "east"})  end)

-- ─── Window Movement ──────────────────────────────────────────
hs.hotkey.bind({"cmd", "shift"}, "h",     function() yabai({"-m", "window", "--warp", "west"})  end)
hs.hotkey.bind({"cmd", "shift"}, "j",     function() yabai({"-m", "window", "--warp", "south"}) end)
hs.hotkey.bind({"cmd", "shift"}, "k",     function() yabai({"-m", "window", "--warp", "north"}) end)
hs.hotkey.bind({"cmd", "shift"}, "l",     function() yabai({"-m", "window", "--warp", "east"})  end)
hs.hotkey.bind({"cmd", "shift"}, "left",  function() yabai({"-m", "window", "--warp", "west"})  end)
hs.hotkey.bind({"cmd", "shift"}, "down",  function() yabai({"-m", "window", "--warp", "south"}) end)
hs.hotkey.bind({"cmd", "shift"}, "up",    function() yabai({"-m", "window", "--warp", "north"}) end)
hs.hotkey.bind({"cmd", "shift"}, "right", function() yabai({"-m", "window", "--warp", "east"})  end)

-- ─── Monitor Focus ────────────────────────────────────────────
hs.hotkey.bind({"cmd", "ctrl"}, "h",     function() yabai({"-m", "display", "--focus", "west"})  end)
hs.hotkey.bind({"cmd", "ctrl"}, "j",     function() yabai({"-m", "display", "--focus", "south"}) end)
hs.hotkey.bind({"cmd", "ctrl"}, "k",     function() yabai({"-m", "display", "--focus", "north"}) end)
hs.hotkey.bind({"cmd", "ctrl"}, "l",     function() yabai({"-m", "display", "--focus", "east"})  end)
hs.hotkey.bind({"cmd", "ctrl"}, "left",  function() yabai({"-m", "display", "--focus", "west"})  end)
hs.hotkey.bind({"cmd", "ctrl"}, "right", function() yabai({"-m", "display", "--focus", "east"})  end)

-- ─── Move Window to Monitor ───────────────────────────────────
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "h",     function() yabai({"-m", "window", "--display", "west",  "--focus"}) end)
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "j",     function() yabai({"-m", "window", "--display", "south", "--focus"}) end)
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "k",     function() yabai({"-m", "window", "--display", "north", "--focus"}) end)
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "l",     function() yabai({"-m", "window", "--display", "east",  "--focus"}) end)
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "left",  function() yabai({"-m", "window", "--display", "west",  "--focus"}) end)
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "right", function() yabai({"-m", "window", "--display", "east",  "--focus"}) end)

-- ─── Workspace Navigation ─────────────────────────────────────
hs.hotkey.bind({"cmd"}, "u", function() yabai({"-m", "space", "--focus", "next"}) end)
hs.hotkey.bind({"cmd"}, "i", function() yabai({"-m", "space", "--focus", "prev"}) end)

-- ─── Move Window to Workspace ─────────────────────────────────
hs.hotkey.bind({"cmd", "ctrl"}, "u", function() yabai({"-m", "window", "--space", "next"}) end)
hs.hotkey.bind({"cmd", "ctrl"}, "i", function() yabai({"-m", "window", "--space", "prev"}) end)

-- ─── Numbered Workspaces ──────────────────────────────────────
for i = 1, 9 do
  local n = tostring(i)
  hs.hotkey.bind({"cmd"},          n, function() yabai({"-m", "space",  "--focus", n}) end)
  hs.hotkey.bind({"cmd", "shift"}, n, function() yabai({"-m", "window", "--space", n}) end)
end

-- ─── Sizing ───────────────────────────────────────────────────
hs.hotkey.bind({"cmd"},          "-", function() yabai({"-m", "window", "--resize", "right:-100:0"})  end)
hs.hotkey.bind({"cmd"},          "=", function() yabai({"-m", "window", "--resize", "right:100:0"})   end)
hs.hotkey.bind({"cmd", "shift"}, "-", function() yabai({"-m", "window", "--resize", "bottom:0:-100"}) end)
hs.hotkey.bind({"cmd", "shift"}, "=", function() yabai({"-m", "window", "--resize", "bottom:0:100"})  end)

-- ─── Lock Screen ──────────────────────────────────────────────
hs.hotkey.bind({"alt"}, "l", function() hs.caffeinate.lockScreen() end)

-- ─── Ctrl → Acción directa (Linux/Windows style) ──────────────

-- Edición
hs.hotkey.bind({"ctrl"}, "a", menuOrKey({{"Edit", "Select All"}, {"Selection", "Select All"}}, "a"))
hs.hotkey.bind({"ctrl"}, "c", menuOrKey({{"Edit", "Copy"}},  "c"))
hs.hotkey.bind({"ctrl"}, "v", menuOrKey({{"Edit", "Paste"}}, "v"))
hs.hotkey.bind({"ctrl"}, "x", menuOrKey({{"Edit", "Cut"}},   "x"))
hs.hotkey.bind({"ctrl"}, "z", menuOrKey({{"Edit", "Undo"}},  "z"))

-- Archivo
hs.hotkey.bind({"ctrl"},          "s", menuOrKey({{"File", "Save"}, {"Edit", "Save"}}, "s"))
hs.hotkey.bind({"ctrl", "shift"}, "s", menuOrKey({{"File", "Save As..."}, {"File", "Save As"}, {"Edit", "Save As..."}}, "s"))
hs.hotkey.bind({"ctrl", "alt"},   "s", menuOrKey({{"File", "Save All"}}, "s"))

-- Navegación y misc
hs.hotkey.bind({"ctrl"}, "n", function() hs.eventtap.keyStroke({"cmd"}, "n") end)  -- new
hs.hotkey.bind({"ctrl"}, "o", function() hs.eventtap.keyStroke({"cmd"}, "o") end)  -- open
hs.hotkey.bind({"ctrl"}, "p", function() hs.eventtap.keyStroke({"cmd"}, "p") end)  -- print
hs.hotkey.bind({"ctrl"}, "f", function() hs.eventtap.keyStroke({"cmd"}, "f") end)  -- find
hs.hotkey.bind({"ctrl"}, "g", function() hs.eventtap.keyStroke({"cmd"}, "g") end)  -- find next
hs.hotkey.bind({"ctrl"}, "r", function() hs.eventtap.keyStroke({"cmd"}, "r") end)  -- reload
hs.hotkey.bind({"ctrl"}, "l", function() hs.eventtap.keyStroke({"cmd"}, "l") end)  -- address bar
hs.hotkey.bind({"ctrl"}, "d", function() hs.eventtap.keyStroke({"cmd"}, "d") end)  -- bookmark
hs.hotkey.bind({"ctrl"}, "=", function() hs.eventtap.keyStroke({"cmd"}, "=") end)  -- zoom in
hs.hotkey.bind({"ctrl"}, "-", function() hs.eventtap.keyStroke({"cmd"}, "-") end)  -- zoom out
hs.hotkey.bind({"ctrl"}, "0", function() hs.eventtap.keyStroke({"cmd"}, "0") end)  -- reset zoom

-- Redo / tabs
hs.hotkey.bind({"ctrl", "shift"}, "z",   function() hs.eventtap.keyStroke({"cmd", "shift"}, "z") end)  -- redo
hs.hotkey.bind({"ctrl", "shift"}, "t",   function() hs.eventtap.keyStroke({"cmd", "shift"}, "t") end)  -- reabrir tab
hs.hotkey.bind({"ctrl", "shift"}, "n",   function() hs.eventtap.keyStroke({"cmd", "shift"}, "n") end)  -- nueva ventana / incógnito
hs.hotkey.bind({"ctrl"},          "tab", function() hs.eventtap.keyStroke({"cmd", "shift"}, "]") end)  -- siguiente tab
hs.hotkey.bind({"ctrl", "shift"}, "tab", function() hs.eventtap.keyStroke({"cmd", "shift"}, "[") end)  -- tab anterior

-- ─── Cmd noops (reemplazados por Ctrl) ────────────────────────
hs.hotkey.bind({"cmd"},          "space", function() end)
hs.hotkey.bind({"cmd"},          "v", function() end)
hs.hotkey.bind({"cmd"},          "x", function() end)
hs.hotkey.bind({"cmd"},          "z", function() end)
hs.hotkey.bind({"cmd"},          "s", function() end)
hs.hotkey.bind({"cmd", "shift"}, "s", function() end)