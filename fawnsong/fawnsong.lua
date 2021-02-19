-- fawnsong by @sademik
--
-- nourish, cherish, perceive
--
--
--
--
--
--
-- e1 - volume
-- e2 - cycle params
-- e3 - change value
--
--



 engine.name = 'FawnGlut'
-- reverb_room, seek, size, speed, spread, volume

local UI = require "ui"
local lfo = include("lib/hnds")
local pages

local lfo_targets = {
  "none",
  "1seek",
  "2seek",
  "1speed",
  "2speed",
  "1size",
  "2size"
}

local function setup_params()
  params:add_separator("samples")

  for i=1,2 do
    params:add_file(i .. "sample", i .. " sample")
    params:set_action(i .. "sample", function(file) engine.read(i, file) end)

    params:add_taper(i .. "volume", i .. " volume", -60, 20, 0, 0, "dB")
    params:set_action(i .. "volume", function(value) engine.volume(i, math.pow(10, value / 20)) end)
    params:hide(i .. "volume")

    params:add_taper(i .. "seek", "care", 0, 100, 0, 0)
    params:set_action(i .. "seek", function(value) engine.seek(i, value / 100) end)
    params:hide(i .. "seek")

    params:add_taper(i .. "speed", "cherish", -400, 400, 0, 0, "%")
    params:set_action(i .. "seek", function(value) engine.speed(i, value / 100) end)
    params:hide(i .. "speed")

    params:add_taper(i .. "size", "perceive", 1, 500, 100, 0, "ms")
    params:set_action(i .. "size", function(value) engine.size(i, value / 100) end)
    params:hide(i .. "size")
  end
end

local function setup_engine()
  engine.seek(1, 0)
  engine.gate(1, 1)

  engine.seek(2, 0)
  engine.gate(2, 1)
end

function lfo.process()
  for i=1,4 do
    local target = params:get(i .. "lfo_target")

    if params:get(i .. "lfo") == 2 then

      if target == 2 then
        params:set("1seek", lfo.scale(lfo[i].slope, -1, 1, 0, 100))
      elseif target == 3 then
        params:set("2seek", lfo.scale(lfo[i].slope, -1, 1, 0, 100))
      elseif target == 4 then
        params:set("1speed", lfo.scale(lfo[i].slope, -1, 1, 0, 500))
      elseif target == 5 then
        params:set("2speed", lfo.scale(lfo[i].slope, -1, 1, 0, 500))
      elseif target == 6 then
        params:set("1size", lfo.scale(lfo[i].slope, -1, 1, 0, 40))
      elseif target == 7 then
        params:set("2size", lfo.scale(lfo[i].slope, -1, 1, 0, 40))
      end
    end
  end
end

function init()
  pages = UI.Pages.new(1, 3)
  setup_params()
  setup_engine()
  re:start()
  for i = 1, 4 do
    lfo[i].lfo_targets = lfo_targets
  end
  lfo.init()
  screen.line_width(0)
  screen.font_face(2)
  screen.font_size(8)
  redraw()
end

function enc(n,d)
if n==1 then
  params:delta("1volume", d)
  params:delta("2volume", d)
end

if n==2 then
  pages:set_index_delta(util.clamp(d, -1, 1), false)
end

if pages.index == 1 then
if n==3 then
  params:delta("1seek", d)
  params:delta("2seek", d)
  end
end
if pages.index == 2 then
  if n==3 then
    params:delta("1speed", d)
    params:delta("2speed", d)
  end
end
if pages.index == 3 then
  if n==3 then
    params:delta("1size", d)
    params:delta("2size", d)
  end
end
end

local viewport = { width = 128, height = 64 }
local frames_per_second = 10
local frame = 0

local fawn_frames = 31
local fawn_frame = 1

function draw_fawn()
  screen.display_png(_path.this.path.."art/fawn_"..fawn_frame..".png", 0, 0)
  if fawn_frame == fawn_frames then
    fawn_frame = 1
  else
    fawn_frame = fawn_frame + 1
  end
end

function draw_ui()
  screen.level(15)
  screen.font_face(5)
  screen.move(50,viewport.height-5)

  if pages.index == 1 then
  screen.text("n o u r i s h  -  " .. math.floor(params:get("1seek")))
elseif pages.index == 2 then
  screen.text("c h e r i s h  -  " .. math.floor(params:get("1speed")))
elseif pages.index == 3 then
  screen.text("p e r c e i v e  - " .. math.floor(params:get("1size")))
end
end

function redraw()
  screen.clear()
  draw_fawn()
  draw_ui()
  pages:redraw()
  screen.update()
end

re = metro.init()

re.time = 1.0/frames_per_second

re.event = function()
  frame = frame + 1
  redraw()
end

function r()
  norns.script.load(norns.state.script)
end
