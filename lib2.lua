-- ============================================================
-- DUCK HUB - UI (tach rieng)
-- Ten hub : Duck Hub
-- Logo    : anh vit deo kinh nhung san (nut vuong bo goc + logo vuong bo goc trong UI)
-- Cach dung: chay file nay -> lay UI qua  getgenv().DuckUI
--            hoac dan phan "CHO DE UI" o cuoi file vao ngay duoi.
-- ============================================================
local DuckUILib = (function()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

------------------------------------------------------------------ THEME
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local THEMES = {
	Mono = { bg = rgb(10, 10, 10), panel = rgb(18, 18, 18), card = rgb(26, 26, 26), line = rgb(44, 44, 44), text = rgb(245, 245, 245), mut = rgb(140, 140, 140), on = rgb(214, 214, 214), off = rgb(56, 56, 56), knobOn = rgb(40, 40, 40), knobOff = rgb(200, 200, 200), btnText = rgb(16, 16, 16) },
	Graphite = { bg = rgb(16, 16, 16), panel = rgb(22, 22, 22), card = rgb(30, 30, 30), line = rgb(46, 46, 46), text = rgb(244, 244, 244), mut = rgb(140, 140, 140), on = rgb(255, 159, 67), off = rgb(58, 58, 58), knobOn = rgb(20, 20, 20), knobOff = rgb(200, 200, 200), btnText = rgb(20, 20, 20) },
	Midnight = { bg = rgb(13, 14, 20), panel = rgb(18, 20, 28), card = rgb(24, 27, 36), line = rgb(38, 42, 58), text = rgb(236, 238, 245), mut = rgb(134, 140, 160), on = rgb(124, 140, 255), off = rgb(48, 52, 70), knobOn = rgb(15, 16, 24), knobOff = rgb(190, 194, 210), btnText = rgb(10, 10, 18) },
	Crimson = { bg = rgb(14, 10, 11), panel = rgb(20, 15, 16), card = rgb(28, 20, 21), line = rgb(46, 32, 35), text = rgb(246, 234, 236), mut = rgb(154, 132, 136), on = rgb(255, 77, 94), off = rgb(60, 42, 45), knobOn = rgb(20, 10, 12), knobOff = rgb(210, 190, 194), btnText = rgb(20, 8, 10) },
	Ocean = { bg = rgb(9, 16, 18), panel = rgb(13, 23, 26), card = rgb(18, 33, 39), line = rgb(29, 48, 55), text = rgb(232, 244, 246), mut = rgb(125, 152, 160), on = rgb(39, 211, 230), off = rgb(36, 58, 66), knobOn = rgb(8, 18, 20), knobOff = rgb(190, 214, 220), btnText = rgb(6, 18, 20) },
}
local T = THEMES.Mono
local reg, hooks = {}, {}
local setButtonImage

local function bind(inst, prop, key)
	inst[prop] = T[key]
	reg[#reg + 1] = { inst, prop, key }
end
local function setTheme(name)
	if not THEMES[name] then return end
	T = THEMES[name]
	for _, e in ipairs(reg) do
		if e[1] and e[1].Parent then e[1][e[2]] = T[e[3]] end
	end
	for _, f in ipairs(hooks) do pcall(f) end
end

------------------------------------------------------------------ HELPERS
local function new(class, props, kids)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else o[k] = v end
	end
	for _, c in ipairs(kids or {}) do c.Parent = o end
	if parent then o.Parent = parent end
	return o
end
local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function stroke(key, th)
	local s = new("UIStroke", { Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	bind(s, "Color", key)
	return s
end
local function pad(l, t, r, b)
	return new("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b) })
end
local function label(parent, text, size, font, colorKey, pos, sz, xAlign)
	local l = new("TextLabel", {
		Parent = parent, BackgroundTransparency = 1, Text = text, TextSize = size, Font = font,
		Position = pos or UDim2.new(), Size = sz or UDim2.new(1, 0, 0, size + 2),
		TextXAlignment = xAlign or Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
	})
	bind(l, "TextColor3", colorKey)
	return l
end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end
local function makeDraggable(handle, target)
	local dragging, startPos, origin
	handle.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, startPos, origin = true, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - startPos
			target.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
end

------------------------------------------------------------------ ICON VE BANG HINH (khong phu thuoc font)
local function iconBar(parent, w, h, rot, key, px, py)
	local f = new("Frame", { Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, px, 0, py), Size = UDim2.new(0, w, 0, h), Rotation = rot or 0, BorderSizePixel = 0 }, { corner(math.max(1, math.floor(math.min(w, h) / 2))) })
	bind(f, "BackgroundColor3", key)
	return f
end
local function iconDot(parent, d, key, px, py)
	local f = new("Frame", { Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, px, 0, py), Size = UDim2.new(0, d, 0, d), BorderSizePixel = 0 }, { corner(d) })
	bind(f, "BackgroundColor3", key)
	return f
end
local function iconRing(parent, d, th, key, px, py)
	return new("Frame", { Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, px, 0, py), Size = UDim2.new(0, d, 0, d), BackgroundTransparency = 1, BorderSizePixel = 0 }, { corner(d), stroke(key, th) })
end
local function drawIcon(kind, parent, key, size)
	local c = new("Frame", { Parent = parent, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, size, 0, size) })
	local m, k = size / 2, size / 14
	if kind == "close" then
		iconBar(c, size * 0.85, 2, 45, key, m, m)
		iconBar(c, size * 0.85, 2, -45, key, m, m)
	elseif kind == "minus" then
		iconBar(c, size * 0.75, 2, 0, key, m, m)
	elseif kind == "square" then
		new("Frame", { Parent = c, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, m, 0, m), Size = UDim2.new(0, size * 0.64, 0, size * 0.64), BackgroundTransparency = 1, BorderSizePixel = 0 }, { corner(3), stroke(key, 2) })
	elseif kind == "check" then
		iconBar(c, 4.4 * k, 2, 45, key, 4 * k, 9.5 * k)
		iconBar(c, 9.8 * k, 2, -47, key, 8.7 * k, 7.5 * k)
	elseif kind == "chevron" then
		iconBar(c, 7 * k, 2, 45, key, 4.5 * k, 6.5 * k)
		iconBar(c, 7 * k, 2, -45, key, 9.5 * k, 6.5 * k)
	elseif kind == "star" then
		local a = iconBar(c, size * 0.55, size * 0.55, 0, key, m, m)
		a.UICorner.CornerRadius = UDim.new(0, 2)
		local b = iconBar(c, size * 0.55, size * 0.55, 45, key, m, m)
		b.UICorner.CornerRadius = UDim.new(0, 2)
	elseif kind == "user" then
		iconDot(c, size * 0.42, key, m, size * 0.3)
		local body = iconBar(c, size * 0.84, size * 0.4, 0, key, m, size * 0.78)
		body.UICorner.CornerRadius = UDim.new(0, math.floor(size * 0.2))
	elseif kind == "gear" then
		for _, r in ipairs({ 0, 45, 90, 135 }) do iconBar(c, 2.6, size * 0.95, r, key, m, m) end
		iconDot(c, size * 0.62, key, m, m)
		iconDot(c, size * 0.26, "card", m, m)
	elseif kind == "palette" then
		iconRing(c, size * 0.92, 2, key, m, m)
		iconDot(c, size * 0.16, key, size * 0.34, size * 0.4)
		iconDot(c, size * 0.16, key, size * 0.56, size * 0.3)
		iconDot(c, size * 0.16, key, size * 0.68, size * 0.52)
	elseif kind == "gauge" then
		iconRing(c, size * 0.92, 2, key, m, m)
		local L = size * 0.4
		local ang = math.rad(40)
		iconBar(c, 2, L, 40, key, m + math.sin(ang) * L / 2, m - math.cos(ang) * L / 2)
		iconDot(c, size * 0.14, key, m, m)
	end
	return c
