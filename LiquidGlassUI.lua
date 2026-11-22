local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if getgenv and getgenv().LiquidGlassUI then
    pcall(function() getgenv().LiquidGlassUI:Destroy() end)
    getgenv().LiquidGlassUI = nil
end
local COLORS = {
    Dark = Color3.fromRGB(20, 20, 26),
    Glass = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Sub = Color3.fromRGB(160, 160, 175),
    Black = Color3.fromRGB(10, 10, 12),
    Gray = Color3.fromRGB(70, 70, 85),
    Green = Color3.fromRGB(80, 200, 140),
    Red = Color3.fromRGB(235, 95, 85),
    Yellow = Color3.fromRGB(240, 190, 80),
}
local EASE = Enum.EasingStyle.Quad
local EASE_OUT = Enum.EasingDirection.Out
local EASE_BACK = Enum.EasingStyle.Back
local EASE_ELASTIC = Enum.EasingStyle.Elastic
local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end
local function addCorner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end
local function addStroke(parent, thickness, color, transparency)
    return create("UIStroke", {
        Thickness = thickness or 1,
        Color = color or Color3.fromRGB(255, 255, 255),
        Transparency = transparency ~= nil and transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end
local function tween(obj, props, time, style, dir, callback)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.35, style or EASE, dir or EASE_OUT, 0, false, 0), props)
    t:Play()
    if callback then t.Completed:Connect(callback) end
    return t
end
local function tweenLoop(obj, props, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.35, style or EASE, dir or EASE_OUT, -1, true, 0), props)
    t:Play()
    return t
end
local guiParent
pcall(function()
    if gethui then guiParent = gethui() end
end)
if not guiParent then
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    guiParent = ok and cg or LocalPlayer:WaitForChild("PlayerGui")
end
local ScreenGui = create("ScreenGui", {
    Name = "LiquidGlassUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)
if getgenv then getgenv().LiquidGlassUI = ScreenGui end
local Island = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.fromOffset(190, 34),
    BackgroundColor3 = COLORS.Black,
    BorderSizePixel = 0,
}, ScreenGui)
addCorner(Island, 17)
addStroke(Island, 1, COLORS.Glass, 0.88)
local islandScale = create("UIScale", { Scale = 0.6 }, Island)
local recDot = create("Frame", {
    Position = UDim2.fromOffset(13, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, Island)
addCorner(recDot, 4)
tweenLoop(recDot, { BackgroundTransparency = 0.6 }, 0.8, Enum.EasingStyle.Sine)
local islandTitle = create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(130, 20),
    BackgroundTransparency = 1,
    Text = "09:41",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
}, Island)
local islandBattery = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -11, 0.5, 0),
    Size = UDim2.fromOffset(46, 20),
    BackgroundTransparency = 1,
    Text = "100%",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Right,
}, Island)
local islandExtra = create("Frame", {
    Position = UDim2.new(0, 15, 0, 40),
    Size = UDim2.new(1, -30, 1, -48),
    BackgroundTransparency = 1,
    Visible = false,
}, Island)
local islandSub = create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 18),
    BackgroundTransparency = 1,
    Text = "Liquid Glass UI",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, islandExtra)
local islandFps = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(64, 18),
    BackgroundTransparency = 1,
    Text = "60 FPS",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Right,
}, islandExtra)
local musicBars = {}
for i = 1, 5 do
    local bar = create("Frame", {
        Position = UDim2.new(0, (i - 1) * 8, 1, -3),
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.fromOffset(4, 7),
        BackgroundColor3 = COLORS.Text,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, islandExtra)
    addCorner(bar, 2)
    musicBars[i] = bar
end
local islandExpanded = false
local islandAuto = true
local function setIsland(title, sub)
    islandTitle.Text = title
    if sub then islandSub.Text = sub end
end
local function islandExpand(title, sub)
    islandExpanded = true
    islandExtra.Visible = true
    if title then setIsland(title, sub) end
    tween(Island, { Size = UDim2.fromOffset(330, 86) }, 0.5, EASE_BACK)
    tween(islandScale, { Scale = 1 }, 0.5, EASE_BACK)
    for i, bar in ipairs(musicBars) do
        tweenLoop(bar, { Size = UDim2.fromOffset(4, 5 + math.random(3, 13)) }, 0.28 + i * 0.05, Enum.EasingStyle.Sine)
    end
end
local function islandCollapse()
    islandExpanded = false
    tween(Island, { Size = UDim2.fromOffset(190, 34) }, 0.4, EASE)
    tween(islandScale, { Scale = 1 }, 0.4, EASE, EASE_OUT, function()
        if not islandExpanded then islandExtra.Visible = false end
    end)
end
local Shadow = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.54),
    Size = UDim2.fromOffset(560, 380),
    BackgroundColor3 = COLORS.Black,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
}, ScreenGui)
addCorner(Shadow, 24)
local MainWindow = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.52),
    Size = UDim2.fromOffset(540, 360),
    BackgroundColor3 = COLORS.Dark,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
}, ScreenGui)
addCorner(MainWindow, 20)
addStroke(MainWindow, 1, COLORS.Glass, 0.78)
local fitScale = create("UIScale", { Scale = 1 }, MainWindow)
local animScale = create("UIScale", { Scale = 0.85 }, MainWindow)
local shadowFit = create("UIScale", { Scale = 1 }, Shadow)
local function updateFit()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local s = math.min(1, (vp.X - 20) / 580, (vp.Y - 80) / 400)
    s = math.max(0.5, s)
    fitScale.Scale = s
    shadowFit.Scale = s
