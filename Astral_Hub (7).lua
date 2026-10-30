local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local State = {
	SpeedOn = false, Speed = 50,
	JumpOn = false, Jump = 100,
	SpinOn = false, Spin = 20,

	Aimbot = false,
	AimPart = "Head",
	Smoothing = 10,
	FOV = 150,
	FOVCircle = false,
	ThroughWalls = false,
	AutoGun = false,
	CamFrozen = false,
	InfJump = false,

	ESPBox = false,
	ESPChams = false,
	ESPDistance = false,
	ESPName = false,
	ESPSkeleton = false,

	Headless = false,
	SelfOutline = false,
	SelfField = false,
	Korblox = false,
	Stretch = false,
	CamFOVOn = false, CamFOV = 70,

	Noclip = false,
	ESPLines = false,
	ESPDropGun = false,
	Sky = "Off",
	Fullbright = false,
	AntiFling = false,
	Invisible = false,

	Theme = 1,
	HoldRMB = false,
	MenuKey = "RightShift",
}

local applySky

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local BG = Color3.fromRGB(9, 9, 11)

local ROLE_COLORS = {
	Murderer = Color3.fromRGB(255, 60, 60),
	Sheriff = Color3.fromRGB(70, 140, 255),
	Innocent = Color3.fromRGB(70, 255, 110),
}

local Themes = {
	{
		name = "Classic",
		bg = BG, panel = Color3.fromRGB(19, 19, 23), tab = Color3.fromRGB(36, 36, 42),
		off = Color3.fromRGB(52, 52, 60), border = Color3.fromRGB(38, 38, 45),
		text = WHITE, inv = BLACK, knob = WHITE,
		a1 = Color3.fromRGB(112, 112, 120), a2 = WHITE, aStroke = Color3.fromRGB(8, 8, 8),
		glow = Color3.fromRGB(205, 205, 212), onO = WHITE, offO = Color3.fromRGB(26, 26, 32),
		tglow = Color3.fromRGB(205, 205, 212),
		card = WHITE, cardT = 0.65,
		t = {bg = 0.12, panel = 0.1, tab = 0.1, off = 0.05, border = 0},
	},
	{
		name = "Glass",
		bg = Color3.fromRGB(16, 16, 22), panel = WHITE, tab = WHITE,
		off = WHITE, border = WHITE,
		text = WHITE, inv = BLACK, knob = WHITE,
		a1 = Color3.fromRGB(135, 135, 146), a2 = Color3.fromRGB(250, 250, 252), aStroke = Color3.fromRGB(14, 14, 18),
		glow = Color3.fromRGB(205, 205, 216), onO = Color3.fromRGB(14, 14, 18), offO = Color3.fromRGB(14, 14, 18),
		tglow = Color3.fromRGB(205, 205, 216),
		card = WHITE, cardT = 0.45,
		t = {bg = 0.5, panel = 0.92, tab = 0.8, off = 0.7, border = 0.75},
	},
	{
		name = "Light",
		bg = Color3.fromRGB(246, 246, 248), panel = Color3.fromRGB(228, 228, 233),
		tab = Color3.fromRGB(206, 206, 214), off = Color3.fromRGB(184, 184, 194),
		border = Color3.fromRGB(196, 196, 204),
		text = BLACK, inv = WHITE, knob = WHITE,
		a1 = Color3.fromRGB(8, 8, 8), a2 = WHITE, aStroke = BLACK,
		glow = Color3.fromRGB(25, 25, 25), onO = BLACK, offO = Color3.fromRGB(255, 255, 255),
		tglow = Color3.fromRGB(170, 170, 178),
		card = BLACK, cardT = 0.6,
		t = {bg = 0.12, panel = 0.1, tab = 0.1, off = 0.05, border = 0},
	},
}

local cur = Themes[1]

local TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tween(obj, props, info)
	TweenService:Create(obj, info or TWEEN, props):Play()
end

local function apply(obj, props, animated)
	if animated then
		tween(obj, props)
	else
		for k, v in props do
			obj[k] = v
		end
	end
end

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in props do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function corner(obj, r)
	new("UICorner", {CornerRadius = UDim.new(0, r or 6)}, obj)
end

local function isPointer(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch
end

local refreshers = {}
local function onTheme(fn)
	table.insert(refreshers, fn)
	fn(false)
end

local function skin(obj, key)
	onTheme(function(a)
		apply(obj, {BackgroundColor3 = cur[key], BackgroundTransparency = cur.t[key]}, a)
	end)
end

local function ink(obj, prop, key)
	onTheme(function(a)
		apply(obj, {[prop] = cur[key or "text"]}, a)
	end)
end

local function skinStroke(stroke, key)
	onTheme(function(a)
		apply(stroke, {Color = cur[key], Transparency = cur.t[key]}, a)
	end)
end

local function hover(b, base)
	b.MouseEnter:Connect(function()
		tween(b, {BackgroundColor3 = cur.off, BackgroundTransparency = cur.t.off})
	end)
	b.MouseLeave:Connect(function()
		tween(b, {BackgroundColor3 = cur[base], BackgroundTransparency = cur.t[base]})
	end)
end

local function textEdge(label)
	local st = new("UIStroke", {Thickness = 1, Transparency = 0.4}, label)
	onTheme(function(a)
		apply(st, {Color = cur.offO}, a)
	end)
	return st
end

local mode = 0
local blur = new("BlurEffect", {Name = "AstralBlur", Size = 0}, Lighting)

local function updateBlur()
	local want = (State.Theme == 2 and mode > 0) and 18 or 0
	tween(blur, {Size = want}, TweenInfo.new(0.45, Enum.EasingStyle.Quad))
end

local function setTheme(i)
	if not Themes[i] then return end
	State.Theme = i
	cur = Themes[i]
	for _, fn in refreshers do
		fn(true)
	end
	updateBlur()
end

local playerGui = player:WaitForChild("PlayerGui")

local fovGui = new("ScreenGui", {
	Name = "FovCircleGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1,
}, playerGui)

local fovCircle = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(300, 300),
	Visible = true,
}, fovGui)
corner(fovCircle, 1000)
new("UIStroke", {Thickness = 2, Color = WHITE, Transparency = 0.2}, fovCircle)

local gui = new("ScreenGui", {
	Name = "AstralHub", ResetOnSpawn = false, DisplayOrder = 10,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local shimmers = {}
local function addShimmer(stroke, speed)
	local dark = Color3.fromRGB(14, 14, 14)
	local g = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, dark),
			ColorSequenceKeypoint.new(0.25, WHITE),
			ColorSequenceKeypoint.new(0.5, dark),
			ColorSequenceKeypoint.new(0.75, WHITE),
			ColorSequenceKeypoint.new(1, dark),
		}),
	}, stroke)
	table.insert(shimmers, {g, speed or 80})
	return g
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for _, e in shimmers do
		e[1].Rotation = (t * e[2]) % 360
	end
end)