end

------------------------------------------------------------------ GUI ROOT
local parentGui = (function()
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local ok = pcall(function() return CoreGui.Name end)
	if ok then return CoreGui end
	return lp:WaitForChild("PlayerGui")
end)()
for _, n in ipairs({ "DuckHubUI" }) do
	local old = parentGui:FindFirstChild(n)
	if old then old:Destroy() end
end

local gui = new("ScreenGui", { Name = "DuckHubUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 200, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
gui.Parent = parentGui

local holder = new("Frame", { Parent = gui, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0) })
local main = new("Frame", { Parent = holder, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(), Size = UDim2.new(0, 720, 0, 410), ClipsDescendants = false }, { corner(16), stroke("line", 1) })
bind(main, "BackgroundColor3", "bg")
local uiScale = new("UIScale", { Parent = main })

local userMul, baseScale = 1, 1
local function applyScale() uiScale.Scale = baseScale * userMul end
local function fitScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local v = cam.ViewportSize
	baseScale = math.clamp(math.min(v.X / 760, v.Y / 450), 0.45, 1)
	applyScale()
end
fitScale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale) end

------------------------------------------------------------------ TOP BAR
local topbar = new("Frame", { Parent = main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 46) })
makeDraggable(topbar, holder)

local logo = new("Frame", { Parent = topbar, Position = UDim2.new(0, 14, 0, 9), Size = UDim2.new(0, 28, 0, 28) }, { corner(9) })
bind(logo, "BackgroundColor3", "on")
local logoImg = new("ImageLabel", { Parent = logo, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScaleType = Enum.ScaleType.Crop, Visible = false, ZIndex = 3 }, { corner(9) })
local logoTxt = label(logo, "D", 15, Enum.Font.GothamBold, "btnText", UDim2.new(), UDim2.new(1, 0, 1, 0), Enum.TextXAlignment.Center)
label(topbar, "Duck Hub", 14, Enum.Font.GothamBold, "text", UDim2.new(0, 50, 0, 7), UDim2.new(0, 90, 0, 16))
label(topbar, "Blox Fruits", 10, Enum.Font.Gotham, "mut", UDim2.new(0, 50, 0, 24), UDim2.new(0, 90, 0, 12))

local tabStrip = new("ScrollingFrame", {
	Parent = topbar, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 150, 0, 0), Size = UDim2.new(1, -150 - 112, 1, 0),
	ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X,
})
new("UIListLayout", { Parent = tabStrip, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

local function ctrlBtn(kind, x)
	local b = new("TextButton", {
		Parent = topbar, AutoButtonColor = false, Text = "", Font = Enum.Font.GothamBold, TextSize = 13,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 10), Size = UDim2.new(0, 26, 0, 26),
	}, { corner(8) })
	bind(b, "BackgroundColor3", "card")
	bind(b, "TextColor3", "mut")
	drawIcon(kind, b, "mut", 12)
	return b
end
local btnClose = ctrlBtn("close", -10)
local btnMax = ctrlBtn("square", -40)
local btnMin = ctrlBtn("minus", -70)

local sep = new("Frame", { Parent = main, Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0 })
bind(sep, "BackgroundColor3", "line")

local body = new("Frame", { Parent = main, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 47), Size = UDim2.new(1, 0, 1, -47) })
local pagesHolder = new("Frame", { Parent = body, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -14 - 250, 1, -20) })

------------------------------------------------------------------ FLAGS / TABS
local Flags = getgenv().DuckFlags or {}
getgenv().DuckFlags = Flags

local tabs, activeTab, userPicked = {}, nil, false
local PREF = { "Farm", "Khu Vực", "Sea Event", "Raid & Fruit", "Race & Items", "Fishing & Quest", "Event", "Halloween", "Player", "Shop", "Setting" }
local function orderOf(name)
	for i, n in ipairs(PREF) do if n == name then return i end end
	return 100 + #tabs
end
local function selectTab(t)
	for _, x in ipairs(tabs) do
		local on = (x == t)
		x.page.Visible = on
		x.under.Visible = on
		x.btn.TextColor3 = on and T.text or T.mut
		x.active = on
	end
	activeTab = t
