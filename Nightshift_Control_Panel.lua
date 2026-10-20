-- NIGHTSHIFT | Roblox Local Control Panel
-- Safe client-side starter for Roblox / Delta-style Lua environments.
-- This file intentionally contains local UI/preferences and informational tools only.
-- It does not include exploit APIs, player targeting, grabbing, or server bypasses.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[NIGHTSHIFT] Run this as a client-side LocalScript.")
    return
end

local COLORS = {
    background = Color3.fromRGB(13, 15, 20),
    panel = Color3.fromRGB(20, 23, 30),
    card = Color3.fromRGB(27, 30, 39),
    cardHover = Color3.fromRGB(35, 39, 50),
    line = Color3.fromRGB(48, 53, 66),
    text = Color3.fromRGB(239, 242, 250),
    muted = Color3.fromRGB(145, 153, 171),
    accent = Color3.fromRGB(95, 130, 255),
    accent2 = Color3.fromRGB(145, 100, 255),
    green = Color3.fromRGB(93, 220, 163),
    red = Color3.fromRGB(255, 100, 119),
}

local old = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if old and old:FindFirstChild("NightshiftPanel") then
    old.NightshiftPanel:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "NightshiftPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.line
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function label(parent, text, size, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextColor3 = color or COLORS.text
    l.TextSize = size or 14
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, text, height)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = text
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.TextColor3 = COLORS.text
    b.BackgroundColor3 = COLORS.card
    b.Size = UDim2.new(1, 0, 0, height or 38)
    b.Parent = parent
    corner(b, 10)
    stroke(b, COLORS.line, 1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.cardHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.card}):Play()
    end)
    return b
end

local root = Instance.new("Frame")
root.Name = "Window"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.88, 0, 0.78, 0)
root.BackgroundColor3 = COLORS.background
root.Parent = gui
corner(root, 18)
stroke(root, Color3.fromRGB(72, 82, 115), 1.2, 0.15)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 360)
sizeConstraint.MaxSize = Vector2.new(760, 650)
sizeConstraint.Parent = root

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 66)
header.BackgroundColor3 = COLORS.panel
header.Parent = root
corner(header, 18)

local headerMask = Instance.new("Frame")
headerMask.Position = UDim2.new(0, 0, 1, -16)
headerMask.Size = UDim2.new(1, 0, 0, 16)
headerMask.BackgroundColor3 = COLORS.panel
headerMask.BorderSizePixel = 0
headerMask.Parent = header

local logo = Instance.new("Frame")
logo.Position = UDim2.new(0, 16, 0, 15)
logo.Size = UDim2.new(0, 36, 0, 36)
logo.BackgroundColor3 = COLORS.accent
logo.Parent = header
corner(logo, 11)
local logoText = label(logo, "N", 20, Color3.new(1,1,1), Enum.Font.GothamBlack)
logoText.Size = UDim2.fromScale(1,1)
logoText.TextXAlignment = Enum.TextXAlignment.Center

local title = label(header, "NIGHTSHIFT", 16, COLORS.text, Enum.Font.GothamBold)
title.Position = UDim2.new(0, 62, 0, 12)
title.Size = UDim2.new(0, 180, 0, 22)
local subtitle = label(header, "CLIENT CONTROL  /  LOCAL TOOLS", 9, COLORS.muted)
subtitle.Position = UDim2.new(0, 63, 0, 35)
subtitle.Size = UDim2.new(0, 230, 0, 15)

local fpsLabel = label(header, "● CLIENT READY", 10, COLORS.green, Enum.Font.GothamMedium)
fpsLabel.AnchorPoint = Vector2.new(1, 0.5)
fpsLabel.Position = UDim2.new(1, -54, 0.5, 0)
fpsLabel.Size = UDim2.new(0, 110, 0, 20)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right

local close = button(header, "×", 34)
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -43, 0, 16)
close.BackgroundColor3 = Color3.fromRGB(42, 31, 40)
close.TextSize = 20
close.Activated:Connect(function() gui:Destroy() end)

-- Drag support for mouse and touch.
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 12, 0, 78)
sidebar.Size = UDim2.new(0, 132, 1, -90)
sidebar.BackgroundColor3 = COLORS.panel
sidebar.Parent = root
corner(sidebar, 14)