local brandGradients = {}
local function brandText(parent, p)
	local box = new("Frame", {
		Size = UDim2.fromOffset(p.Width, p.Height), Position = p.Position or UDim2.new(),
		BackgroundTransparency = 1, LayoutOrder = p.LayoutOrder or 0,
	}, parent)
	local function make(extra)
		local t = {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = p.Text,
			Font = Enum.Font.GothamBold, TextSize = p.TextSize,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		for k, v in extra do
			t[k] = v
		end
		return new("TextLabel", t, box)
	end
	for _, g in {{6, 0.9}, {3, 0.72}} do
		local gl = make({TextTransparency = 0.97, ZIndex = 1})
		local st = new("UIStroke", {Thickness = g[1], Transparency = g[2]}, gl)
		ink(st, "Color", "tglow")
	end
	local main = make({TextColor3 = WHITE, ZIndex = 2})
	local edge = new("UIStroke", {Thickness = 1.2}, main)
	ink(edge, "Color", "aStroke")
	table.insert(brandGradients, new("UIGradient", {}, main))
	return box
end

RunService.RenderStepped:Connect(function()
	local phase = (os.clock() * 0.3) % 1
	local keys = {}
	for i = 0, 10 do
		local x = i / 10
		local w = (math.sin((x - phase) * math.pi * 2) + 1) / 2
		keys[#keys + 1] = ColorSequenceKeypoint.new(x, cur.a1:Lerp(cur.a2, w))
	end
	local seq = ColorSequence.new(keys)
	for _, g in brandGradients do
		g.Color = seq
	end
end)

local function glowLayers(parent, radius)
	local layers = {}
	for k = 1, 6 do
		local pad = (k - 1) * 3
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, ZIndex = 1,
		}, parent)
		corner(f, radius + pad)
		new("UIStroke", {
			Thickness = 3, Color = cur.glow, Transparency = 0.45 + k * 0.09,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}, f)
		f:SetAttribute("pad", pad)
		layers[k] = f
	end
	onTheme(function(a)
		for _, f in layers do
			apply(f:FindFirstChildOfClass("UIStroke"), {Color = cur.glow}, a)
		end
	end)
	return layers
end

local function placeGlow(layers, h)
	for _, l in layers do
		local pad = l:GetAttribute("pad")
		l.Position = UDim2.new(0.5, 0, 0, -pad)
		l.Size = UDim2.new(1, pad * 2, 0, h + pad * 2)
		l.Visible = h > 2
	end
end

local WIN_W, WIN_H = 680, 360
local TITLE_H = 46

local window = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 1, Visible = false,
}, gui)
local uiScale = new("UIScale", {Scale = 1}, window)

local winGlow = glowLayers(window, 6)

local shade = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0),
	Size = UDim2.fromScale(1, 1), ClipsDescendants = true,
}, window)
corner(shade, 6)
skin(shade, "bg")
local winStroke = new("UIStroke", {Thickness = 1.8, Color = WHITE}, shade)
addShimmer(winStroke, 60)
placeGlow(winGlow, WIN_H)

local body = new("Frame", {
	Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 1,
}, shade)

local title = new("Frame", {Size = UDim2.new(1, 0, 0, TITLE_H)}, body)
skin(title, "panel")

brandText(title, {Text = "Astral Hub", Width = 130, Height = TITLE_H, TextSize = 18, Position = UDim2.fromOffset(16, 0)})

local titleLine = new("Frame", {
	Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, TITLE_H), BorderSizePixel = 0,
}, body)
skin(titleLine, "border")

local fitScale = 1
local animValue = new("NumberValue", {Value = 0}, gui)
local function applyScale()
	uiScale.Scale = fitScale * math.max(animValue.Value, 0.02)
end
animValue.Changed:Connect(applyScale)
applyScale()

local animTween
local function setMode(m)
	if m == mode then return end
	mode = m
	local open = m > 0
	if animTween then animTween:Cancel() end
	if open then window.Visible = true end
	local tw = TweenService:Create(
		animValue,
		TweenInfo.new(
			open and 0.42 or 0.28, Enum.EasingStyle.Quint,
			open and Enum.EasingDirection.Out or Enum.EasingDirection.In
		),
		{Value = open and 1 or 0}
	)
	animTween = tw
	tw.Completed:Connect(function(state)
		if mode == 0 and state == Enum.PlaybackState.Completed then
			window.Visible = false
		end
	end)
	tw:Play()
	updateBlur()
end

local function toggleWindow()
	setMode(mode == 0 and 2 or 0)
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode[State.MenuKey] then
		toggleWindow()
	end
end)

local lastVS
RunService.RenderStepped:Connect(function()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local vs = cam.ViewportSize
	if vs == lastVS then return end
	lastVS = vs
	fitScale = math.clamp(math.min(vs.X * 0.96 / WIN_W, vs.Y * 0.92 / WIN_H), 0.4, 1.15)
	applyScale()
end)

do
	local dragging, dragStart, startPos = false, nil, nil
	title.InputBegan:Connect(function(i)
		if isPointer(i) then
			dragging = true
			dragStart = i.Position
			startPos = window.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if isPointer(i) then dragging = false end
	end)
end

local TAB_W = 150
local AREA_TOP = TITLE_H + 12
local AREA_H = -(TITLE_H + 22)

local tabList = new("Frame", {
	Size = UDim2.new(0, TAB_W, 1, AREA_H), Position = UDim2.fromOffset(10, AREA_TOP),
	BackgroundTransparency = 1,
}, body)
new("UIListLayout", {Padding = UDim.new(0, 6)}, tabList)

local divider = new("Frame", {
	Size = UDim2.new(0, 1, 1, AREA_H), Position = UDim2.fromOffset(TAB_W + 18, AREA_TOP),
	BorderSizePixel = 0,
}, body)
skin(divider, "border")

local content = new("Frame", {
	Size = UDim2.new(1, -(TAB_W + 38), 1, AREA_H), Position = UDim2.fromOffset(TAB_W + 28, AREA_TOP),
	BackgroundTransparency = 1,
}, body)

local pages, tabButtons = {}, {}
local groups = {}
local activeTab

local function renderTabs(animated)
	for n, t in tabButtons do
		local active = (n == activeTab)
		apply(t.btn, {
			BackgroundColor3 = active and cur.tab or cur.panel,
			BackgroundTransparency = active and cur.t.tab or cur.t.panel,
			TextColor3 = cur.text,
			TextTransparency = active and 0 or 0.4,
		}, animated)
		apply(t.outline, {Color = cur.text, Transparency = active and 0 or 1}, animated)
		apply(t.edge, {Color = active and cur.onO or cur.offO}, animated)
	end
end
onTheme(renderTabs)

local function selectTab(name)
	activeTab = name
	for n, page in pages do
		page.Visible = (n == name)
	end
	renderTabs(true)
	for _, refresh in groups do
		refresh()
	end
end

local function createTab(name)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 36), Text = name, Font = Enum.Font.GothamMedium,
		TextSize = 14, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left,
	}, tabList)
	corner(btn, 5)
	new("UIPadding", {PaddingLeft = UDim.new(0, 16)}, btn)
	local outline = new("UIStroke", {
		Thickness = 1.8, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, btn)
	local outlineShine = addShimmer(outline, 70)
	onTheme(function()
		outlineShine.Enabled = State.Theme == 1
	end)
	local edge = new("UIStroke", {Thickness = 1, Transparency = 0.4}, btn)
	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(), Visible = false,
	}, content)
	ink(page, "ScrollBarImageColor3")
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)}, page)
	pages[name] = page
	tabButtons[name] = {btn = btn, outline = outline, edge = edge}
	btn.Activated:Connect(function() selectTab(name) end)
	return page