end
hooks[#hooks + 1] = function() if activeTab then selectTab(activeTab) end end

local function seaNumber()
	local id = game.PlaceId
	if id == 2753915549 or id == 85211729168715 then return 1 end
	if id == 4442272183 or id == 79091703265657 then return 2 end
	if id == 7449423635 or id == 100117331123089 then return 3 end
	return 0
end

local function makeTab(name, title)
	local tab = { name = name, active = false }
	local w = TextService:GetTextSize(name, 13, Enum.Font.GothamMedium, Vector2.new(1000, 30)).X + 22
	local btn = new("TextButton", {
		Parent = tabStrip, AutoButtonColor = false, BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamMedium, TextSize = 13,
		Size = UDim2.new(0, w, 0, 32), LayoutOrder = orderOf(name),
	})
	bind(btn, "TextColor3", "mut")
	local under = new("Frame", { Parent = btn, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -16, 0, 2), BorderSizePixel = 0, Visible = false }, { corner(2) })
	bind(under, "BackgroundColor3", "on")
	tab.btn, tab.under = btn, under

	local page = new("Frame", { Parent = pagesHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false })
	tab.page = page
	label(page, title or name, 20, Enum.Font.GothamBold, "text", UDim2.new(0, 2, 0, 0), UDim2.new(0.5, 0, 0, 30))
	local chip = new("Frame", { Parent = page, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 3), Size = UDim2.new(0, 150, 0, 24) }, { corner(12), stroke("line", 1) })
	bind(chip, "BackgroundColor3", "card")
	local dot = new("Frame", { Parent = chip, Position = UDim2.new(0, 10, 0.5, -3), Size = UDim2.new(0, 6, 0, 6) }, { corner(3) })
	bind(dot, "BackgroundColor3", "on")
	local chipTxt = label(chip, "", 11, Enum.Font.Gotham, "mut", UDim2.new(0, 22, 0, 0), UDim2.new(1, -28, 1, 0))
	tab.chipTxt = chipTxt

	local scroll = new("ScrollingFrame", {
		Parent = page, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38),
		ScrollBarThickness = 3, ScrollBarImageColor3 = T.line, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	new("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	new("UIPadding", { Parent = scroll, PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
	local order, current = 0, nil
	local function nextOrder()
		if current then current.n = current.n + 1 return current.rank * 1000 + current.n end
		order = order + 1
		return order
	end
	function tab:UseSection(st) current = st end

	btn.MouseButton1Click:Connect(function() userPicked = true selectTab(tab) end)
	tabs[#tabs + 1] = tab
	if not userPicked then
		local best = tabs[1]
		for _, x in ipairs(tabs) do if x.btn.LayoutOrder < best.btn.LayoutOrder then best = x end end
		selectTab(best)
	end

	local function card(h)
		local f = new("Frame", { Parent = scroll, Size = UDim2.new(1, 0, 0, h), LayoutOrder = nextOrder() }, { corner(10), stroke("line", 1) })
		bind(f, "BackgroundColor3", "card")
		return f
	end

	function tab:AddSection(text)
		local l = label(scroll, string.upper(text), 11, Enum.Font.GothamBold, "mut", nil, UDim2.new(1, 0, 0, 16))
		l.LayoutOrder = nextOrder()
		return l
	end

	function tab:AddLabel(text)
		local f = card(34)
		local l = label(f, text, 12, Enum.Font.Gotham, "mut", UDim2.new(0, 14, 0, 0), UDim2.new(1, -28, 1, 0))
		return { Set = function(_, t) l.Text = tostring(t) end, SetColor = function(_, c) if typeof(c) == "Color3" then l.TextColor3 = c end end, Get = function() return l.Text end }
	end

	function tab:AddToggle(o)
		local f = card(o.Desc and 46 or 38)
		label(f, o.Name, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 14, 0, o.Desc and 7 or 0), UDim2.new(1, -80, 0, o.Desc and 16 or 38))
		if o.Desc then label(f, o.Desc, 11, Enum.Font.Gotham, "mut", UDim2.new(0, 14, 0, 24), UDim2.new(1, -80, 0, 14)) end
		local pill = new("TextButton", { Parent = f, AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 40, 0, 22) }, { corner(11) })
		local knob = new("Frame", { Parent = pill, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.new(0, 16, 0, 16) }, { corner(8) })
		local state = o.Default == true
		local function visual(anim)
			local ti = TweenInfo.new(anim and 0.15 or 0)
			TS:Create(pill, ti, { BackgroundColor3 = state and T.on or T.off }):Play()
			TS:Create(knob, ti, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and T.knobOn or T.knobOff }):Play()
		end
		visual(false)
		hooks[#hooks + 1] = function() visual(false) end
		local obj = {}
		local function set(v, silent)
			state = v and true or false
			if o.Flag then Flags[o.Flag] = state end
			visual(true)
			if not silent and o.Callback then task.spawn(o.Callback, state) end
		end
		pill.MouseButton1Click:Connect(function() set(not state) end)
		if o.Flag then Flags[o.Flag] = state end
		if state and o.Callback then task.defer(o.Callback, state) end
		function obj:Set(v, silent) set(v, silent) end
		function obj:Get() return state end
		return obj
	end

	function tab:AddSlider(o)
		local f = card(54)
		label(f, o.Name, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 14, 0, 8), UDim2.new(0.6, 0, 0, 16))
		local val = label(f, "", 12, Enum.Font.Gotham, "mut", UDim2.new(1, -14, 0, 8), UDim2.new(0.4, 0, 0, 16), Enum.TextXAlignment.Right)
		val.AnchorPoint = Vector2.new(1, 0)
		local track = new("TextButton", { Parent = f, AutoButtonColor = false, Text = "", Position = UDim2.new(0, 14, 0, 36), Size = UDim2.new(1, -28, 0, 6) }, { corner(3) })
		bind(track, "BackgroundColor3", "off")
		local fill = new("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, { corner(3) })
		bind(fill, "BackgroundColor3", "on")
		local knob = new("Frame", { Parent = track, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0.5, 0) }, { corner(6) })
		bind(knob, "BackgroundColor3", "text")
		local min, max, suffix = o.Min or 0, o.Max or 100, o.Suffix or ""
		local step = o.Step or 1
		local value = math.clamp(o.Default or min, min, max)
		local function render()
			local r = (value - min) / math.max(max - min, 1e-6)
			fill.Size = UDim2.new(r, 0, 1, 0)
			knob.Position = UDim2.new(r, 0, 0.5, 0)
			val.Text = tostring(value) .. (suffix ~= "" and (" " .. suffix) or "")
		end
		local function set(v, silent)
			v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
			v = tonumber(string.format("%.3f", v))
			if v == value and not silent then return end
			value = v
			if o.Flag then Flags[o.Flag] = value end
			render()
			if not silent and o.Callback then task.spawn(o.Callback, value) end
		end
		local dragging = false
		local function fromX(x)
			local r = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			set(min + (max - min) * r)
		end
		track.InputBegan:Connect(function(i) if isPress(i) then dragging = true fromX(i.Position.X) end end)
		UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then fromX(i.Position.X) end end)
		UIS.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)
		render()
		if o.Flag then Flags[o.Flag] = value end
		if o.Callback then task.defer(o.Callback, value) end
		return { Set = function(_, v) set(v) end, Get = function() return value end }
	end

	function tab:AddButtons(list)
		local row = new("Frame", { Parent = scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = nextOrder() })
		new("UIListLayout", { Parent = row, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
		local n = #list
		for i, b in ipairs(list) do
			local btn = new("TextButton", {
				Parent = row, AutoButtonColor = false, Text = b.Name, Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = i,
				Size = UDim2.new(b.Wide or (1 / n), -(8 * (n - 1) / n), 1, 0),
			}, { corner(10) })
			local function paint()
				if b.Primary then
					btn.BackgroundColor3, btn.TextColor3 = T.on, T.btnText
				else
					btn.BackgroundColor3, btn.TextColor3 = T.card, T.text
				end
			end
			paint()
			hooks[#hooks + 1] = paint
			if not b.Primary then stroke("line", 1).Parent = btn end
			btn.MouseButton1Click:Connect(function()
				TS:Create(btn, TweenInfo.new(0.08), { BackgroundTransparency = 0.25 }):Play()
				task.delay(0.1, function() TS:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play() end)
				if b.Callback then task.spawn(b.Callback) end
			end)
		end
	end

	function tab:AddButton(o) return tab:AddButtons({ o }) end

	function tab:AddDropdown(o)
		local opts = o.Options or {}
		local current = o.Default
		local f = card(40)
		f.ClipsDescendants = true
		label(f, o.Name, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 14, 0, 0), UDim2.new(0.5, 0, 0, 40))
		local head = new("TextButton", { Parent = f, AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 40) })
		local cur = label(head, "", 12, Enum.Font.GothamMedium, "on", UDim2.new(1, -14, 0, 0), UDim2.new(0.5, 0, 1, 0), Enum.TextXAlignment.Right)
		cur.AnchorPoint = Vector2.new(1, 0)
		cur.TextTruncate = Enum.TextTruncate.AtEnd
		local chev = drawIcon("chevron", head, "on", 14)
		chev.AnchorPoint = Vector2.new(1, 0.5)
		chev.Position = UDim2.new(1, -12, 0.5, 0)
		cur.Position = UDim2.new(1, -32, 0, 0)
		local list = new("Frame", { Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 42), Size = UDim2.new(1, -16, 0, 0) })
		new("UIListLayout", { Parent = list, Padding = UDim.new(0, 2) })
		local open = false
		local function refresh() cur.Text = (current ~= nil and tostring(current) or "Chọn...")
			TS:Create(chev, TweenInfo.new(0.15), { Rotation = open and 180 or 0 }):Play() end
		local function pick(op, silent)
			current = op
			if o.Flag then Flags[o.Flag] = current end
			open = false
			TS:Create(f, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 40) }):Play()
			refresh()
			if not silent and o.Callback then task.spawn(o.Callback, current) end
		end
		local function rebuild()
			for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			for _, op in ipairs(opts) do
				local b = new("TextButton", { Parent = list, AutoButtonColor = false, BackgroundTransparency = 1, Text = tostring(op), Font = Enum.Font.Gotham, TextSize = 12, Size = UDim2.new(1, 0, 0, 26) }, { corner(6) })
				bind(b, "TextColor3", "text")
				b.MouseButton1Click:Connect(function() pick(op) end)
			end
			list.Size = UDim2.new(1, -16, 0, #opts * 28)
			if open then f.Size = UDim2.new(1, 0, 0, 46 + #opts * 28) end
		end
		head.MouseButton1Click:Connect(function()
			open = not open
			TS:Create(f, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, open and (46 + #opts * 28) or 40) }):Play()
			refresh()
		end)
		rebuild()
		refresh()
		if o.Flag then Flags[o.Flag] = current end
		if current ~= nil and o.Callback then task.defer(o.Callback, current) end
		return {
			Get = function() return current end,
			Set = function(_, v) pick(v) end,
			SetOptions = function(_, l) opts = l or {} current = nil rebuild() refresh() end,
		}
	end

	function tab:AddMultiDropdown(o)
		local prio = o.Priority == true
		local opts, sel, ord, rows = {}, {}, {}, {}
		local f = card(40)
		f.ClipsDescendants = true
		label(f, o.Name, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 14, 0, 0), UDim2.new(0.4, 0, 0, 40))
		local head = new("TextButton", { Parent = f, AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 40) })
		local cur = label(head, "", 12, Enum.Font.GothamMedium, "on", UDim2.new(1, -14, 0, 0), UDim2.new(0.55, 0, 1, 0), Enum.TextXAlignment.Right)
		cur.AnchorPoint = Vector2.new(1, 0)
		cur.TextTruncate = Enum.TextTruncate.AtEnd
		local chev = drawIcon("chevron", head, "on", 14)
		chev.AnchorPoint = Vector2.new(1, 0.5)
		chev.Position = UDim2.new(1, -12, 0.5, 0)
		cur.Position = UDim2.new(1, -32, 0, 0)
		local list = new("Frame", { Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 42), Size = UDim2.new(1, -16, 0, 0) })
		new("UIListLayout", { Parent = list, Padding = UDim.new(0, 2) })
		local open = false
		local function summary()
			if prio then return #ord > 0 and table.concat(ord, " > ") or "Chọn..." end
			local n = 0
			for _, v in pairs(sel) do if v then n = n + 1 end end
			return n > 0 and (n .. " đã chọn") or "Chọn..."
		end
		local function refresh()
			cur.Text = summary()
			TS:Create(chev, TweenInfo.new(0.15), { Rotation = open and 180 or 0 }):Play()
			for n, r in pairs(rows) do r.Visible = sel[n] and true or false end
		end
		local function toggle(name, on, silent)
			on = on and true or false
			sel[name] = on
			if prio then
				for i = #ord, 1, -1 do if ord[i] == name then table.remove(ord, i) end end
				if on then ord[#ord + 1] = name end
			end
			refresh()
			if not silent and o.Callback then
				if prio then task.spawn(o.Callback, table.clone(ord)) else task.spawn(o.Callback, name, on) end
			end
		end
		local function build(names)
			for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			opts, sel, ord, rows = names, {}, {}, {}
			for _, n in ipairs(names) do
				local b = new("TextButton", { Parent = list, AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 26) }, { corner(6) })
				label(b, n, 12, Enum.Font.Gotham, "text", UDim2.new(0, 8, 0, 0), UDim2.new(1, -34, 1, 0))
				local ck = drawIcon("check", b, "on", 14)
				ck.AnchorPoint = Vector2.new(1, 0.5)
				ck.Position = UDim2.new(1, -10, 0.5, 0)
				ck.Visible = false
				rows[n] = ck
				b.MouseButton1Click:Connect(function() toggle(n, not sel[n]) end)
			end
			list.Size = UDim2.new(1, -16, 0, #names * 28)
			if open then f.Size = UDim2.new(1, 0, 0, 46 + #names * 28) end
			refresh()
		end
		head.MouseButton1Click:Connect(function()
			open = not open
			TS:Create(f, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, open and (46 + #opts * 28) or 40) }):Play()
			refresh()
		end)
		build(o.Options or {})
		for _, n in ipairs(o.Init or {}) do if rows[n] then toggle(n, true) end end
		return {
			SetValue = function(_, v)
				if type(v) == "table" then
					if #v > 0 then for _, n in ipairs(v) do if rows[tostring(n)] then toggle(tostring(n), true) end end
					else for n, on in pairs(v) do if on == true and rows[tostring(n)] then toggle(tostring(n), true) end end end
				elseif v ~= nil and rows[tostring(v)] then toggle(tostring(v), true) end
			end,
			Refresh = function(_, names, init)
				build(names)
				for _, n in ipairs(init or {}) do if rows[n] then toggle(n, true) end end
			end,
		}
	end

	function tab:AddBox(o)
		local f = card(40)
		label(f, o.Name, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 14, 0, 0), UDim2.new(0.4, 0, 1, 0))
		local tb = new("TextBox", {
			Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.5, 0, 0, 26),
			Text = o.Default ~= nil and tostring(o.Default) or "", PlaceholderText = o.Placeholder or "", ClearTextOnFocus = false,
			Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		}, { corner(8), stroke("line", 1), pad(8, 0, 8, 0) })
		bind(tb, "BackgroundColor3", "bg")
		bind(tb, "TextColor3", "text")
		bind(tb, "PlaceholderColor3", "mut")
		local function fireCb() if o.Callback then task.spawn(o.Callback, tb.Text) end end
		tb.FocusLost:Connect(function()
			if o.Numeric then tb.Text = tb.Text:gsub("[^%d%.%-]", "") end
			fireCb()
		end)
		if tb.Text ~= "" and o.Callback then task.defer(o.Callback, tb.Text) end
		return { Set = function(_, v) tb.Text = tostring(v) fireCb() end, Get = function() return tb.Text end }
	end

	return tab
end

------------------------------------------------------------------ RIGHT PANEL (thong tin tai khoan)
local side = new("Frame", { Parent = body, Position = UDim2.new(1, -240, 0, 10), Size = UDim2.new(0, 226, 1, -20) }, { corner(14), stroke("line", 1) })
bind(side, "BackgroundColor3", "panel")

label(side, "Người dùng:", 10, Enum.Font.Gotham, "mut", UDim2.new(0, 14, 0, 10), UDim2.new(1, -28, 0, 12))
local nameLbl = label(side, lp.DisplayName, 14, Enum.Font.GothamBold, "text", UDim2.new(0, 14, 0, 23), UDim2.new(1, -50, 0, 18))
local star = drawIcon("star", side, "on", 14)
local function placeStar()
	local w = TextService:GetTextSize(nameLbl.Text, 14, Enum.Font.GothamBold, Vector2.new(400, 20)).X
	star.Position = UDim2.new(0, 14 + w + 14, 0, 32)
end
placeStar()
label(side, "Script: ", 10, Enum.Font.Gotham, "mut", UDim2.new(0, 14, 0, 43), UDim2.new(0, 36, 0, 12))
label(side, "Duck Hub", 10, Enum.Font.GothamBold, "text", UDim2.new(0, 48, 0, 43), UDim2.new(1, -60, 0, 12))

-- avatar
local avatarBox = new("Frame", { Parent = side, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 60), Size = UDim2.new(1, -20, 0, 188), ClipsDescendants = true })
local glow1 = new("Frame", { Parent = avatarBox, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4), Size = UDim2.new(0, 150, 0, 22), BackgroundTransparency = 0.8 }, { corner(11) })
bind(glow1, "BackgroundColor3", "on")
local glow2 = new("Frame", { Parent = avatarBox, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.new(0, 96, 0, 12), BackgroundTransparency = 0.6 }, { corner(6) })
bind(glow2, "BackgroundColor3", "on")
local avHolder = new("Frame", { Parent = avatarBox, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, 0, 1, 0) })
local thumb = new("ImageLabel", { Parent = avHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScaleType = Enum.ScaleType.Fit })
task.spawn(function()
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
	end)
	if ok then thumb.Image = img end