local navTitle = label(sidebar, "WORKSPACE", 9, COLORS.muted, Enum.Font.GothamBold)
navTitle.Position = UDim2.new(0, 14, 0, 12)
navTitle.Size = UDim2.new(1, -24, 0, 18)

local navList = Instance.new("Frame")
navList.Position = UDim2.new(0, 8, 0, 38)
navList.Size = UDim2.new(1, -16, 1, -46)
navList.BackgroundTransparency = 1
navList.Parent = sidebar
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 7)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navList

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 154, 0, 78)
content.Size = UDim2.new(1, -166, 1, -90)
content.BackgroundColor3 = COLORS.panel
content.Parent = root
corner(content, 14)

local pageTitle = label(content, "Overview", 21, COLORS.text, Enum.Font.GothamBold)
pageTitle.Position = UDim2.new(0, 20, 0, 15)
pageTitle.Size = UDim2.new(1, -40, 0, 30)
local pageSubtitle = label(content, "A compact collection of local client preferences.", 11, COLORS.muted)
pageSubtitle.Position = UDim2.new(0, 21, 0, 45)
pageSubtitle.Size = UDim2.new(1, -40, 0, 20)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 14, 0, 76)
scroll.Size = UDim2.new(1, -28, 1, -90)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.accent
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = content
local stack = Instance.new("UIListLayout")
stack.Padding = UDim.new(0, 9)
stack.SortOrder = Enum.SortOrder.LayoutOrder
stack.Parent = scroll
stack:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, stack.AbsoluteContentSize.Y + 8)
end)

local pages = {}
local currentPage = "Overview"
local originalFov = 70
local brightnessEffect
local savedLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
}
local connections = {}

local function clearCards()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child ~= stack then child:Destroy() end
    end
end

local function card(titleText, descriptionText, height)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -2, 0, height or 72)
    frame.BackgroundColor3 = COLORS.card
    frame.Parent = scroll
    corner(frame, 12)
    stroke(frame, COLORS.line, 1)
    local t = label(frame, titleText, 13, COLORS.text, Enum.Font.GothamMedium)
    t.Position = UDim2.new(0, 14, 0, 10)
    t.Size = UDim2.new(1, -28, 0, 20)
    if descriptionText then
        local d = label(frame, descriptionText, 10, COLORS.muted)
        d.Position = UDim2.new(0, 14, 0, 33)
        d.Size = UDim2.new(1, -28, 0, 20)
        d.TextWrapped = true
    end
    return frame
end

local function addAction(titleText, desc, actionText, callback)
    local f = card(titleText, desc, 76)
    local b = button(f, actionText or "RUN", 30)
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -10, 0.5, 8)
    b.Size = UDim2.new(0, 82, 0, 30)
    b.Activated:Connect(callback)
    return f
end

local function addToggle(titleText, desc, initial, callback)
    local value = initial
    local f = card(titleText, desc, 76)
    local b = button(f, value and "ON" or "OFF", 30)
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -10, 0.5, 8)
    b.Size = UDim2.new(0, 68, 0, 30)
    local function paint()
        b.Text = value and "ON" or "OFF"
        b.BackgroundColor3 = value and Color3.fromRGB(42, 72, 68) or COLORS.cardHover
        b.TextColor3 = value and COLORS.green or COLORS.muted
    end
    paint()
    b.Activated:Connect(function()
        value = not value
        paint()
        callback(value)
    end)
    return f
end

local function addSlider(titleText, desc, minV, maxV, initial, callback)
    local f = card(titleText, desc, 94)
    local valueLabel = label(f, tostring(initial), 11, COLORS.accent)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -14, 0, 11)
    valueLabel.Size = UDim2.new(0, 55, 0, 18)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame")
    bar.Position = UDim2.new(0, 14, 0, 61)
    bar.Size = UDim2.new(1, -28, 0, 6)
    bar.BackgroundColor3 = COLORS.line
    bar.Parent = f
    corner(bar, 4)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.Parent = bar
    corner(fill, 4)
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial-minV)/(maxV-minV), 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = COLORS.text
    knob.Parent = bar
    corner(knob, 7)
    local hit = Instance.new("TextButton")
    hit.Text = ""
    hit.BackgroundTransparency = 1
    hit.Position = UDim2.new(0, 0, 0, -10)
    hit.Size = UDim2.new(1, 0, 0, 26)
    hit.Parent = bar
    local function setFromX(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X,1), 0, 1)
        local value = math.floor(minV + ratio*(maxV-minV) + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)
    return f