end

local controls = {}
local pendingKey = nil
local function K(key)
	pendingKey = key
	return State[key]
end

controls.Theme = {type = "number", set = function(v) setTheme(v) end}

local function makeRow(parent, height)
	return new("Frame", {Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1}, parent)
end

local function rowLabel(row, text, rightGap)
	local l = new("TextLabel", {
		Size = UDim2.new(1, -(rightGap or 70), 0, 22), Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	ink(l, "TextColor3")
	return l, textEdge(l)
end

local function addToggle(page, text, default, callback)
	local key = pendingKey
	pendingKey = nil
	local row = makeRow(page, 32)
	local _, edge = rowLabel(row, text)
	local btn = new("TextButton", {
		Size = UDim2.fromOffset(44, 22), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Text = "", AutoButtonColor = false,
	}, row)
	corner(btn, 6)
	local knob = new("Frame", {Size = UDim2.fromOffset(18, 18)}, btn)
	corner(knob, 4)

	local on = default
	local function render(animated)
		apply(btn, {
			BackgroundColor3 = on and cur.text or cur.off,
			BackgroundTransparency = on and 0 or cur.t.off,
		}, animated)
		apply(knob, {
			Position = on and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = on and cur.inv or cur.knob,
		}, animated)
		apply(edge, {Color = on and cur.onO or cur.offO}, animated)
	end
	onTheme(render)
	btn.Activated:Connect(function()
		on = not on
		render(true)
		callback(on)
	end)
	if key then
		controls[key] = {type = "boolean", set = function(v)
			if v == on then return end
			on = v
			render(true)
			callback(v)
		end}
	end
end

local function addSlider(page, text, min, max, default, callback)
	local key = pendingKey
	pendingKey = nil
	local row = makeRow(page, 46)
	rowLabel(row, text, 80)
	local valLbl = new("TextLabel", {
		Size = UDim2.fromOffset(60, 22), AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 5), BackgroundTransparency = 1,
		Text = tostring(default), Font = Enum.Font.GothamBold,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right,
	}, row)
	ink(valLbl, "TextColor3")
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 4), Position = UDim2.fromOffset(0, 34),
	}, row)
	corner(bar, 2)
	skin(bar, "off")
	local a0 = (default - min) / (max - min)
	local fill = new("Frame", {Size = UDim2.fromScale(a0, 1), BorderSizePixel = 0}, bar)
	corner(fill, 2)
	ink(fill, "BackgroundColor3")
	local knob = new("Frame", {
		Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(a0, 0.5),
	}, bar)
	corner(knob, 6)
	ink(knob, "BackgroundColor3")
	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, -10),
		BackgroundTransparency = 1, Text = "",
	}, bar)

	local dragging = false
	local scroller
	local function setFromX(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * a + 0.5)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valLbl.Text = tostring(v)
		callback(v)
	end
	hit.InputBegan:Connect(function(i)
		if isPointer(i) then
			dragging = true
			scroller = hit:FindFirstAncestorOfClass("ScrollingFrame")
			if scroller then scroller.ScrollingEnabled = false end
			setFromX(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then setFromX(i.Position.X) end
	end)
	UIS.InputEnded:Connect(function(i)
		if dragging and isPointer(i) then
			dragging = false
			if scroller then scroller.ScrollingEnabled = true end
		end
	end)
	if key then
		controls[key] = {type = "number", set = function(v)
			v = math.clamp(math.floor(v + 0.5), min, max)
			local a = (v - min) / (max - min)
			fill.Size = UDim2.fromScale(a, 1)
			knob.Position = UDim2.fromScale(a, 0.5)
			valLbl.Text = tostring(v)
			callback(v)
		end}
	end
end

local function addCycle(page, text, options, default, callback)
	local key = pendingKey
	pendingKey = nil
	local row = makeRow(page, 34)
	rowLabel(row, text, 130)
	local idx = table.find(options, default) or 1
	local btn = new("TextButton", {
		Size = UDim2.fromOffset(110, 26), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Text = options[idx],
		Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
	}, row)
	corner(btn, 4)
	skin(btn, "tab")
	ink(btn, "TextColor3")
	hover(btn, "tab")
	btn.Activated:Connect(function()
		idx = idx % #options + 1
		btn.Text = options[idx]
		callback(options[idx])
	end)
	if key then
		controls[key] = {type = "string", set = function(v)
			local i = table.find(options, v)
			if not i or i == idx then return end
			idx = i
			btn.Text = v
			callback(v)
		end}
	end
end

local function addGroup(page, text, startOpen)
	local HEAD = 30
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, HEAD), ClipsDescendants = true,
	}, page)
	corner(holder, 6)
	skin(holder, "panel")
	local cardStroke = new("UIStroke", {Thickness = 1}, holder)
	local cardShine = addShimmer(cardStroke, 25)
	onTheme(function()
		cardShine.Enabled = State.Theme == 1
		end)
	onTheme(function(a)
		apply(cardStroke, {Color = cur.card, Transparency = cur.cardT}, a)
	end)

	local header = new("TextButton", {
		Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, holder)
	local label = new("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1, Text = string.upper(text), TextTransparency = 0.25,
		Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
	}, header)
	ink(label, "TextColor3")
	local arrow = new("TextLabel", {
		Size = UDim2.fromOffset(20, HEAD), AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0), BackgroundTransparency = 1, Text = ">",
		Font = Enum.Font.GothamBold, TextSize = 13, Rotation = startOpen and 90 or 0,
	}, header)
	ink(arrow, "TextColor3")

	local inner = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, HEAD),
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
	}, holder)
	new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, inner)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10),
	}, inner)

	local open = startOpen
	local running
	local function fullHeight()
		return HEAD + inner.AbsoluteSize.Y / uiScale.Scale
	end
	local function refresh()
		if running then return end
		holder.Size = UDim2.new(1, 0, 0, open and fullHeight() or HEAD)
	end
	inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	table.insert(groups, refresh)

	header.Activated:Connect(function()
		open = not open
		if running then running:Cancel() end
		tween(arrow, {Rotation = open and 90 or 0})
		local tw = TweenService:Create(
			holder,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, 0, 0, open and fullHeight() or HEAD)}
		)
		running = tw
		tw.Completed:Connect(function()
			if running == tw then
				running = nil
				refresh()
			end
		end)
		tw:Play()
	end)
	refresh()
	return inner
end

local function addLegend(page)
	local row = makeRow(page, 38)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, row)
	for _, role in {"Murderer", "Sheriff", "Innocent"} do
		new("TextLabel", {
			Size = UDim2.new(1 / 3, 0, 1, 0), BackgroundTransparency = 1,
			Text = role, TextColor3 = ROLE_COLORS[role],
			Font = Enum.Font.GothamBold, TextSize = 13,
		}, row)
	end
end