end)
local vp = new("ViewportFrame", { Parent = avHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Ambient = rgb(185, 185, 185), LightColor = rgb(255, 255, 255), LightDirection = Vector3.new(-0.6, -0.8, -0.7), Visible = false })

local avatarModel, avatarAngle = nil, 160
local avShown, miniAv = true, nil
local function buildAvatar()
	local ok = pcall(function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		char:WaitForChild("HumanoidRootPart", 5)
		char.Archivable = true
		local clone = char:Clone()
		if not clone then error("no clone") end
		if avatarModel then avatarModel:Destroy() end
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Tool") or d:IsA("BillboardGui") or d:IsA("Sound") or d:IsA("ForceField") then
				d:Destroy()
			elseif d:IsA("BasePart") then
				d.Anchored = true
			end
		end
		local hum = clone:FindFirstChildOfClass("Humanoid")
		if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
		clone:PivotTo(CFrame.new(0, 0, 0))
		clone.Parent = vp
		avatarModel = clone
		local cam = vp.CurrentCamera
		if not cam then
			cam = new("Camera", { Parent = vp })
			vp.CurrentCamera = cam
		end
		local cf, size = clone:GetBoundingBox()
		local h = math.max(size.Y, 5)
		cam.FieldOfView = 38
		cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, h * 0.05, h * 1.9), cf.Position + Vector3.new(0, h * 0.02, 0))
		vp.Visible = true
		thumb.Visible = false
	end)
	if not ok then vp.Visible = false thumb.Visible = true end