end
updateFit()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFit)
end
local GlassHighlight = create("Frame", {
    Size = UDim2.new(1, 0, 0.45, 0),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
}, MainWindow)
addCorner(GlassHighlight, 20)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 90,
}, GlassHighlight)
local Shine = create("Frame", {
    Position = UDim2.new(-0.4, 0, 0, 0),
    Size = UDim2.new(0.35, 0, 1, 0),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.97,
    BorderSizePixel = 0,
}, MainWindow)
Shine.Rotation = 12
tweenLoop(Shine, { Position = UDim2.new(1.2, 0, 0, 0) }, 5, Enum.EasingStyle.Sine)
local TitleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, MainWindow)
local function trafficLight(color, x)
    local b = create("TextButton", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, x, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundColor3 = color,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, TitleBar)
    addCorner(b, 6)
    return b
end
local closeBtn = trafficLight(COLORS.Red, 14)
local minBtn = trafficLight(COLORS.Yellow, 32)
local maxBtn = trafficLight(COLORS.Green, 50)
create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(220, 20),
    BackgroundTransparency = 1,
    Text = "Liquid Glass UI",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COLORS.Text,
}, TitleBar)
local verPill = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 84, 0.5, 0),
    Size = UDim2.fromOffset(40, 16),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.86,
    BorderSizePixel = 0,
}, TitleBar)
addCorner(verPill, 8)
create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "v4",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = COLORS.Text,
}, verPill)
local function titleAction(text, x, onClick)
    local b = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, x, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = 0.92,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, TitleBar)
    addCorner(b, 8)
    addStroke(b, 1, COLORS.Glass, 0.85)
    local bs = create("UIScale", { Scale = 1 }, b)
    b.MouseButton1Down:Connect(function() tween(bs, { Scale = 0.88 }, 0.12) end)
    b.MouseButton1Up:Connect(function() tween(bs, { Scale = 1 }, 0.2, EASE_BACK) end)
    b.MouseButton1Click:Connect(onClick)
    return b