local function addThemePicker(page)
	local row = makeRow(page, 52)
	local items = {}
	for i, th in Themes do
		local b = new("TextButton", {
			Size = UDim2.new(1 / 3, -8, 0, 34), Position = UDim2.new((i - 1) / 3, 4, 0.5, -17),
			BackgroundColor3 = th.bg, BackgroundTransparency = math.min(th.t.bg, 0.25),
			Text = th.name, TextColor3 = th.text, Font = Enum.Font.GothamBold, TextSize = 13,
			AutoButtonColor = false,
		}, row)
		corner(b, 5)
		local st = new("UIStroke", {Thickness = 2, Color = WHITE}, b)
		local g = addShimmer(st, 90)
		items[i] = {stroke = st, grad = g}
		b.Activated:Connect(function() setTheme(i) end)
	end
	onTheme(function(animated)
		for i, it in items do
			local selected = (i == State.Theme)
			it.grad.Enabled = selected
			if selected then
				it.stroke.Color = WHITE
				it.stroke.Transparency = 0
			else
				apply(it.stroke, {Color = cur.border, Transparency = cur.t.border}, animated)
			end
		end
	end)
end

local lp = createTab("Local Player")
local lpG = addGroup(lp, "Movement", true)
addToggle(lpG, "Speed", K("SpeedOn"), function(v) State.SpeedOn = v end)
addSlider(lpG, "Speed value", 1, 1000, K("Speed"), function(v) State.Speed = v end)
addToggle(lpG, "Jump", K("JumpOn"), function(v) State.JumpOn = v end)
addSlider(lpG, "Jump value", 1, 1000, K("Jump"), function(v) State.Jump = v end)
addToggle(lpG, "Spin", K("SpinOn"), function(v) State.SpinOn = v end)
addSlider(lpG, "Spin speed", 1, 100, K("Spin"), function(v) State.Spin = v end)
addToggle(lpG, "Noclip", K("Noclip"), function(v) State.Noclip = v end)
addToggle(lpG, "Inf Jump", K("InfJump"), function(v) State.InfJump = v end)

local combat = createTab("Combat")
local legitG = addGroup(combat, "Legit", true)
addToggle(legitG, "Aim Bot", K("Aimbot"), function(v) State.Aimbot = v end)
addCycle(legitG, "Aim Part", {"Head", "Torso", "Legs"}, K("AimPart"), function(v) State.AimPart = v end)
addSlider(legitG, "Aim Smoothing", 1, 100, K("Smoothing"), function(v) State.Smoothing = v end)
addSlider(legitG, "FOV", 10, 500, K("FOV"), function(v) State.FOV = v end)
addToggle(legitG, "FOV Circle", K("FOVCircle"), function(v) State.FOVCircle = v end)
addToggle(legitG, "Through Walls", K("ThroughWalls"), function(v) State.ThroughWalls = v end)
local rageG = addGroup(combat, "Rage", true)
addToggle(rageG, "Pick Up Gun", K("AutoGun"), function(v) State.AutoGun = v end)

local visuals = createTab("Visuals")
local espG = addGroup(visuals, "ESP", true)
addToggle(espG, "ESP Box", K("ESPBox"), function(v) State.ESPBox = v end)
addToggle(espG, "ESP Skeleton", K("ESPSkeleton"), function(v) State.ESPSkeleton = v end)
addToggle(espG, "ESP Chams", K("ESPChams"), function(v) State.ESPChams = v end)
addToggle(espG, "ESP Distance", K("ESPDistance"), function(v) State.ESPDistance = v end)
addToggle(espG, "ESP Name", K("ESPName"), function(v) State.ESPName = v end)
addToggle(espG, "ESP Lines", K("ESPLines"), function(v) State.ESPLines = v end)
addToggle(espG, "Drop Gun ESP", K("ESPDropGun"), function(v) State.ESPDropGun = v end)
local colorG = addGroup(visuals, "Role colors", false)
addLegend(colorG)
local charG = addGroup(visuals, "Character", false)
addToggle(charG, "Headless", K("Headless"), function(v) State.Headless = v end)
addToggle(charG, "Korblox (right leg)", K("Korblox"), function(v) State.Korblox = v end)
local toolG = addGroup(visuals, "Custom Toolbox", false)
addToggle(toolG, "Outline Body", K("SelfOutline"), function(v) State.SelfOutline = v end)
addToggle(toolG, "Forcefield Body", K("SelfField"), function(v) State.SelfField = v end)
local worldG = addGroup(visuals, "World", false)
addCycle(worldG, "Custom Sky", {"Off", "Night", "Gray", "Halloween"}, K("Sky"), function(v)
	State.Sky = v
	applySky(v)
end)
addToggle(worldG, "Fullbright", State.Fullbright, function(v) State.Fullbright = v end)
local camG = addGroup(visuals, "Camera", false)
addToggle(camG, "Stretch 4:3", K("Stretch"), function(v) State.Stretch = v end)
addToggle(camG, "Custom FOV", K("CamFOVOn"), function(v) State.CamFOVOn = v end)
addSlider(camG, "FOV value", 30, 120, K("CamFOV"), function(v) State.CamFOV = v end)

local defense = createTab("Defense")
local defG = addGroup(defense, "Protection", true)
addToggle(defG, "Anti Fling", K("AntiFling"), function(v) State.AntiFling = v end)

local troll = createTab("Troll")
local trollG = addGroup(troll, "Fun", true)
addToggle(trollG, "Invisibility", K("Invisible"), function(v) State.Invisible = v end)

local settings = createTab("Settings")

local interfaceG = addGroup(settings, "Interface", true)
addThemePicker(interfaceG)

local aboutG = addGroup(settings, "About", false)
do
	local row = makeRow(aboutG, 36)
	local a = new("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1, Text = "@zoxamo",
		Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	ink(a, "TextColor3")
end

local CFG_ROOT = "AstralHub"
local CFG_DIR = CFG_ROOT .. "/configs"
local hasFS = type(writefile) == "function" and type(readfile) == "function"
	and type(isfile) == "function" and type(listfiles) == "function"
	and type(delfile) == "function" and type(makefolder) == "function"
	and type(isfolder) == "function"
local memStore = {}

local function ensureDir()
	if not hasFS then return end
	pcall(function()
		if not isfolder(CFG_ROOT) then makefolder(CFG_ROOT) end
		if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
	end)
end

local function cleanName(n)
	n = (tostring(n or ""):gsub("[^%w _%-]", ""))
	n = n:match("^%s*(.-)%s*$") or ""
	return string.sub(n, 1, 24)
end

local function cfgPath(name)
	return CFG_DIR .. "/" .. name .. ".json"
end

local function listConfigs()
	local names = {}
	if hasFS then
		ensureDir()
		local ok, files = pcall(listfiles, CFG_DIR)
		if ok and type(files) == "table" then
			for _, f in files do
				local n = tostring(f):match("([^/\\]+)%.json$")
				if n then table.insert(names, n) end
			end
		end
	else
		for n in memStore do table.insert(names, n) end
	end
	table.sort(names, function(a, b) return a:lower() < b:lower() end)
	return names
end

local function findConfig(name)
	for _, n in listConfigs() do
		if n:lower() == name:lower() then return n end
	end
end

local function writeConfig(name, data)
	if hasFS then
		ensureDir()
		return (pcall(writefile, cfgPath(name), data))
	end
	memStore[name] = data
	return true
end

local function readConfig(name)
	if hasFS then
		local ok, data = pcall(function()
			if isfile(cfgPath(name)) then return readfile(cfgPath(name)) end
		end)
		return ok and data or nil
	end
	return memStore[name]
end

local function removeConfig(name)
	if hasFS then
		pcall(delfile, cfgPath(name))
	else
		memStore[name] = nil
	end
end

local function snapshot()
	local data = {}
	for key in controls do
		data[key] = State[key]
	end
	return HttpService:JSONEncode(data)
end

local function applyConfig(json)
	local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
	if not ok or type(data) ~= "table" then return false end
	for key, val in data do
		local c = controls[key]
		if c and type(val) == c.type then
			pcall(c.set, val)
		end
	end
	return true
end

local cfgG = addGroup(settings, "Config", false)

local infoRow = makeRow(cfgG, 30)
local infoLabel = new("TextLabel", {
	Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
	BackgroundTransparency = 1, TextTransparency = 0.35,
	Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
	Text = hasFS and ("Storage: files (" .. CFG_DIR .. ")") or "Storage: session only (no file access)",
}, infoRow)
ink(infoLabel, "TextColor3")

local nameRow = makeRow(cfgG, 38)
local nameBox = new("TextBox", {
	Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 6),
	PlaceholderText = "Config name", Text = "",
	Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
}, nameRow)
corner(nameBox, 4)
skin(nameBox, "tab")
ink(nameBox, "TextColor3")
ink(nameBox, "PlaceholderColor3")
new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, nameBox)