end
task.spawn(buildAvatar)
lp.CharacterAdded:Connect(function() task.wait(1.5) buildAvatar() end)
RS.RenderStepped:Connect(function(dt)
	if avatarModel and avatarModel.Parent and gui.Parent and avShown and holder.Visible then
		avatarAngle = (avatarAngle + dt * 40) % 360
		pcall(function() avatarModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(avatarAngle), 0)) end)
	end
end)

-- nut tat/mo nhan vat
local avToggle = new("TextButton", { Parent = avatarBox, AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -2, 0, 2), Size = UDim2.new(0, 26, 0, 26), ZIndex = 6 }, { corner(8) })
bind(avToggle, "BackgroundColor3", "card")
local avIcon = drawIcon("user", avToggle, "mut", 13)
local avSlash = new("Frame", { Parent = avToggle, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 2), Rotation = -45, BorderSizePixel = 0, Visible = false, ZIndex = 7 })
bind(avSlash, "BackgroundColor3", "on")
local avOffLbl = label(avatarBox, "Nhân vật đang tắt", 10, Enum.Font.Gotham, "mut", UDim2.new(0, 0, 0.5, -6), UDim2.new(1, 0, 0, 12), Enum.TextXAlignment.Center)
avOffLbl.Visible = false
local function tw(o, t, props) pcall(function() TS:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end) end
local function refreshAvatar()
	local open = holder.Visible
	avSlash.Visible = not avShown
	avOffLbl.Visible = (not avShown) and open
	glow1.Visible = avShown and open
	glow2.Visible = avShown and open
	if not avShown then
		avHolder.Visible = false
		if miniAv then miniAv.Visible = false end
		return
	end
	-- nhan vat chi hien trong UI; dong UI thi an han (khong render ben ngoai -> bot lag)
	if open then
		avHolder.Visible = true
		avHolder.Size = UDim2.new(0.4, 0, 0.4, 0)
		tw(avHolder, 0.3, { Size = UDim2.new(1, 0, 1, 0) })
	else
		avHolder.Visible = false
		if miniAv then miniAv.Visible = false end
	end
