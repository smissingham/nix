hl.config({
  animations = {
    enabled = true,
  },
})

hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 12, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "snappy" })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "snappy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 6, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "quick", style = "fade" })