local btnRow = makeRow(cfgG, 38)
local function cfgButton(text, index, count, onClick)
	local b = new("TextButton", {
		Size = UDim2.new(1 / count, -6, 0, 26), Position = UDim2.new((index - 1) / count, 3, 0.5, -13),
		Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false,
	}, btnRow)
	corner(b, 4)
	skin(b, "tab")
	ink(b, "TextColor3")
	hover(b, "tab")
	b.Activated:Connect(onClick)
end

local statusRow = makeRow(cfgG, 34)
local statusLabel = new("TextLabel", {
	Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
	BackgroundTransparency = 1, Text = "Ready",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
}, statusRow)
ink(statusLabel, "TextColor3")
local function setStatus(t) statusLabel.Text = t end

local listHolder = new("Frame", {
	Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
}, cfgG)
corner(listHolder, 4)
skin(listHolder, "panel")
local listStroke = new("UIStroke", {Thickness = 1}, listHolder)
skinStroke(listStroke, "border")
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, listHolder)
new("UIPadding", {
	PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
	PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
}, listHolder)

local selected, delArm = nil, nil
local refreshList

refreshList = function()
	for _, c in listHolder:GetChildren() do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	local names = listConfigs()
	if selected and not table.find(names, selected) then selected = nil end

	if #names == 0 then
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
			Text = "No configs yet", TextColor3 = cur.text, TextTransparency = 0.4,
			Font = Enum.Font.Gotham, TextSize = 13,
		}, listHolder)
		return
	end

	for i, n in names do
		local isSel = (n == selected)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 28), LayoutOrder = i,
			BackgroundColor3 = isSel and cur.tab or cur.panel,
			BackgroundTransparency = isSel and cur.t.tab or cur.t.panel,
			Text = n, TextColor3 = cur.text, Font = Enum.Font.GothamMedium, TextSize = 13,
			AutoButtonColor = false,
		}, listHolder)
		corner(b, 4)
		new("UIStroke", {
			Thickness = 1, Color = isSel and cur.text or cur.border,
			Transparency = isSel and 0 or cur.t.border,
		}, b)
		b.Activated:Connect(function()
			selected = n
			delArm = nil
			nameBox.Text = ""
			refreshList()
			setStatus("Selected '" .. n .. "'")
		end)
	end
end

onTheme(function() refreshList() end)

cfgButton("Create", 1, 4, function()
	local name = cleanName(nameBox.Text)
	if name == "" then setStatus("Enter a config name first") return end
	local existing = findConfig(name)
	if existing then
		setStatus("'" .. existing .. "' already exists - select it and press Save")
		return
	end
	if writeConfig(name, snapshot()) then
		selected = name
		nameBox.Text = ""
		refreshList()
		setStatus("Created '" .. name .. "'")
	else
		setStatus("Could not write the config")
	end
end)

cfgButton("Save", 2, 4, function()
	if not selected then setStatus("Select a config first") return end
	if writeConfig(selected, snapshot()) then
		setStatus("Saved '" .. selected .. "'")
	else
		setStatus("Could not write the config")
	end
end)

cfgButton("Load", 3, 4, function()
	if not selected then setStatus("Select a config first") return end
	local data = readConfig(selected)
	if not data then
		setStatus("Config not found")
		refreshList()
		return
	end
	if applyConfig(data) then
		setStatus("Loaded '" .. selected .. "'")
	else
		setStatus("Config is corrupted")
	end
end)

cfgButton("Delete", 4, 4, function()
	if not selected then setStatus("Select a config first") return end
	local name = selected
	if delArm ~= name then
		delArm = name
		setStatus("Press Delete again to remove '" .. name .. "'")
		task.delay(3, function()
			if delArm == name then delArm = nil end
		end)
		return
	end
	delArm = nil
	removeConfig(name)
	selected = nil
	refreshList()
	setStatus("Deleted '" .. name .. "'")
end)

local menuG = addGroup(settings, "Menu", false)
addCycle(menuG, "Menu Key", {"RightShift", "Insert", "RightControl", "P"}, K("MenuKey"), function(v)
	State.MenuKey = v
end)
addToggle(menuG, "Hold RMB to aim", K("HoldRMB"), function(v) State.HoldRMB = v end)

selectTab("Local Player")
setMode(2)

local wasSpeed, wasJump, wasSpin = false, false, false

RunService.Heartbeat:Connect(function(dt)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	if State.SpeedOn then
		hum.WalkSpeed = State.Speed
	elseif wasSpeed then
		hum.WalkSpeed = 16
	end
	wasSpeed = State.SpeedOn

	if State.JumpOn then
		hum.UseJumpPower = true
		hum.JumpPower = State.Jump
	elseif wasJump then
		hum.JumpPower = 50
	end
	wasJump = State.JumpOn

	if State.SpinOn then
		hum.AutoRotate = false
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.Spin * 10) * dt, 0)
	elseif wasSpin then
		hum.AutoRotate = true
	end
	wasSpin = State.SpinOn
end)

local KNIFE_NAME = "Knife"
local GUN_NAME = "Gun"

local function getRole(plr)
	local char = plr.Character
	local bp = plr:FindFirstChildOfClass("Backpack")
	if (char and char:FindFirstChild(KNIFE_NAME)) or (bp and bp:FindFirstChild(KNIFE_NAME)) then
		return "Murderer"
	end
	if (char and char:FindFirstChild(GUN_NAME)) or (bp and bp:FindFirstChild(GUN_NAME)) then
		return "Sheriff"
	end
	return "Innocent"
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function getAimPart(char)
	if State.AimPart == "Head" then
		return char:FindFirstChild("Head")
	elseif State.AimPart == "Torso" then
		return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	else
		return char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg")
	end
end

local function isVisible(cam, part, char)
	rayParams.FilterDescendantsInstances = {player.Character}
	local origin = cam.CFrame.Position
	local result = Workspace:Raycast(origin, part.Position - origin, rayParams)
	return result == nil or result.Instance:IsDescendantOf(char)