end
avToggle.MouseButton1Click:Connect(function() avShown = not avShown refreshAvatar() end)

-- FPS
local fpsRow = new("Frame", { Parent = side, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 252), Size = UDim2.new(1, -28, 0, 30) })
local gaugeIc = drawIcon("gauge", fpsRow, "mut", 22)
gaugeIc.Position = UDim2.new(0, 11, 0.5, 0)
label(fpsRow, "FPS:", 9, Enum.Font.Gotham, "mut", UDim2.new(0, 30, 0, 2), UDim2.new(0, 50, 0, 11))
local fpsLbl = label(fpsRow, "-- FPS", 15, Enum.Font.GothamBold, "text", UDim2.new(0, 30, 0, 12), UDim2.new(0, 100, 0, 18))
local fpsDot = new("Frame", { Parent = fpsRow, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 7, 0, 7), BackgroundColor3 = rgb(70, 220, 110) }, { corner(4) })
do
	local frames, last = 0, os.clock()
	RS.RenderStepped:Connect(function()
		frames = frames + 1
		local now = os.clock()
		if now - last >= 0.5 then
			local fps = math.floor(frames / (now - last) + 0.5)
			frames, last = 0, now
			fpsLbl.Text = fps .. " FPS"
			fpsDot.BackgroundColor3 = fps >= 45 and rgb(70, 220, 110) or (fps >= 25 and rgb(240, 190, 60) or rgb(240, 80, 80))
		end
	end)
end

------------------------------------------------------------------ POPUPS
local overlay = new("TextButton", { Parent = main, AutoButtonColor = false, Text = "", BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 40 }, { corner(16) })
local popup = new("Frame", { Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 380, 0, 300), ZIndex = 41, Active = true }, { corner(14), stroke("line", 1) })
bind(popup, "BackgroundColor3", "panel")
local popTitle = label(popup, "", 16, Enum.Font.GothamBold, "text", UDim2.new(0, 16, 0, 12), UDim2.new(1, -60, 0, 22))
popTitle.ZIndex = 42
local popClose = new("TextButton", { Parent = popup, AutoButtonColor = false, Text = "", Font = Enum.Font.GothamBold, TextSize = 13, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.new(0, 26, 0, 26), ZIndex = 42 }, { corner(8) })
bind(popClose, "BackgroundColor3", "card")
bind(popClose, "TextColor3", "mut")
drawIcon("close", popClose, "mut", 12)
local popBody = new("ScrollingFrame", { Parent = popup, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 14, 0, 46), Size = UDim2.new(1, -28, 1, -58), ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 42 })
new("UIListLayout", { Parent = popBody, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
local popTick
local function closePopup() overlay.Visible = false popTick = nil end
popClose.MouseButton1Click:Connect(closePopup)
overlay.MouseButton1Click:Connect(closePopup)

local function clearPop()
	for _, c in ipairs(popBody:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end
end
local function popRow(k, order)
	local r = new("Frame", { Parent = popBody, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, ZIndex = 43 }, { corner(8) })
	bind(r, "BackgroundColor3", "card")
	local a = label(r, k, 12, Enum.Font.Gotham, "mut", UDim2.new(0, 12, 0, 0), UDim2.new(0.45, 0, 1, 0))
	local b = label(r, "", 12, Enum.Font.GothamMedium, "text", UDim2.new(1, -12, 0, 0), UDim2.new(0.55, 0, 1, 0), Enum.TextXAlignment.Right)
	b.AnchorPoint = Vector2.new(1, 0)
	a.ZIndex, b.ZIndex = 44, 44
	return b
end

-- doc du lieu tai khoan
local function dataVal(name)
	local d = lp:FindFirstChild("Data")
	local o = d and d:FindFirstChild(name)
	return o and o.Value
end
local function fmt(n)
	if type(n) ~= "number" then return tostring(n or "?") end
	local s = tostring(math.floor(n))
	return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end
local function getInfo()
	local bounty
	pcall(function()
		local ls = lp:FindFirstChild("leaderstats")
		local b = ls and (ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty"))
		bounty = b and b.Value
	end)
	local ping
	pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
	local sea = seaNumber()
	return {
		{ "Tên hiển thị", lp.DisplayName },
		{ "Username", "@" .. lp.Name },
		{ "User ID", tostring(lp.UserId) },
		{ "Tuổi tài khoản", lp.AccountAge .. " ngày" },
		{ "Sea", sea > 0 and ("Sea " .. sea) or "Không rõ" },
		{ "Level", fmt(dataVal("Level")) },
		{ "Beli", fmt(dataVal("Beli")) },
		{ "Fragments", fmt(dataVal("Fragments")) },
		{ "Bounty / Honor", fmt(bounty) },
		{ "Race", tostring(dataVal("Race") or "?") },
		{ "Trái ác quỷ", tostring(dataVal("DevilFruit") or "Không có") },
		{ "Ping", ping and (ping .. " ms") or "?" },
		{ "Người chơi trong server", #Players:GetPlayers() .. "/" .. Players.MaxPlayers },
		{ "Job ID", string.sub(game.JobId, 1, 13) .. (#game.JobId > 13 and "…" or "") },
	}
end

local function openInfo()
	clearPop()
	popTitle.Text = "Thông tin tài khoản"
	local cells = {}
	for i, row in ipairs(getInfo()) do cells[i] = popRow(row[1], i) end
	local function refresh()
		for i, row in ipairs(getInfo()) do if cells[i] then cells[i].Text = tostring(row[2]) end end
	end
	refresh()
	overlay.Visible = true
	local my = {}
	popTick = my
	task.spawn(function()
		while popTick == my and overlay.Visible do
			task.wait(1)
			pcall(refresh)
		end
	end)
end

local fpsToggleObj
local function openSettings()
	clearPop()
	popTitle.Text = "Cài đặt"
	-- cai dat don gian dung lai controls
	local function pRow(h)
		local r = new("Frame", { Parent = popBody, Size = UDim2.new(1, 0, 0, h), ZIndex = 43 }, { corner(8) })
		bind(r, "BackgroundColor3", "card")
		return r
	end
	-- hien FPS
	local r1 = pRow(38)
	label(r1, "Hiện FPS", 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 12, 0, 0), UDim2.new(0.6, 0, 1, 0)).ZIndex = 44
	local pill = new("TextButton", { Parent = r1, AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 40, 0, 22), ZIndex = 44 }, { corner(11) })
	local knob = new("Frame", { Parent = pill, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 16, 0, 16), ZIndex = 45 }, { corner(8) })
	local function vis()
		local on = fpsRow.Visible
		pill.BackgroundColor3 = on and T.on or T.off
		knob.Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		knob.BackgroundColor3 = on and T.knobOn or T.knobOff
	end
	vis()
	pill.MouseButton1Click:Connect(function() fpsRow.Visible = not fpsRow.Visible vis() end)
	-- kich thuoc UI
	local r2 = pRow(54)
	label(r2, "Kích thước UI", 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 12, 0, 8), UDim2.new(0.6, 0, 0, 16)).ZIndex = 44
	local v = label(r2, math.floor(userMul * 100) .. "%", 12, Enum.Font.Gotham, "mut", UDim2.new(1, -12, 0, 8), UDim2.new(0.4, 0, 0, 16), Enum.TextXAlignment.Right)
	v.AnchorPoint, v.ZIndex = Vector2.new(1, 0), 44
	local track = new("TextButton", { Parent = r2, AutoButtonColor = false, Text = "", Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 6), ZIndex = 44 }, { corner(3) })
	track.BackgroundColor3 = T.off
	local fill = new("Frame", { Parent = track, BackgroundColor3 = T.on, BorderSizePixel = 0, ZIndex = 45 }, { corner(3) })
	local function paint() fill.Size = UDim2.new((userMul - 0.7) / 0.6, 0, 1, 0) v.Text = math.floor(userMul * 100 + 0.5) .. "%" end
	paint()
	local dragging = false
	local function fromX(x)
		local r = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		userMul = math.floor((0.7 + 0.6 * r) * 20 + 0.5) / 20
		applyScale() paint()
	end
	track.InputBegan:Connect(function(i) if isPress(i) then dragging = true fromX(i.Position.X) end end)
	UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then fromX(i.Position.X) end end)
	UIS.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)
	-- phim tat
	local r3 = pRow(34)
	label(r3, "Ẩn/hiện menu: phím LeftControl hoặc nút tròn khi thu nhỏ", 11, Enum.Font.Gotham, "mut", UDim2.new(0, 12, 0, 0), UDim2.new(1, -24, 1, 0)).ZIndex = 44
	local r4 = pRow(40)
	label(r4, "Ảnh nút tròn (ID/đường dẫn)", 12, Enum.Font.GothamMedium, "text", UDim2.new(0, 12, 0, 0), UDim2.new(0.5, 0, 1, 0)).ZIndex = 44
	local tb = new("TextBox", { Parent = r4, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.46, 0, 0, 26), Text = tostring(getgenv().DuckButtonImage or ""), PlaceholderText = "rbxassetid://...", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 44, TextXAlignment = Enum.TextXAlignment.Left }, { corner(8), pad(8, 0, 8, 0) })
	tb.BackgroundColor3, tb.TextColor3, tb.PlaceholderColor3 = T.bg, T.text, T.mut
	tb.FocusLost:Connect(function() getgenv().DuckButtonImage = tb.Text setButtonImage(tb.Text) end)
	overlay.Visible = true