end
local Sidebar = create("Frame", {
    Position = UDim2.fromOffset(8, 48),
    Size = UDim2.new(0, 116, 1, -56),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.95,
    BorderSizePixel = 0,
}, MainWindow)
addCorner(Sidebar, 14)
addStroke(Sidebar, 1, COLORS.Glass, 0.86)
local Logo = create("Frame", {
    Position = UDim2.fromOffset(14, 12),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, Sidebar)
addCorner(Logo, 17)
create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "◆",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = COLORS.Black,
}, Logo)
create("TextLabel", {
    Position = UDim2.fromOffset(56, 14),
    Size = UDim2.fromOffset(54, 16),
    BackgroundTransparency = 1,
    Text = "Liquid",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Sidebar)
create("TextLabel", {
    Position = UDim2.fromOffset(56, 30),
    Size = UDim2.fromOffset(54, 14),
    BackgroundTransparency = 1,
    Text = "Glass",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Sidebar)
local NavList = create("Frame", {
    Position = UDim2.fromOffset(8, 62),
    Size = UDim2.new(1, -16, 0, 132),
    BackgroundTransparency = 1,
}, Sidebar)
local navIndicator = create("Frame", {
    Position = UDim2.fromOffset(0, 2),
    Size = UDim2.new(0, 3, 0, 30),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, NavList)
addCorner(navIndicator, 2)
local NAV_ITEMS = {
    { id = "home", icon = "⌂", label = "Trang chủ" },
    { id = "features", icon = "✦", label = "Tính năng" },
    { id = "settings", icon = "⚙", label = "Cài đặt" },
}
local navButtons = {}
for i, item in ipairs(NAV_ITEMS) do
    local btn = create("TextButton", {
        Position = UDim2.fromOffset(10, (i - 1) * 38),
        Size = UDim2.new(1, -14, 0, 34),
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = i == 1 and 0.88 or 1,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, NavList)
    addCorner(btn, 10)
    create("TextLabel", {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(20, 34),
        BackgroundTransparency = 1,
        Text = item.icon,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = i == 1 and COLORS.Text or COLORS.Sub,
    }, btn)
    create("TextLabel", {
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -34, 0, 34),
        BackgroundTransparency = 1,
        Text = item.label,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = i == 1 and COLORS.Text or COLORS.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)
    navButtons[item.id] = btn
end
local UserCard = create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 8, 1, -8),
    Size = UDim2.new(1, -16, 0, 48),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
}, Sidebar)
addCorner(UserCard, 11)
addStroke(UserCard, 1, COLORS.Glass, 0.86)
local Avatar = create("Frame", {
    Position = UDim2.fromOffset(7, 7),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, UserCard)
addCorner(Avatar, 17)
create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "A",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = COLORS.Black,
}, Avatar)
create("TextLabel", {
    Position = UDim2.fromOffset(48, 7),
    Size = UDim2.new(1, -54, 0, 16),
    BackgroundTransparency = 1,
    Text = "Người dùng",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, UserCard)
local statusDot = create("Frame", {
    Position = UDim2.fromOffset(48, 27),
    Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = COLORS.Green,
    BorderSizePixel = 0,
}, UserCard)
addCorner(statusDot, 3)
create("TextLabel", {
    Position = UDim2.fromOffset(58, 24),
    Size = UDim2.new(1, -64, 0, 14),
    BackgroundTransparency = 1,
    Text = "Đang hoạt động",
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, UserCard)
local Content = create("Frame", {
    Position = UDim2.fromOffset(132, 48),
    Size = UDim2.new(1, -140, 1, -56),
    BackgroundTransparency = 1,
}, MainWindow)
local SearchBar = create("Frame", {
    Size = UDim2.new(1, -96, 0, 34),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0,
}, Content)
addCorner(SearchBar, 10)
local searchStroke = addStroke(SearchBar, 1, COLORS.Glass, 0.85)
create("TextLabel", {
    Position = UDim2.fromOffset(10, 0),
    Size = UDim2.fromOffset(18, 34),
    BackgroundTransparency = 1,
    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = COLORS.Sub,
}, SearchBar)
local SearchBox = create("TextBox", {
    Position = UDim2.fromOffset(30, 0),
    Size = UDim2.new(1, -36, 1, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "Tìm kiếm...",
    PlaceholderColor3 = COLORS.Sub,
    Text = "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
}, SearchBar)
SearchBox.Focused:Connect(function() tween(searchStroke, { Transparency = 0.4 }, 0.2) end)
SearchBox.FocusLost:Connect(function() tween(searchStroke, { Transparency = 0.85 }, 0.2) end)
local BellBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -46, 0, 0),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.93,
    Text = "◉",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COLORS.Text,
    AutoButtonColor = false,
    BorderSizePixel = 0,
}, Content)
addCorner(BellBtn, 10)
addStroke(BellBtn, 1, COLORS.Glass, 0.85)
local bellDot = create("Frame", {
    Position = UDim2.new(1, -9, 0, 6),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, BellBtn)
addCorner(bellDot, 4)
local HeaderAvatar = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, Content)
addCorner(HeaderAvatar, 17)
create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "A",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COLORS.Black,
}, HeaderAvatar)
local Pages = create("Frame", {
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    BackgroundTransparency = 1,
}, Content)
local function makePage(id, visible)
    local p = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = visible,
    }, Pages)
    p.Name = id
    return p
end
local PageHome = makePage("home", true)
local PageFeatures = makePage("features", false)
local PageSettings = makePage("settings", false)
local allPages = { home = PageHome, features = PageFeatures, settings = PageSettings }
local function makeButton(parent, text, pos, size, style, onClick)
    local btn = create("TextButton", {
        Position = pos,
        Size = size,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    addCorner(btn, 10)
    if style == "primary" then
        btn.BackgroundColor3 = COLORS.Text
        btn.TextColor3 = COLORS.Black
        addStroke(btn, 1, COLORS.Glass, 0.6)
    elseif style == "danger" then
        btn.BackgroundColor3 = COLORS.Glass
        btn.BackgroundTransparency = 0.9
        btn.TextColor3 = COLORS.Text
        addStroke(btn, 1, COLORS.Glass, 0.8)
    else
        btn.BackgroundColor3 = COLORS.Glass
        btn.BackgroundTransparency = 0.92
        btn.TextColor3 = COLORS.Text
        addStroke(btn, 1, COLORS.Glass, 0.82)
    end
    local bs = create("UIScale", { Scale = 1 }, btn)
    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundTransparency = style == "primary" and 0.15 or 0.84 }, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundTransparency = style == "primary" and 0 or (style == "danger" and 0.9 or 0.92) }, 0.2)
        tween(bs, { Scale = 1 }, 0.2, EASE_BACK)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(bs, { Scale = 0.95 }, 0.1)
        local ripple = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = style == "primary" and COLORS.Black or COLORS.Glass,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
        }, btn)
        addCorner(ripple, 999)
        tween(ripple, { Size = UDim2.fromOffset(200, 200), BackgroundTransparency = 1 }, 0.5, EASE, EASE_OUT, function() ripple:Destroy() end)
    end)
    btn.MouseButton1Up:Connect(function() tween(bs, { Scale = 1 }, 0.25, EASE_BACK) end)
    btn.MouseButton1Click:Connect(function()
        if onClick then onClick() end
    end)
    return btn
