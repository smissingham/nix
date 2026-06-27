hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia-shell --daemonize")
end)

hl.bind(hyperMod .. " + M", hl.dsp.exec_cmd(browser .. " --app=https://mail.proton.me"))
hl.bind(hyperMod .. " + P", hl.dsp.exec_cmd(browser .. " --app=https://pass.proton.me"))
hl.bind(hyperMod .. " + A", hl.dsp.exec_cmd(browser .. " --app=https://chatgpt.com"))
hl.bind(hyperMod .. " + S", hl.dsp.exec_cmd(termPop .. " -e wiremix"))
hl.bind(hyperMod .. " + B", hl.dsp.exec_cmd(termPop .. " -e bluetui"))
hl.bind(hyperMod .. " + R", hl.dsp.exec_cmd(termPop .. " -e btop"))
hl.bind(hyperMod .. " + O", hl.dsp.exec_cmd(termPop .. " -e opencode"))
hl.bind(hyperMod .. " + C", hl.dsp.exec_cmd(termPop .. " -e podman-tui"))
hl.bind(hyperMod .. " + Y", hl.dsp.exec_cmd(termPop .. " -e yazi"))
hl.bind(hyperMod .. " + N", hl.dsp.exec_cmd(termPop .. " -e sesh connect Notes"))
hl.bind(hyperMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(hyperMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(hyperMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("code:192", hl.dsp.exec_cmd("handy --toggle-transcription"), { ignore_mods = true })
hl.bind("code:192", hl.dsp.exec_cmd("handy --toggle-transcription"), { release = true, ignore_mods = true })
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle"))
hl.bind(altMod .. " + Space", hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle"))
hl.bind(altMod .. " + Backspace", hl.dsp.exec_cmd("noctalia-shell ipc call settings toggle"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("wtype -M ctrl -k c"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("wtype -M ctrl -M shift -k v"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("noctalia-shell ipc call launcher clipboard"))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + slash", hl.dsp.window.float({ toggle = true }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ toggle = true }))
hl.bind(mod .. " + grave", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + SHIFT + M", hl.dsp.window.fullscreen({ mode = 0 }))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

local function resize_focused(delta)
  return function()
    local window = hl.get_active_window()
    if not window then
      return
    end

    local monitor = window.monitor or hl.get_active_monitor()
    if not monitor then
      return
    end

    local window_center_x = window.at.x + (window.size.x / 2)
    local monitor_center_x = monitor.x + (monitor.width / 2)

    if window_center_x < monitor_center_x then
      hl.dispatch(hl.dsp.cursor.move_to_corner({ corner = 1, window = window }))
      hl.dispatch(hl.dsp.window.resize({ x = delta, y = 0, relative = true, window = window }))
      return
    end

    hl.dispatch(hl.dsp.cursor.move_to_corner({ corner = 0, window = window }))
    hl.dispatch(hl.dsp.window.resize({ x = delta * -1, y = 0, relative = true, window = window }))
  end
end

hl.bind(mod .. " + SHIFT + equal", resize_focused(240))
hl.bind(mod .. " + SHIFT + minus", resize_focused(-240))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.layout("orientationcycle"))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

for i = 1, 10 do
  local key = tostring(i % 10)
  local workspace = tostring(i)
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