end

local function openThemes()
	clearPop()
	popTitle.Text = "Giao diện"
	local names = { "Mono", "Graphite", "Midnight", "Crimson", "Ocean" }
	for i, n in ipairs(names) do
		local th = THEMES[n]
		local r = new("TextButton", { Parent = popBody, AutoButtonColor = false, Text = "", Size = UDim2.new(1, 0, 0, 40), LayoutOrder = i, ZIndex = 43 }, { corner(8) })
		bind(r, "BackgroundColor3", "card")
		local sw = new("Frame", { Parent = r, Position = UDim2.new(0, 10, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), BackgroundColor3 = th.on, ZIndex = 44 }, { corner(6) })
		local sw2 = new("Frame", { Parent = r, Position = UDim2.new(0, 34, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), BackgroundColor3 = th.bg, ZIndex = 44 }, { corner(6), new("UIStroke", { Color = th.line, Thickness = 1 }) })
		label(r, n, 13, Enum.Font.GothamMedium, "text", UDim2.new(0, 66, 0, 0), UDim2.new(1, -80, 1, 0)).ZIndex = 44
		r.MouseButton1Click:Connect(function() setTheme(n) pcall(function() getgenv().DuckTheme = n end) end)
	end
	overlay.Visible = true
end

-- 3 nut o cuoi panel
local function sideBtn(icon, text, idx, fn)
	local w = (226 - 28 - 12) / 3
	local b = new("TextButton", { Parent = side, AutoButtonColor = false, Text = "", Position = UDim2.new(0, 14 + (idx - 1) * (w + 6), 1, -66), Size = UDim2.new(0, w, 0, 54) }, { corner(10), stroke("line", 1) })
	bind(b, "BackgroundColor3", "card")
	local ic = drawIcon(icon, b, "text", 18)
	ic.Position = UDim2.new(0.5, 0, 0, 17)
	label(b, text, 10, Enum.Font.GothamMedium, "mut", UDim2.new(0, 0, 0, 31), UDim2.new(1, 0, 0, 14), Enum.TextXAlignment.Center)
	b.MouseButton1Click:Connect(fn)
	return b
end
sideBtn("user", "Thông tin", 1, openInfo)
sideBtn("gear", "Cài đặt", 2, openSettings)
sideBtn("palette", "Giao diện", 3, openThemes)