end

local function getTarget(cam)
	local center = cam.ViewportSize / 2
	local best, bestDist = nil, State.FOV
	for _, plr in Players:GetPlayers() do
		local char = plr.Character
		if plr ~= player and char and getRole(plr) == "Murderer" then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local part = getAimPart(char)
			if hum and hum.Health > 0 and part then
				local pos, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen then
					local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if d < bestDist and (State.ThroughWalls or isVisible(cam, part, char)) then
						best, bestDist = part, d
					end
				end
			end
		end
	end
	return best
end

RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local cam = Workspace.CurrentCamera
	if not cam then return end

	local vs = cam.ViewportSize
	fovCircle.Position = UDim2.fromOffset(vs.X / 2, vs.Y / 2)
	fovCircle.Size = UDim2.fromOffset(State.FOV * 2, State.FOV * 2)
	fovCircle.Visible = State.FOVCircle

	if State.CamFrozen or not State.Aimbot then return end
	if State.HoldRMB and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

	local target = getTarget(cam)
	if target then
		local cf = cam.CFrame
		local goal = CFrame.lookAt(cf.Position, target.Position)
		cam.CFrame = cf:Lerp(goal, math.clamp(dt * 60 / State.Smoothing, 0, 1))
	end
end)

local espGui
do
	espGui = new("ScreenGui", {
		Name = "AstralESP", ResetOnSpawn = false, DisplayOrder = 5, IgnoreGuiInset = true,
	}, playerGui)

	local espData = {}

	local R15_BONES = {
		{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
		{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
		{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
		{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
		{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
	}

	local R6_BONES = {
		{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
		{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
	}

	local function newLine()
		return new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0,
			BackgroundColor3 = WHITE, Visible = false,
		}, espGui)
	end

	local function setLine(frame, a, b, thickness, color)
		local diff = b - a
		frame.Size = UDim2.fromOffset(diff.Magnitude, thickness)
		frame.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
		frame.Rotation = math.deg(math.atan2(diff.Y, diff.X))
		frame.BackgroundColor3 = color
		frame.Visible = true
	end

	local function destroyESP(plr)
		local d = espData[plr]
		if d then
			d.box:Destroy()
			d.text:Destroy()
			d.highlight:Destroy()
			d.line:Destroy()
			for _, f in d.bones do
				f:Destroy()
			end
			espData[plr] = nil
		end
	end

	local function createESP(plr, char, root, head)
		local box = new("BillboardGui", {
			Adornee = root, AlwaysOnTop = true, Size = UDim2.fromScale(4, 6),
			ResetOnSpawn = false,
		}, espGui)
		local boxFrame = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}, box)
		local stroke = new("UIStroke", {Thickness = 1.5, Color = WHITE}, boxFrame)

		local text = new("BillboardGui", {
			Adornee = head, AlwaysOnTop = true, Size = UDim2.fromOffset(200, 36),
			StudsOffset = Vector3.new(0, 2.6, 0), ResetOnSpawn = false,
		}, espGui)
		local label = new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = WHITE,
			TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextSize = 13,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}, text)

		local highlight = new("Highlight", {
			FillTransparency = 0.5, OutlineTransparency = 0,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		}, char)

		espData[plr] = {
			char = char, box = box, stroke = stroke, text = text, label = label,
			highlight = highlight, line = newLine(), bones = {},
		}
		return espData[plr]
	end

	local function updateSkeleton(d, char, cam, color)
		local used = 0
		if State.ESPSkeleton and cam then
			local set = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
			for _, pair in set do
				local p0 = char:FindFirstChild(pair[1])
				local p1 = char:FindFirstChild(pair[2])
				if p0 and p1 then
					local a = cam:WorldToViewportPoint(p0.Position)
					local b = cam:WorldToViewportPoint(p1.Position)
					if a.Z > 0 and b.Z > 0 then
						used += 1
						local f = d.bones[used]
						if not f then
							f = newLine()
							d.bones[used] = f
						end
						setLine(f, Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y), 1.6, color)
					end
				end
			end
		end
		for i = used + 1, #d.bones do
			d.bones[i].Visible = false
		end
	end

	RunService.RenderStepped:Connect(function()
		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local anyOn = State.ESPBox or State.ESPChams or State.ESPDistance
			or State.ESPName or State.ESPLines or State.ESPSkeleton
		local cam = Workspace.CurrentCamera

		for _, plr in Players:GetPlayers() do
			if plr ~= player then
				local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local head = char and char:FindFirstChild("Head")

				if anyOn and hum and hum.Health > 0 and root and head then
					local d = espData[plr]
					if d and d.char ~= char then
						destroyESP(plr)
						d = nil
					end
					d = d or createESP(plr, char, root, head)

					local color = ROLE_COLORS[getRole(plr)]

					d.box.Enabled = State.ESPBox
					d.stroke.Color = color

					d.highlight.Enabled = State.ESPChams
					d.highlight.FillColor = color
					d.highlight.OutlineColor = color

					local drawn = false
					if State.ESPLines and cam then
						local pos, onScreen = cam:WorldToViewportPoint(root.Position)
						if onScreen then
							local vs = cam.ViewportSize
							setLine(d.line, Vector2.new(vs.X / 2, vs.Y), Vector2.new(pos.X, pos.Y), 1.5, color)
							drawn = true
						end
					end
					d.line.Visible = drawn

					updateSkeleton(d, char, cam, color)

					local lines = {}
					if State.ESPName then
						table.insert(lines, plr.DisplayName)
					end
					if State.ESPDistance and myRoot then
						table.insert(lines, math.floor((myRoot.Position - root.Position).Magnitude) .. " studs")
					end
					d.text.Enabled = #lines > 0
					d.label.Text = table.concat(lines, "\n")
					d.label.TextColor3 = color
				else
					destroyESP(plr)
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(destroyESP)
end

do
	local infoGui = new("ScreenGui", {
		Name = "AstralInfo", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 12,
	}, playerGui)

	local PILL_W, PILL_H = 330, 36
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(PILL_W, PILL_H), BackgroundTransparency = 1,
	}, infoGui)
	placeGlow(glowLayers(holder, 5), PILL_H)

	local pill = new("Frame", {Size = UDim2.fromScale(1, 1), ZIndex = 2}, holder)
	local click = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5,
	}, holder)
	click.Activated:Connect(toggleWindow)
	corner(pill, 5)
	local pillStroke = new("UIStroke", {Thickness = 1}, pill)
	onTheme(function(a)
		local glass = State.Theme == 2
		apply(pill, {
			BackgroundColor3 = cur.bg,
			BackgroundTransparency = glass and 1 or math.min(cur.t.bg, 0.15),
		}, a)
		apply(pillStroke, {
			Color = glass and WHITE or cur.border,
			Transparency = glass and 0 or cur.t.border,
			Thickness = glass and 1.5 or 1,
		}, a)
	end)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 9),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	}, pill)

	local function sep(order)
		local f = new("Frame", {
			Size = UDim2.fromOffset(1, 16), BorderSizePixel = 0, LayoutOrder = order,
		}, pill)
		skin(f, "off")
	end

	local function stat(text, width, order)
		local l = new("TextLabel", {
			Size = UDim2.fromOffset(width, 18), BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = order,
		}, pill)
		ink(l, "TextColor3")
		local shadow = new("UIStroke", {Thickness = 0.6, Color = BLACK, Transparency = 1}, l)
		onTheme(function(a)
			apply(shadow, {Transparency = State.Theme == 2 and 0.45 or 1}, a)
		end)
		return l
	end

	local badge = new("TextLabel", {
		Size = UDim2.fromOffset(22, 22), BorderSizePixel = 0, Text = "A",
		Font = Enum.Font.GothamBold, TextSize = 15, LayoutOrder = 1,
	}, pill)
	corner(badge, 3)
	onTheme(function(a)
		apply(badge, {BackgroundColor3 = cur.a1, TextColor3 = cur.inv}, a)
	end)
	brandText(pill, {Text = "Astral Hub", Width = 88, Height = 22, TextSize = 14, LayoutOrder = 2})
	sep(3)
	local fpsLabel = stat("60 fps", 50, 4)
	sep(5)
	local pingLabel = stat("0 ms", 46, 6)
	sep(7)
	local plrLabel = stat("0/0", 38, 8)

	local function getPing()
		local ok, v = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and v then return math.floor(v + 0.5) end
		return math.floor(player:GetNetworkPing() * 2000)
	end

	local frames, lastTick = 0, os.clock()
	RunService.RenderStepped:Connect(function()
		frames += 1
		local now = os.clock()
		if now - lastTick >= 0.5 then
			fpsLabel.Text = math.floor(frames / (now - lastTick) + 0.5) .. " fps"
			pingLabel.Text = getPing() .. " ms"
			plrLabel.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
			frames, lastTick = 0, now
		end
	end)