end
local function makeToggle(parent, pos, defaultState, onToggle)
    local state = defaultState or false
    local track = create("TextButton", {
        Position = pos,
        Size = UDim2.fromOffset(42, 24),
        BackgroundColor3 = state and COLORS.Text or COLORS.Gray,
        BackgroundTransparency = state and 0 or 0.3,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, parent)
    addCorner(track, 12)
    addStroke(track, 1, COLORS.Glass, 0.85)
    local knob = create("Frame", {
        Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = state and COLORS.Black or COLORS.Text,
        BorderSizePixel = 0,
    }, track)
    addCorner(knob, 9)
    local function refresh()
        tween(track, { BackgroundColor3 = state and COLORS.Text or COLORS.Gray, BackgroundTransparency = state and 0 or 0.3 }, 0.25)
        tween(knob, { Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and COLORS.Black or COLORS.Text }, 0.3, EASE_BACK)
    end
    track.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if onToggle then onToggle(state) end
    end)
    return track, function() return state end
end
local function makeSlider(parent, pos, width, defaultVal, onChange)
    local value = defaultVal or 50
    local track = create("Frame", {
        Position = pos,
        Size = UDim2.fromOffset(width, 6),
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
    }, parent)
    addCorner(track, 3)
    addStroke(track, 1, COLORS.Glass, 0.86)
    local fill = create("Frame", {
        Size = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
    }, track)
    addCorner(fill, 3)
    local knob = create("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(value / 100, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = COLORS.Text,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, track)
    addCorner(knob, 8)
    addStroke(knob, 1, COLORS.Black, 0.4)
    local dragging = false
    local function updateFromX(absX)
        local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(rel * 100)
        tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.08)
        tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.08)
        if onChange then onChange(value) end
    end
    knob.MouseButton1Down:Connect(function() dragging = true end)
    track.MouseButton1Down:Connect(function(input)
        dragging = true
        updateFromX(input.Position.X)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    return track, function() return value end
end
local lagState = { applied = false, saved = {} }
local function applyFixLag(on)
    local Lighting = game:GetService("Lighting")
    if on and not lagState.applied then
        lagState.saved = {}
        pcall(function() lagState.saved.GlobalShadows = Lighting.GlobalShadows end)
        pcall(function() lagState.saved.Brightness = Lighting.Brightness end)
        pcall(function() lagState.saved.FogStart = Lighting.FogStart end)
        pcall(function() lagState.saved.FogEnd = Lighting.FogEnd end)
        pcall(function() lagState.saved.Diffuse = Lighting.EnvironmentDiffuseScale end)
        pcall(function() lagState.saved.Specular = Lighting.EnvironmentSpecularScale end)
        pcall(function() lagState.saved.Softness = Lighting.ShadowSoftness end)
        pcall(function() lagState.saved.Tech = Lighting.Technology end)
        lagState.saved.PostFX = {}
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                table.insert(lagState.saved.PostFX, { obj = v, enabled = v.Enabled })
                pcall(function() v.Enabled = false end)
            end
        end
        lagState.saved.Particles = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                if v.Enabled ~= nil then
                    table.insert(lagState.saved.Particles, { obj = v, enabled = v.Enabled })
                    pcall(function() v.Enabled = false end)
                end
            end
        end
        pcall(function() Lighting.GlobalShadows = false end)
        pcall(function() Lighting.Brightness = 1 end)
        pcall(function() Lighting.FogStart = 100000 end)
        pcall(function() Lighting.FogEnd = 100000 end)
        pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
        pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
        pcall(function() Lighting.ShadowSoftness = 0 end)
        pcall(function() Lighting.Technology = Enum.Technology.Voxel end)
        pcall(function() settings().GraphicsQuality = Enum.GraphicsQuality.Level01 end)
        pcall(function() settings().GraphicsMode = Enum.GraphicsMode.Manual end)
        pcall(function() collectgarbage("collect") end)
        lagState.applied = true
    elseif not on and lagState.applied then
        pcall(function() Lighting.GlobalShadows = lagState.saved.GlobalShadows end)
        pcall(function() Lighting.Brightness = lagState.saved.Brightness end)
        pcall(function() Lighting.FogStart = lagState.saved.FogStart end)
        pcall(function() Lighting.FogEnd = lagState.saved.FogEnd end)
        pcall(function() Lighting.EnvironmentDiffuseScale = lagState.saved.Diffuse end)
        pcall(function() Lighting.EnvironmentSpecularScale = lagState.saved.Specular end)
        pcall(function() Lighting.ShadowSoftness = lagState.saved.Softness end)
        pcall(function() Lighting.Technology = lagState.saved.Tech end)
        for _, r in ipairs(lagState.saved.PostFX or {}) do
            pcall(function() r.obj.Enabled = r.enabled end)
        end
        for _, r in ipairs(lagState.saved.Particles or {}) do
            pcall(function() r.obj.Enabled = r.enabled end)
        end
        lagState.applied = false
    end
end
local function makeFeatureCard(parent, pos, icon, title, desc, withToggle, realCallback)
    local card = create("Frame", {
        Position = pos,
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
    }, parent)
    addCorner(card, 12)
    local cardStroke = addStroke(card, 1, COLORS.Glass, 0.86)
    local origPos = pos
    card.MouseEnter:Connect(function()
        tween(cardStroke, { Transparency = 0.55 }, 0.2)
        tween(card, { Position = origPos + UDim2.fromOffset(0, -2) }, 0.2)
    end)
    card.MouseLeave:Connect(function()
        tween(cardStroke, { Transparency = 0.86 }, 0.2)
        tween(card, { Position = origPos }, 0.2)
    end)
    local iconBox = create("Frame", {
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
    }, card)
    addCorner(iconBox, 11)
    create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = COLORS.Black,
    }, iconBox)
    create("TextLabel", {
        Position = UDim2.fromOffset(58, 9),
        Size = UDim2.new(1, -120, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    create("TextLabel", {
        Position = UDim2.fromOffset(58, 29),
        Size = UDim2.new(1, -120, 0, 18),
        BackgroundTransparency = 1,
        Text = desc,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = COLORS.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    if withToggle then
        makeToggle(card, UDim2.new(1, -52, 0.5, 0), false, function(on)
            if realCallback then
                realCallback(on)
            else
                showToast(title, on and "Đã bật (demo)" or "Đã tắt (demo)")
                islandExpand(title, on and "Trạng thái: BẬT" or "Trạng thái: TẮT")
                task.delay(1.8, function() if islandExpanded then islandCollapse() end end)
            end
        end)
    end
    return card
end
local function makeStatCard(parent, pos, label, value, icon)
    local card = create("Frame", {
        Position = pos,
        Size = UDim2.new(0.32, 0, 0, 70),
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
    }, parent)
    addCorner(card, 12)
    addStroke(card, 1, COLORS.Glass, 0.86)
    create("TextLabel", {
        Position = UDim2.fromOffset(10, 7),
        Size = UDim2.new(1, -20, 0, 14),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. label,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = COLORS.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local valLabel = create("TextLabel", {
        Position = UDim2.fromOffset(10, 23),
        Size = UDim2.new(1, -20, 0, 28),
        BackgroundTransparency = 1,
        Text = "0",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    return valLabel
end
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1,
    Text = "Xin chào!",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageHome)
create("TextLabel", {
    Position = UDim2.fromOffset(0, 26),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = "Liquid Glass UI — popup tối giản, chỉ để ngắm.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageHome)
local fpsLabel = makeStatCard(PageHome, UDim2.fromOffset(0, 50), "FPS", "60", "⚡")
local pingLabel = makeStatCard(PageHome, UDim2.new(0.34, 0, 0, 50), "Ping", "24ms", "◎")
local playerLabel = makeStatCard(PageHome, UDim2.new(0.68, 0, 0, 50), "Người chơi", "1", "●")
local function countUp(label, target, suffix)
    task.spawn(function()
        local cur = 0
        while cur < target do
            cur = math.min(target, cur + math.ceil(target / 25))
            label.Text = tostring(cur) .. (suffix or "")
            task.wait(0.03)
        end
    end)
end
countUp(fpsLabel, 60)
countUp(pingLabel, 24, "ms")
countUp(playerLabel, 1)
local ProgressCard = create("Frame", {
    Position = UDim2.fromOffset(0, 130),
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
}, PageHome)
addCorner(ProgressCard, 12)
addStroke(ProgressCard, 1, COLORS.Glass, 0.86)
create("TextLabel", {
    Position = UDim2.fromOffset(12, 9),
    Size = UDim2.new(1, -24, 0, 16),
    BackgroundTransparency = 1,
    Text = "Đang tải giao diện...",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ProgressCard)
local progressTrack = create("Frame", {
    Position = UDim2.fromOffset(12, 32),
    Size = UDim2.new(1, -24, 0, 8),
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
}, ProgressCard)
addCorner(progressTrack, 4)
local progressFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
}, progressTrack)
addCorner(progressFill, 4)
local progressPct = create("TextLabel", {
    Position = UDim2.fromOffset(12, 46),
    Size = UDim2.new(1, -24, 0, 16),
    BackgroundTransparency = 1,
    Text = "0%",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Right,
}, ProgressCard)
task.spawn(function()
    while ScreenGui.Parent do
        for i = 0, 100, 2 do
            if not ScreenGui.Parent then break end
            tween(progressFill, { Size = UDim2.new(i / 100, 0, 1, 0) }, 0.12)
            progressPct.Text = i .. "%"
            task.wait(0.06)
        end
        task.wait(0.6)
    end
end)
makeButton(PageHome, "Bắt đầu", UDim2.fromOffset(0, 218), UDim2.new(0.32, 0, 0, 36), "primary", function()
    showToast("Chào bạn!", "UI demo — không có chức năng thật")
    islandExpand("Bắt đầu", "Cảm ơn bạn đã dùng Liquid Glass")
    task.delay(2, function() if islandExpanded then islandCollapse() end end)
end)
makeButton(PageHome, "Xem thêm", UDim2.new(0.34, 0, 0, 218), UDim2.new(0.32, 0, 0, 36), "glass", function()
    switchPage("features")
end)
makeButton(PageHome, "Cài đặt", UDim2.new(0.68, 0, 0, 218), UDim2.new(0.32, 0, 0, 36), "glass", function()
    switchPage("settings")
end)
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1,
    Text = "Tính năng",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageFeatures)
create("TextLabel", {
    Position = UDim2.fromOffset(0, 26),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = "1 chức năng thật duy nhất: Super Fix Lag. Còn lại chỉ là demo.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = COLORS.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageFeatures)
makeFeatureCard(PageFeatures, UDim2.fromOffset(0, 50), "⚡", "Super Fix Lag", "Chức năng thật — tăng FPS, tắt shadow/FX", true, function(on)
    applyFixLag(on)
    if on then
        showToast("Super Fix Lag", "Đã bật — FPS sẽ tăng rõ rệt")
        islandExpand("Super Fix Lag: BẬT", "Đang tối ưu đồ họa...")
    else
        showToast("Super Fix Lag", "Đã tắt — khôi phục đồ họa")
        islandExpand("Super Fix Lag: TẮT", "Đã khôi phục cài đặt gốc")
    end
    task.delay(2.2, function() if islandExpanded then islandCollapse() end end)
end)
makeFeatureCard(PageFeatures, UDim2.fromOffset(0, 116), "✦", "Hiệu ứng đẹp", "Demo toggle", true)
makeFeatureCard(PageFeatures, UDim2.fromOffset(0, 182), "◎", "Tối ưu", "Demo toggle", true)
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1,
    Text = "Cài đặt",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageSettings)
local function settingRow(parent, y, label, desc, defaultState)
    create("TextLabel", {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, -54, 0, 18),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    create("TextLabel", {
        Position = UDim2.fromOffset(0, y + 18),
        Size = UDim2.new(1, -54, 0, 14),
        BackgroundTransparency = 1,
        Text = desc,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = COLORS.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    makeToggle(parent, UDim2.new(1, -42, 0, y + 4), defaultState, function(on)
        showToast(label, on and "Đã bật (demo)" or "Đã tắt (demo)")
    end)
end
settingRow(PageSettings, 38, "Hiệu ứng chuyển động", "Bật/tắt animation", true)
settingRow(PageSettings, 82, "Âm thanh giao diện", "Tiếng click khi nhấn", false)
settingRow(PageSettings, 126, "Tự động lưu", "Lưu cài đặt tự động", true)
create("TextLabel", {
    Position = UDim2.fromOffset(0, 170),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = "Độ sáng UI",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageSettings)
local brightnessVal = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 170),
    Size = UDim2.fromOffset(44, 16),
    BackgroundTransparency = 1,
    Text = "80%",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Right,
}, PageSettings)
makeSlider(PageSettings, UDim2.fromOffset(0, 192), 400, 80, function(v)
    brightnessVal.Text = v .. "%"
end)
create("TextLabel", {
    Position = UDim2.fromOffset(0, 220),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = "Âm lượng",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, PageSettings)
local volumeVal = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 220),
    Size = UDim2.fromOffset(44, 16),
    BackgroundTransparency = 1,
    Text = "50%",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Right,
}, PageSettings)
makeSlider(PageSettings, UDim2.fromOffset(0, 242), 400, 50, function(v)
    volumeVal.Text = v .. "%"
end)
makeButton(PageSettings, "Áp dụng", UDim2.fromOffset(0, 274), UDim2.new(0.48, 0, 0, 36), "primary", function()
    showToast("Thành công!", "Đã áp dụng cài đặt (demo)")
end)
makeButton(PageSettings, "Đặt lại", UDim2.new(0.52, 0, 0, 274), UDim2.new(0.48, 0, 0, 36), "glass", function()
    showToast("Đã đặt lại", "Trở về mặc định (demo)")
end)
local ToastContainer = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -14),
    Size = UDim2.fromOffset(260, 180),
    BackgroundTransparency = 1,
}, ScreenGui)
function showToast(title, msg)
    local toast = create("Frame", {
        Position = UDim2.new(1, 280, 0, 0),
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = COLORS.Dark,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
    }, ToastContainer)
    addCorner(toast, 12)
    addStroke(toast, 1, COLORS.Glass, 0.8)
    local dot = create("Frame", {
        Position = UDim2.fromOffset(11, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
    }, toast)
    addCorner(dot, 4)
    create("TextLabel", {
        Position = UDim2.fromOffset(28, 7),
        Size = UDim2.new(1, -36, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toast)
    create("TextLabel", {
        Position = UDim2.fromOffset(28, 27),
        Size = UDim2.new(1, -36, 0, 20),
        BackgroundTransparency = 1,
        Text = msg,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = COLORS.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, toast)
    tween(toast, { Position = UDim2.new(1, 0, 0, 0) }, 0.45, EASE_BACK)
    task.delay(3.2, function()
        if toast.Parent then
            tween(toast, { Position = UDim2.new(1, 280, 0, 0) }, 0.35, EASE, EASE_OUT, function()
                toast:Destroy()
            end)
        end
    end)
end
local currentPage = "home"
function switchPage(id)
    if currentPage == id then return end
    currentPage = id
    for pid, page in pairs(allPages) do
        page.Visible = (pid == id)
        if pid == id then
            page.Position = UDim2.fromOffset(20, 0)
            tween(page, { Position = UDim2.fromOffset(0, 0) }, 0.3, EASE)
        end
    end
    local idx = 1
    for _, item in ipairs(NAV_ITEMS) do
        local btn = navButtons[item.id]
        local active = (item.id == id)
        for _, child in ipairs(btn:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = active and COLORS.Text or COLORS.Sub
            end
        end
        tween(btn, { BackgroundTransparency = active and 0.88 or 1 }, 0.25)
        if active then
            tween(navIndicator, { Position = UDim2.fromOffset(0, (idx - 1) * 38 + 2) }, 0.3, EASE_BACK)
        end
        idx = idx + 1
    end
end
for _, item in ipairs(NAV_ITEMS) do
    navButtons[item.id].MouseButton1Click:Connect(function()
        switchPage(item.id)
    end)
end
BellBtn.MouseButton1Click:Connect(function()
    bellDot.Visible = false
    showToast("Thông báo", "Bạn có 1 thông báo mới (demo)")
    islandExpand("Thông báo", "Bạn có 1 thông báo mới")
    task.delay(2, function() if islandExpanded then islandCollapse() end end)
end)
Island.MouseButton1Click:Connect(function()
    islandAuto = false
    if not MainWindow.Visible then
        restoreWindow()
        islandExpand("Đã mở lại UI", "Chào mừng bạn quay lại")
        task.delay(2.2, function() if islandExpanded then islandCollapse() end end)
    elseif islandExpanded then
        islandCollapse()
    else
        islandExpand("Liquid Glass", "Nhấn để thu gọn")
    end
end)
task.spawn(function()
    while ScreenGui.Parent do
        local t = os.date("%H:%M")
        if not islandExpanded then islandTitle.Text = t end
        task.wait(1)
    end
end)
local islandMessages = {
    { "Xin chào!", "UI đã sẵn sàng" },
    { "Liquid Glass", "Popup tối giản, mượt mà" },
    { "Dynamic Island", "Nhấn vào tôi để mở rộng" },
    { "Delta X VNG", "Chạy local trong Place của bạn" },
}
task.spawn(function()
    local idx = 1
    while ScreenGui.Parent do
        task.wait(7)
        if islandAuto and MainWindow.Visible and not islandExpanded then
            local m = islandMessages[idx]
            islandExpand(m[1], m[2])
            task.wait(3)
            if islandAuto and islandExpanded then islandCollapse() end
            idx = idx % #islandMessages + 1
        end
    end
end)
local draggingWindow = false
local dragStart = Vector2.new()
local startPos = UDim2.new()
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPos = MainWindow.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Shadow.Position = MainWindow.Position + UDim2.fromOffset(0, 8)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)
local windowOpen = true
local ToggleBtn = nil
local toggleLabel = nil
local toggleStroke = nil
local function refreshToggleBtn()
    if not toggleLabel then return end
    if windowOpen then
        tween(toggleLabel, { TextTransparency = 0 }, 0.25)
        if toggleStroke then tween(toggleStroke, { Transparency = 0.65 }, 0.25) end
    else
        tween(toggleLabel, { TextTransparency = 0.45 }, 0.25)
        if toggleStroke then tween(toggleStroke, { Transparency = 0.35 }, 0.25) end
    end
end
function restoreWindow()
    if windowOpen then return end
    windowOpen = true
    MainWindow.Visible = true
    Shadow.Visible = true
    tween(animScale, { Scale = 1 }, 0.45, EASE_BACK)
    tween(Shadow, { BackgroundTransparency = 0.5 }, 0.35)
    refreshToggleBtn()
end
local function hideWindow(msgTitle, msgSub)
    windowOpen = false
    tween(animScale, { Scale = 0 }, 0.35, EASE, EASE_OUT, function()
        MainWindow.Visible = false
        Shadow.Visible = false
    end)
    tween(Shadow, { BackgroundTransparency = 1 }, 0.35)
    islandExpand(msgTitle, msgSub)
    refreshToggleBtn()
end
titleAction("—", -46, function()
    hideWindow("Đã thu nhỏ", "Nhấn vào Island hoặc nút nguồn để mở lại")
end)
titleAction("✕", -14, function()
    hideWindow("Tạm đóng UI", "Nhấn nút nguồn để bật lại")
end)
closeBtn.MouseButton1Click:Connect(function()
    hideWindow("Tạm đóng UI", "Nhấn nút nguồn để bật lại nhé")
end)
minBtn.MouseButton1Click:Connect(function()
    hideWindow("Đã thu nhỏ", "Nhấn nút nguồn để mở lại UI")
end)
maxBtn.MouseButton1Click:Connect(function()
    tween(animScale, { Scale = 1.05 }, 0.22, EASE_BACK, EASE_OUT, function()
        tween(animScale, { Scale = 1 }, 0.22, EASE)
    end)
    showToast("Phóng to", "Hiệu ứng nảy nhẹ (demo)")
end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if MainWindow.Visible then
            hideWindow("Đã ẩn UI", "Nhấn RightShift hoặc nút nguồn để hiện lại")
        else
            restoreWindow()
            islandExpand("Xin chào!", "UI đã quay trở lại")
            task.delay(2, function() if islandExpanded then islandCollapse() end end)
        end
    end
end)
ToggleBtn = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.fromOffset(56, 56),
    BackgroundColor3 = COLORS.Black,
    BorderSizePixel = 0,
}, ScreenGui)
addCorner(ToggleBtn, 28)
toggleStroke = addStroke(ToggleBtn, 1.5, COLORS.Glass, 0.65)
local toggleScale = create("UIScale", { Scale = 1 }, ToggleBtn)
toggleLabel = create("TextLabel", {
    Position = UDim2.fromOffset(0, -4),
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    Text = "⏻",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = COLORS.Text,
}, ToggleBtn)
create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -7),
    Size = UDim2.fromOffset(40, 12),
    BackgroundTransparency = 1,
    Text = "ON / OFF",
    Font = Enum.Font.GothamBold,
    TextSize = 7,
    TextColor3 = COLORS.Sub,
}, ToggleBtn)
local tDragging = false
local tDragStart = Vector2.new()
local tStartPos = UDim2.new()
local tMoved = 0
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true
        tDragStart = input.Position
        tStartPos = ToggleBtn.Position
        tMoved = 0
        tween(toggleScale, { Scale = 0.9 }, 0.12)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tDragStart
        tMoved = math.max(tMoved, math.abs(delta.X) + math.abs(delta.Y))
        ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if tDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        tDragging = false
        tween(toggleScale, { Scale = 1 }, 0.25, EASE_BACK)
        if tMoved < 8 then
            if MainWindow.Visible then
                hideWindow("Đã tắt UI", "Nhấn nút nguồn để bật lại")
            else
                restoreWindow()
                islandExpand("Đã bật UI", "Chào mừng bạn quay lại")
                task.delay(2, function() if islandExpanded then islandCollapse() end end)
            end
        end
    end
end)
local frames = 0
local lastTime = tick()
local lastFps = 60
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.floor(frames / (now - lastTime))
        frames = 0
        lastTime = now
        lastFps = fps
        islandFps.Text = tostring(fps) .. " FPS"
        if currentPage == "home" then
            fpsLabel.Text = tostring(fps)
        end
    end
end)
task.spawn(function()
    tween(islandScale, { Scale = 1 }, 0.6, EASE_ELASTIC)
    islandExpand("Đang khởi tạo...", "Liquid Glass UI đang tải")
    task.wait(1)
    tween(animScale, { Scale = 1 }, 0.6, EASE_BACK)
    tween(toggleScale, { Scale = 1 }, 0.6, EASE_BACK)
    task.wait(0.4)
    islandExpand("Chào mừng!", "Kéo nút nguồn để di chuyển, nhấn để bật/tắt")
    task.wait(2.2)
    islandCollapse()
    task.wait(0.4)
    showToast("Xin chào!", "Chào mừng đến với Liquid Glass UI v4")
end)
print("Liquid Glass UI v4 loaded - Super Fix Lag ready")