------------------------------------------------------------------ WINDOW CONTROLS
-- Nut vuong bo goc (co the dat anh): getgenv().DuckButtonImage = "rbxassetid://ID" hoac duong dan file
local floatBtn = new("ImageButton", {
	Parent = gui, AutoButtonColor = false, Image = "", ScaleType = Enum.ScaleType.Crop, Active = true,
	Position = UDim2.new(0, 16, 0.5, -28), Size = UDim2.new(0, 56, 0, 56),
}, { corner(14), stroke("line", 1.5) })
bind(floatBtn, "BackgroundColor3", "bg")
local floatTxt = label(floatBtn, "D", 26, Enum.Font.GothamBold, "text", UDim2.new(), UDim2.new(1, 0, 1, 0), Enum.TextXAlignment.Center)
setButtonImage = function(id)
	id = tostring(id or "")
	if id == "" then floatBtn.Image = "" floatTxt.Visible = true logoImg.Visible = false logoTxt.Visible = true return end
	if id:match("^%d+$") then id = "rbxassetid://" .. id end
	if not id:match("^rbxasset") and not id:match("^https?://") and isfile and getcustomasset then
		local okf, exists = pcall(isfile, id)
		if okf and exists then
			local oka, asset = pcall(getcustomasset, id)
			if oka then id = asset end
		end
	end
	floatBtn.Image = id
	floatTxt.Visible = false
	logoImg.Image = id
	logoImg.Visible = true
	logoTxt.Visible = false
end
do -- logo hub: anh vit deo kinh (nhung san)
	local B64 = [==[
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
qOs+y9zv3LhdV9N8sOKDvR2fV7T4h79++P8+dTgu3cjIdQ6PSzDyO+FcxDt/4eqP/mL/qf2bU+eFQvQ3EM1l3dM6e+eoCsxWMz276j8yCg6PjIw3gJGXGB9+
Zl117YOztZDGnhW9gib1vKmnaXnQHxwsptXHLuo//eiVlMfs/8jIGABGXlp8/NnVQ3W6bcsHH3taW6g8TblYXF5l7d1s+itPlp/+7JVxoUZGMKaARl5idMA/
fyo/0bkbqnJXk2/05ijKanWMlrc0tqfNB58ePcdHRsYbwMhLlC8c4oYaD924vbMz255Xk0bmU4StiuD+9Sf3/4cPPB9HxZ+RkTEAjLxU+dyVWLS6+dj2seOV
22WcIJTFBz+99+PvfezpwzH7PzKCUQtoBC95Jbvvu392/xmWyv/GWf5nH7z48fPLcVlGRkZGvl5oBH68SY6MjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyM
jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyM
jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIxcT/x/AT9lBnMP7ywAAAAASUVORK5CYII=
]==]
	local function dec(data)
		local ok, r = pcall(function()
			if crypt and crypt.base64decode then return crypt.base64decode(data) end
			if base64_decode then return base64_decode(data) end
			if base64 and base64.decode then return base64.decode(data) end
			error("no")
		end)
		if ok and r and #r > 0 then return r end
		local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local map = {}
		for i = 1, 64 do map[chars:sub(i, i)] = i - 1 end
		data = data:gsub("[^%w%+/=]", "")
		local out, n = {}, 0
		for i = 1, #data, 4 do
			local a, b, c, d = map[data:sub(i, i)], map[data:sub(i + 1, i + 1)], map[data:sub(i + 2, i + 2)], map[data:sub(i + 3, i + 3)]
			if not a or not b then break end
			local v = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
			n = n + 1 out[n] = string.char(math.floor(v / 65536) % 256)
			if c then n = n + 1 out[n] = string.char(math.floor(v / 256) % 256) end
			if d then n = n + 1 out[n] = string.char(v % 256) end
		end
		return table.concat(out)
	end
	local applied = false
	if writefile and getcustomasset then
		pcall(function()
			local path = "DuckHub_logo.png"
			writefile(path, dec((B64:gsub("%s", ""))))
			local asset = getcustomasset(path)
			if asset and asset ~= "" then
				getgenv().DuckButtonImage = asset
				setButtonImage(asset)
				applied = true
			end
		end)
	end
end

miniAv = new("Frame", { Parent = floatBtn, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -4), Size = UDim2.new(0, 56, 0, 84), Visible = false })
local function showWindow(v) holder.Visible = v refreshAvatar() end
btnMin.MouseButton1Click:Connect(function() showWindow(false) end)
do -- keo nut di chuyen; bam nhanh = an/hien menu
	local down, moved, startPos, origin = false, false, nil, nil
	floatBtn.InputBegan:Connect(function(i)
		if isPress(i) then down, moved, startPos, origin = true, false, i.Position, floatBtn.Position end
	end)
	UIS.InputChanged:Connect(function(i)
		if down and isMove(i) then
			local d = i.Position - startPos
			if d.Magnitude > 6 then moved = true end
			if moved then floatBtn.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y) end
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if down and isPress(i) then
			down = false
			if not moved then showWindow(not holder.Visible) end
		end
	end)
end
local maxed = false
btnMax.MouseButton1Click:Connect(function() maxed = not maxed userMul = maxed and 1.15 or 1 applyScale() end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)
UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.LeftControl then showWindow(not holder.Visible) end
end)

------------------------------------------------------------------ CHIP (Limit: nguoi choi - Ban)
local function updateChips()
	local txt = string.format("Limit: %d/%d - Bản %d", #Players:GetPlayers(), Players.MaxPlayers, seaNumber())
	for _, t in ipairs(tabs) do t.chipTxt.Text = txt end
end
task.spawn(function()
	while gui.Parent do
		pcall(updateChips)
		task.wait(3)
	end
end)


return {
	makeTab = makeTab, selectTab = selectTab, setTheme = setTheme, gui = gui, Flags = Flags, THEMES = THEMES,
	toggle = function() showWindow(not holder.Visible) end, setButtonImage = function(x) setButtonImage(x) end,
}

end)()

getgenv().DuckUI = DuckUILib

-- ============================================================
-- ================== CHO DE UI (them tab o day) ==================
-- Moi tab:  local Tab = DuckUILib.makeTab("Ten Tab", "Tieu de trang")
-- Cac muc:  Tab:AddSection("TEN MUC")
--           Tab:AddLabel("noi dung")
--           Tab:AddToggle({ Name = "Ten", Desc = "mo ta", Flag = "Khoa", Default = false, Callback = function(v) end })
--           Tab:AddSlider({ Name = "Ten", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
--           Tab:AddButton({ Name = "Ten", Primary = true, Callback = function() end })
--           Tab:AddDropdown({ Name = "Ten", Options = {"A", "B"}, Default = "A", Callback = function(v) end })
--           Tab:AddBox({ Name = "Ten", Placeholder = "...", Callback = function(text) end })
-- ============================================================
local Tab = DuckUILib.makeTab("Chính", "Duck Hub")
Tab:AddSection("Ví dụ")
Tab:AddToggle({ Name = "Công tắc mẫu", Desc = "Chỉ là ví dụ", Flag = "Demo", Default = false, Callback = function(v) end })
-- ================== HET CHO DE UI ==================

return DuckUILib