end

do
	local KORBLOX_PARTS = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}

	local function setHeadless(char, on)
		local head = char:FindFirstChild("Head")
		if not head then return end
		head.Transparency = on and 1 or 0
		local face = head:FindFirstChildOfClass("Decal")
		if face then face.Transparency = on and 1 or 0 end
	end

	local function setKorblox(char, on)
		for _, name in KORBLOX_PARTS do
			local part = char:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				local bone = part:FindFirstChild("AstralKorblox")
				if on then
					part.Transparency = 1
					if not bone then
						bone = Instance.new("Part")
						bone.Name = "AstralKorblox"
						bone.Color = Color3.fromRGB(28, 28, 32)
						bone.Material = Enum.Material.SmoothPlastic
						bone.CanCollide = false
						bone.CanTouch = false
						bone.CanQuery = false
						bone.Massless = true
						if name == "RightFoot" then
							bone.Size = Vector3.new(0.3, 0.18, 0.8)
							bone.CFrame = part.CFrame * CFrame.new(0, -0.05, -0.15)
						else
							bone.Shape = Enum.PartType.Cylinder
							bone.Size = Vector3.new(part.Size.Y, 0.22, 0.22)
							bone.CFrame = part.CFrame * CFrame.Angles(0, 0, math.rad(90))
						end
						bone.Parent = part
						local w = Instance.new("WeldConstraint")
						w.Part0 = part
						w.Part1 = bone
						w.Parent = bone
					end
				elseif bone then
					bone:Destroy()
					part.Transparency = 0
				end
			end
		end
	end

	local wasHeadless, wasKorblox = false, false
	RunService.RenderStepped:Connect(function()
		local char = player.Character
		if not char then return end

		if State.Headless then
			setHeadless(char, true)
		elseif wasHeadless then
			setHeadless(char, false)
		end
		wasHeadless = State.Headless

		if State.Korblox then
			setKorblox(char, true)
		elseif wasKorblox then
			setKorblox(char, false)
		end
		wasKorblox = State.Korblox
	end)
end

local wasFov = false
RunService:BindToRenderStep("AstralCamera", Enum.RenderPriority.Camera.Value + 2, function()
	local cam = Workspace.CurrentCamera
	if not cam then return end

	if State.CamFOVOn then
		cam.FieldOfView = State.CamFOV
	elseif wasFov then
		cam.FieldOfView = 70
	end
	wasFov = State.CamFOVOn

	if State.Stretch and not State.CamFrozen then
		cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.65, 0, 0, 0, 1)
	end
end)

RunService.Stepped:Connect(function()
	local char = player.Character

	if State.Noclip and char then
		for _, o in char:GetDescendants() do
			if o:IsA("BasePart") then o.CanCollide = false end
		end
	end

	if State.AntiFling then
		for _, plr in Players:GetPlayers() do
			local oc = plr ~= player and plr.Character
			if oc then
				for _, o in oc:GetChildren() do
					if o:IsA("BasePart") then o.CanCollide = false end
				end
			end
		end
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local limit = 250 + (State.SpeedOn and State.Speed or 0) + (State.JumpOn and State.Jump or 0)
			if root.AssemblyLinearVelocity.Magnitude > limit or root.AssemblyAngularVelocity.Magnitude > 60 then
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end
end)

local DROP_NAME = "GunDrop"
local DROP_COLOR = Color3.fromRGB(255, 220, 60)
local gunDrops, dropData = {}, {}

local function trackDrop(inst)
	if inst.Name == DROP_NAME then gunDrops[inst] = true end
end
for _, d in Workspace:GetDescendants() do trackDrop(d) end
Workspace.DescendantAdded:Connect(trackDrop)

local function clearDrop(inst)
	local d = dropData[inst]
	if d then
		d.highlight:Destroy()
		d.gui:Destroy()
		dropData[inst] = nil
	end
end

RunService.RenderStepped:Connect(function()
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	for inst in gunDrops do
		if not inst:IsDescendantOf(Workspace) then
			clearDrop(inst)
			gunDrops[inst] = nil
		elseif State.ESPDropGun then
			local d = dropData[inst]
			if not d then
				local adornee = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
				if adornee then
					local gui = new("BillboardGui", {
						Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(160, 24),
						StudsOffset = Vector3.new(0, 2, 0), ResetOnSpawn = false,
					}, espGui)
					local label = new("TextLabel", {
						Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
						TextColor3 = DROP_COLOR, TextStrokeTransparency = 0,
						Font = Enum.Font.GothamBold, TextSize = 13,
					}, gui)
					local hl = new("Highlight", {
						Adornee = inst, FillColor = DROP_COLOR, OutlineColor = DROP_COLOR,
						FillTransparency = 0.4, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
					}, inst)
					d = {gui = gui, label = label, highlight = hl, part = adornee}
					dropData[inst] = d
				end
			end
			if d then
				local dist = myRoot and math.floor((myRoot.Position - d.part.Position).Magnitude) or 0
				d.label.Text = "Gun Drop [" .. dist .. "]"
			end
		else
			clearDrop(inst)
		end
	end
end)

local skyState = {orig = nil, hidden = {}, sky = nil, atmo = nil}