end

local function showOverview()
    clearCards()
    addAction("Local player status", "Show your current character and health.", "CHECK", function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local msg = hum and string.format("Health: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth)) or "Character is not loaded."
        pageSubtitle.Text = msg
    end)
    addAction("Reset camera FOV", "Restore the standard local camera field of view.", "RESET", function()
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = originalFov end
        pageSubtitle.Text = "Camera FOV restored to 70."
    end)
    addAction("Refresh player list", "Show player names and display names for information.", "REFRESH", function()
        currentPage = "Players"
        pageTitle.Text = "Players"
        pageSubtitle.Text = "Information only — no player manipulation."
        pages.Players()
    end)
    addAction("Restore lighting", "Return lighting values to what they were when the panel opened.", "RESTORE", function()
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
        pageSubtitle.Text = "Lighting restored."
    end)
end

local function showLocalPlayer()
    clearCards()
    addSlider("Camera field of view", "Local camera only; typical range is 50–100.", 50, 100, 70, function(v)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = v end
    end)
    addToggle("Extra brightness", "Adjust local scene brightness.", false, function(on)
        Lighting.Brightness = on and math.max(savedLighting.Brightness, 3) or savedLighting.Brightness
    end)
    addSlider("Time of day", "Local lighting preference; does not change server time.", 0, 24, math.floor(savedLighting.ClockTime), function(v)
        Lighting.ClockTime = v
    end)
    addAction("Reset camera FOV", "Set the camera field of view back to 70.", "RESET", function()
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = originalFov end
    end)
end

local function showVisuals()
    clearCards()
    addToggle("Extra brightness", "Increase local lighting brightness.", false, function(on)
        Lighting.Brightness = on and math.max(savedLighting.Brightness, 3) or savedLighting.Brightness
    end)
    addSlider("Fog distance", "Change local fog distance where the experience permits it.", 100, 100000, math.clamp(math.floor(savedLighting.FogEnd),100,100000), function(v)
        Lighting.FogEnd = v
    end)
    addSlider("Clock time", "Set a local lighting time preference.", 0, 24, math.floor(savedLighting.ClockTime), function(v)
        Lighting.ClockTime = v
    end)
    addAction("Restore visual defaults", "Restore captured lighting settings.", "RESTORE", function()
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
    end)
end

local function showProtection()
    clearCards()
    addAction("Check character availability", "Reports whether your own character and Humanoid are loaded.", "CHECK", function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        pageSubtitle.Text = hum and "Character ready." or "Character not loaded."
    end)
    addAction("Recheck character", "Wait for your own character to be available.", "CHECK", function()
        LocalPlayer.CharacterAdded:Wait()
        pageSubtitle.Text = "Your character has loaded."
    end)
    addToggle("Show status in header", "Display a small local ready indicator.", true, function(on)
        fpsLabel.Visible = on
    end)
end

local function showPlayers()
    clearCards()
    local list = Players:GetPlayers()
    table.sort(list, function(a,b) return a.Name:lower() < b.Name:lower() end)
    for _, p in ipairs(list) do
        local status = p == LocalPlayer and "You • local player" or ("Display name: " .. p.DisplayName)
        card(p.Name, status, 58)
    end
    addAction("Refresh player list", "Update names after players join or leave.", "REFRESH", function()
        showPlayers()
    end)
end

local function showGrabs()
    clearCards()
    card("No grab actions included", "This section is reserved for legitimate actions in your own Roblox experience. It does not manipulate other players.", 86)
    addAction("Explain limitation", "Client scripts cannot grant server-side permissions.", "INFO", function()
        pageSubtitle.Text = "Server-authoritative actions must be implemented by the experience owner."
    end)
end

local function showServer()
    clearCards()
    addAction("Show server information", "Display basic client-visible session information.", "CHECK", function()
        pageSubtitle.Text = "PlaceId: " .. tostring(game.PlaceId) .. " • JobId: " .. tostring(game.JobId)
    end)
    addAction("Show player count", "Current number of players visible to this client.", "COUNT", function()
        pageSubtitle.Text = "Players in session: " .. tostring(#Players:GetPlayers())
    end)
    card("Server permissions", "This client panel cannot grant admin rights or bypass server checks.", 70)
end

local function showMisc()
    clearCards()
    addAction("Copy username to output", "Print your username in the client output.", "PRINT", function()
        print("[NIGHTSHIFT] Username: " .. LocalPlayer.Name)
        pageSubtitle.Text = "Username printed to client output."
    end)
    addAction("Recenter panel", "Move the panel back to the center of the screen.", "CENTER", function()
        root.Position = UDim2.fromScale(0.5, 0.5)
    end)
    addAction("Close panel", "Close this local interface.", "CLOSE", function()
        gui:Destroy()
    end)
end

pages = {
    ["Overview"] = showOverview,
    ["Local Player"] = showLocalPlayer,
    ["Visuals"] = showVisuals,
    ["Protection"] = showProtection,
    ["Players"] = showPlayers,
    ["Grabs"] = showGrabs,
    ["Server"] = showServer,
    ["Misc"] = showMisc,
}

local navButtons = {}
local navNames = {"Overview", "Local Player", "Visuals", "Protection", "Players", "Grabs", "Server", "Misc"}

local function navigate(name)
    currentPage = name
    pageTitle.Text = name
    pageSubtitle.Text = ({
        ["Overview"] = "A compact collection of local client preferences.",
        ["Local Player"] = "Camera and local character information.",
        ["Visuals"] = "Client-side lighting preferences.",
        ["Protection"] = "Character availability and local status tools.",
        ["Players"] = "Player list for information only.",
        ["Grabs"] = "Safe placeholder for experience-owned actions.",
        ["Server"] = "Basic session information visible to the client.",
        ["Misc"] = "Small interface utilities.",
    })[name] or ""
    for n, b in pairs(navButtons) do
        b.BackgroundColor3 = n == name and COLORS.accent or COLORS.card
        b.TextColor3 = n == name and Color3.new(1,1,1) or COLORS.muted
    end
    pages[name]()
end

for i, name in ipairs(navNames) do
    local b = button(navList, name, 35)
    b.LayoutOrder = i
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 11
    b.TextColor3 = COLORS.muted
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = b
    navButtons[name] = b
    b.Activated:Connect(function() navigate(name) end)
end

-- Keep UI comfortable on smaller phone screens.
local function adaptForViewport()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if viewport.X < 520 then
        root.Size = UDim2.new(0.96, 0, 0.84, 0)
        sidebar.Size = UDim2.new(0, 105, 1, -90)
        content.Position = UDim2.new(0, 123, 0, 78)
        content.Size = UDim2.new(1, -135, 1, -90)
        navTitle.TextSize = 8
        for _, b in pairs(navButtons) do b.TextSize = 10 end
    else
        root.Size = UDim2.new(0.88, 0, 0.78, 0)
        sidebar.Size = UDim2.new(0, 132, 1, -90)
        content.Position = UDim2.new(0, 154, 0, 78)
        content.Size = UDim2.new(1, -166, 1, -90)
        navTitle.TextSize = 9
        for _, b in pairs(navButtons) do b.TextSize = 11 end
    end
end

if workspace.CurrentCamera then
    table.insert(connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptForViewport))
end
table.insert(connections, Players.PlayerAdded:Connect(function()
    if currentPage == "Players" then showPlayers() end
end))
table.insert(connections, Players.PlayerRemoving:Connect(function()
    if currentPage == "Players" then task.defer(showPlayers) end
end))

gui.Destroying:Connect(function()
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    pcall(function()
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
    end)
end)

adaptForViewport()
navigate("Overview")
print("[NIGHTSHIFT] Loaded successfully.")