applySky = function(mode)
	if not skyState.orig then
		skyState.orig = {ClockTime = Lighting.ClockTime, ColorShift_Top = Lighting.ColorShift_Top}
	end
	if skyState.sky then skyState.sky:Destroy() skyState.sky = nil end
	if skyState.atmo then skyState.atmo:Destroy() skyState.atmo = nil end
	for _, o in skyState.hidden do o.Parent = Lighting end
	table.clear(skyState.hidden)

	if mode == "Off" then
		Lighting.ClockTime = skyState.orig.ClockTime
		Lighting.ColorShift_Top = skyState.orig.ColorShift_Top
		return
	end
	Lighting.ColorShift_Top = skyState.orig.ColorShift_Top

	for _, c in Lighting:GetChildren() do
		if c:IsA("Sky") or c:IsA("Atmosphere") then
			table.insert(skyState.hidden, c)
			c.Parent = nil
		end
	end

	local sky = Instance.new("Sky")
	sky.Name = "AstralSky"
	sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "", "", ""
	sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "", "", ""
	sky.StarCount = 0
	sky.CelestialBodiesShown = false
	sky.Parent = Lighting
	skyState.sky = sky

	if mode == "Night" then
		Lighting.ClockTime = 0
	elseif mode == "Halloween" then
		Lighting.ClockTime = 0
		sky.StarCount = 4000
		sky.CelestialBodiesShown = true
		sky.MoonAngularSize = 32
		Lighting.ColorShift_Top = Color3.fromRGB(255, 120, 30)
		skyState.atmo = new("Atmosphere", {
			Name = "AstralAtmosphere", Color = Color3.fromRGB(255, 110, 25),
			Decay = Color3.fromRGB(80, 20, 120), Density = 0.38, Offset = 0.3,
			Glare = 0, Haze = 1.6,
		}, Lighting)
	else
		Lighting.ClockTime = 14
		local gray = Color3.fromRGB(140, 140, 140)
		skyState.atmo = new("Atmosphere", {
			Name = "AstralAtmosphere", Color = gray, Decay = gray,
			Density = 0.3, Offset = 1, Glare = 0, Haze = 0,
		}, Lighting)
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		if State.Sky ~= "Off" then
			if not skyState.sky or skyState.sky.Parent ~= Lighting then
				applySky(State.Sky)
			end
			Lighting.ClockTime = (State.Sky == "Night" or State.Sky == "Halloween") and 0 or 14
		end
	end
end)

do
	local invisOrig, wasInvis = {}, false

	RunService.RenderStepped:Connect(function()
		local char = player.Character
		if not char then return end

		if State.Invisible then
			for _, o in char:GetDescendants() do
				if o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture") then
					if invisOrig[o] == nil then invisOrig[o] = o.Transparency end
					o.Transparency = 1
				end
			end
			wasInvis = true
		elseif wasInvis then
			for o, t in invisOrig do
				if o.Parent then o.Transparency = t end
			end
			table.clear(invisOrig)
			wasInvis = false
		end
	end)

	local lookOrig = {}
	local lookActive = false
	local lookGlow

	local function restoreLook()
		for o, rec in lookOrig do
			if o.Parent then
				o.Transparency = rec.t
				if rec.m then o.Material = rec.m end
			end
		end
		table.clear(lookOrig)
		if lookGlow then
			lookGlow:Destroy()
			lookGlow = nil
		end
		lookActive = false
	end

	RunService.RenderStepped:Connect(function()
		local char = player.Character
		local want = (State.SelfOutline or State.SelfField) and char and not State.Invisible
		if not want then
			if lookActive then restoreLook() end
			return
		end
		lookActive = true

		for _, o in char:GetDescendants() do
			local isPart = o:IsA("BasePart")
			if (isPart and o.Name ~= "HumanoidRootPart") or o:IsA("Decal") then
				local rec = lookOrig[o]
				if not rec then
					rec = {t = o.Transparency, m = isPart and o.Material or nil}
					lookOrig[o] = rec
				end
				if State.SelfOutline then
					o.Transparency = isPart and 0.99 or 1
				else
					o.Transparency = rec.t
				end
				if isPart then
					o.Material = State.SelfField and Enum.Material.ForceField or rec.m
				end
			end
		end

		if State.SelfOutline then
			if not lookGlow or lookGlow.Parent ~= char then
				if lookGlow then lookGlow:Destroy() end
				lookGlow = new("Highlight", {
					Name = "AstralOutline", FillTransparency = 1,
					OutlineColor = WHITE, OutlineTransparency = 0,
					DepthMode = Enum.HighlightDepthMode.Occluded,
				}, char)
			end
		elseif lookGlow then
			lookGlow:Destroy()
			lookGlow = nil
		end
	end)
end

UIS.JumpRequest:Connect(function()
	if not State.InfJump then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

do
	local MAX_DROP_DIST = 600

	local function inRound()
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local cam = Workspace.CurrentCamera
		if not (hum and root and cam) then return false end
		if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return false end
		if cam.CameraType == Enum.CameraType.Scriptable and not State.CamFrozen then return false end
		for _, plr in Players:GetPlayers() do
			if plr ~= player and getRole(plr) == "Murderer" then
				local c = plr.Character
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if h and h.Health > 0 then return true end
			end
		end
		return false
	end

	local gunBusy, gunCooldown = false, 0

	local function findDrop(root)
		local best, bestPart, bestDist = nil, nil, MAX_DROP_DIST
		for inst in gunDrops do
			if inst:IsDescendantOf(Workspace) then
				local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
				if part then
					local d = (part.Position - root.Position).Magnitude
					if d <= bestDist then
						best, bestPart, bestDist = inst, part, d
					end
				end
			end
		end
		return best, bestPart
	end

	RunService.Heartbeat:Connect(function()
		if gunBusy or not State.AutoGun then return end
		if os.clock() < gunCooldown then return end
		if not inRound() or getRole(player) ~= "Innocent" then return end

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local cam = Workspace.CurrentCamera
		if not (root and cam) then return end
		local drop, dropPart = findDrop(root)
		if not drop then return end

		gunBusy = true
		local back = root.CFrame
		local camCF, camType = cam.CFrame, cam.CameraType
		State.CamFrozen = true
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = camCF

		local got = false
		pcall(function()
			local t0 = os.clock()
			while os.clock() - t0 < 0.4 and State.AutoGun do
				if not (root.Parent and drop:IsDescendantOf(Workspace) and inRound()) then break end
				if getRole(player) ~= "Innocent" then
					got = true
					break
				end
				root.CFrame = CFrame.new(dropPart.Position + Vector3.new(0, 1.5, 0))
				root.AssemblyLinearVelocity = Vector3.zero
				RunService.Heartbeat:Wait()
			end
		end)

		if root.Parent and inRound() then
			root.CFrame = back
			root.AssemblyLinearVelocity = Vector3.zero
		end
		if cam.CameraType == Enum.CameraType.Scriptable then
			cam.CameraType = camType
		end
		State.CamFrozen = false
		if not got then gunCooldown = os.clock() + 0.25 end
		gunBusy = false
	end)
end

local fbOrig = nil
RunService.RenderStepped:Connect(function()
	if State.Fullbright then
		if not fbOrig then
			fbOrig = {
				Brightness = Lighting.Brightness,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				GlobalShadows = Lighting.GlobalShadows,
				FogEnd = Lighting.FogEnd,
				ExposureCompensation = Lighting.ExposureCompensation,
			}
		end
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(190, 190, 190)
		Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
		Lighting.ExposureCompensation = 0
	elseif fbOrig then
		for k, v in fbOrig do
			Lighting[k] = v
		end
		fbOrig = nil
	end
end)
