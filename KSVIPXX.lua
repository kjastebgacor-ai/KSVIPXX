-- K.S VIP XX | COMPACT EDITION 2 PAGE

local P = game:GetService("Players")
local L = game:GetService("Lighting")
local W = workspace
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")

local p = P.LocalPlayer
if not p then return end

local g = p:WaitForChild("PlayerGui")

for _, n in ipairs({"KSVIPXXGlobal", "KSVIPXXToggle"}) do
    local o = g:FindFirstChild(n)
    if o then o:Destroy() end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KSVIPXXGlobal"
gui.ResetOnSpawn = false
gui.Parent = g

local m = Instance.new("Frame")
m.Size = UDim2.fromOffset(280, 370)
m.Position = UDim2.new(0.5, -140, 0.5, -185)
m.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
m.Active = true
m.Draggable = true
m.Parent = gui
Instance.new("UICorner", m).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.Text = "K.S VIP XX"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 70)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = m

-- PAGE NAVIGATION
local pages = {}
local page = 1
local order = 0

local nav = Instance.new("Frame")
nav.Position = UDim2.new(0, 6, 0, 42)
nav.Size = UDim2.new(1, -12, 0, 34)
nav.BackgroundTransparency = 1
nav.Parent = m

local function makeNavButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -3, 1, 0)
    b.Position = UDim2.new(x, x == 0 and 0 or 3, 0, 0)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = Color3.fromRGB(35, 40, 45)
    b.Parent = nav
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local page1Btn = makeNavButton("PAGE 1", 0)
local page2Btn = makeNavButton("PAGE 2", 0.5)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 6, 0, 82)
list.Size = UDim2.new(1, -12, 1, -88)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = m

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 4)
pad.Parent = list

local function setPage(n)
    page = n

    for _, item in ipairs(pages) do
        item.Visible = item:GetAttribute("Page") == page
    end

    page1Btn.BackgroundColor3 =
        page == 1 and Color3.fromRGB(0, 120, 80)
        or Color3.fromRGB(35, 40, 45)

    page2Btn.BackgroundColor3 =
        page == 2 and Color3.fromRGB(0, 120, 80)
        or Color3.fromRGB(35, 40, 45)

    list.CanvasPosition = Vector2.zero
end

page1Btn.Activated:Connect(function()
    setPage(1)
end)

page2Btn.Activated:Connect(function()
    setPage(2)
end)

local function btn(text, fn, pageNumber)
    order += 1

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 34)
    b.LayoutOrder = order
    b.Text = text
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(0, 255, 160)
    b.BackgroundColor3 = Color3.fromRGB(35, 40, 45)
    b:SetAttribute("Page", pageNumber or 1)
    b.Parent = list

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)

    table.insert(pages, b)
    b.Visible = b:GetAttribute("Page") == page

    b.Activated:Connect(function()
        local ok, err = pcall(fn, b)
        if not ok then warn(err) end
    end)

    return b
end

-- BRIGHTNESS
local bright = L.Brightness
local label = Instance.new("TextLabel")
label.LayoutOrder = 0
label.Size = UDim2.new(1, -8, 0, 24)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label:SetAttribute("Page", 1)
label.Parent = list
table.insert(pages, label)

local function showBright()
    label.Text = "BRIGHTNESS: " .. math.floor(bright * 10) / 10
end

local function setBright(v)
    bright = math.clamp(v, 0, 10)
    L.Brightness = bright
    L.ExposureCompensation = 0
    L.Ambient = Color3.fromRGB(150, 150, 150)
    L.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    showBright()
end

btn("BRIGHTNESS +", function()
    setBright(bright + 1)
end, 1)

btn("BRIGHTNESS -", function()
    setBright(bright - 1)
end, 1)

-- NO LIGHT / SHADOW
local noLight = false

local old = {
    L.GlobalShadows,
    L.Brightness,
    L.Ambient,
    L.OutdoorAmbient,
    L.ExposureCompensation
}

local effects = {}

for _, v in ipairs(L:GetDescendants()) do
    if v:IsA("PostEffect") then
        effects[v] = v.Enabled
    end
end

btn("NO LIGHT / SHADOW: OFF", function(b)
    noLight = not noLight

    if noLight then
        L.GlobalShadows = false
        setBright(bright)

        for _, v in ipairs(L:GetDescendants()) do
            if v:IsA("PostEffect") then
                if effects[v] == nil then
                    effects[v] = v.Enabled
                end
                v.Enabled = false
            end
        end
    else
        L.GlobalShadows = old[1]
        L.Brightness = old[2]
        L.Ambient = old[3]
        L.OutdoorAmbient = old[4]
        L.ExposureCompensation = old[5]

        for v, x in pairs(effects) do
            if v.Parent then
                v.Enabled = x
            end
        end

        bright = math.clamp(old[2], 0, 10)
        showBright()
    end

    b.Text = "NO LIGHT / SHADOW: " ..
        (noLight and "ON" or "OFF")
end, 1)

-- FPS BOOST
local fps = false

btn("FPS BOOST: OFF", function(b)
    fps = not fps

    if type(setfpscap) == "function" then
        pcall(setfpscap, fps and 120 or 60)
    end

    b.Text = "FPS BOOST: " .. (fps and "ON" or "OFF")
end, 1)

-- NO TEXTURE
local noTex = false
local parts, decals = {}, {}

local function strip(v)
    if v:IsA("BasePart") then
        if not parts[v] then
            parts[v] = {v.Material, v.Reflectance}
        end

        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0

    elseif v:IsA("Decal") or v:IsA("Texture") then
        if decals[v] == nil then
            decals[v] = v.Transparency
        end

        v.Transparency = 1
    end
end

local function restoreTextures()
    for v, x in pairs(parts) do
        if v.Parent then
            v.Material = x[1]
            v.Reflectance = x[2]
        end
    end

    for v, x in pairs(decals) do
        if v.Parent then
            v.Transparency = x
        end
    end

    table.clear(parts)
    table.clear(decals)
end

btn("NO TEXTURE: OFF", function(b)
    noTex = not noTex

    if noTex then
        for _, v in ipairs(W:GetDescendants()) do
            strip(v)
        end
    else
        restoreTextures()
    end

    b.Text = "NO TEXTURE: " .. (noTex and "ON" or "OFF")
end, 1)

W.DescendantAdded:Connect(function(v)
    if noTex then
        task.defer(function()
            if noTex and v.Parent then
                strip(v)
            end
        end)
    end
end)

-- ANTI-LAG
local antiLag = false
local savedEffects = {}

local function disableEffect(obj)
    if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
        or obj:IsA("PostEffect") then

        if savedEffects[obj] == nil then
            savedEffects[obj] = obj.Enabled
        end

        obj.Enabled = false
    end
end

local function restoreEffects()
    for obj, value in pairs(savedEffects) do
        if obj.Parent then
            pcall(function()
                obj.Enabled = value
            end)
        end
    end

    table.clear(savedEffects)
end

btn("ANTI-LAG: OFF", function(b)
    antiLag = not antiLag

    if antiLag then
        for _, obj in ipairs(W:GetDescendants()) do
            disableEffect(obj)
        end

        for _, obj in ipairs(L:GetDescendants()) do
            disableEffect(obj)
        end
    else
        restoreEffects()
    end

    b.Text = "ANTI-LAG: " .. (antiLag and "ON" or "OFF")
end, 1)

W.DescendantAdded:Connect(function(obj)
    if antiLag then
        task.defer(function()
            if antiLag and obj.Parent then
                disableEffect(obj)
            end
        end)
    end
end)

L.DescendantAdded:Connect(function(obj)
    if antiLag then
        task.defer(function()
            if antiLag and obj.Parent then
                disableEffect(obj)
            end
        end)
    end
end)

-- AFK MODE
local afk = false

btn("AFK MODE: OFF", function(b)
    if type(R.Set3dRenderingEnabled) ~= "function" then
        b.Text = "AFK: UNSUPPORTED"
        return
    end

    local nextState = not afk
    local ok = pcall(function()
        R:Set3dRenderingEnabled(not nextState)
    end)

    if not ok then
        b.Text = "AFK: UNSUPPORTED"
        return
    end

    afk = nextState
    b.Text = "AFK MODE: " .. (afk and "ON" or "OFF")
end, 1)

-- CHARACTER
local function character()
    local c = p.Character
    return c and c:FindFirstChildOfClass("Humanoid"),
        c and c:FindFirstChild("HumanoidRootPart")
end

-- SHIFTLOCK
local shift = false
local shiftConn
local oldAuto, oldOffset

local function setShift(on)
    shift = on

    if shiftConn then
        shiftConn:Disconnect()
        shiftConn = nil
    end

    local h = character()

    if on then
        if h then
            oldAuto = h.AutoRotate
            oldOffset = h.CameraOffset
            h.AutoRotate = false
            h.CameraOffset = Vector3.new(1.75, 0, 0)
        end

        shiftConn = R.RenderStepped:Connect(function()
            local hum, root = character()
            local cam = W.CurrentCamera

            if shift and hum and root and cam then
                local v = cam.CFrame.LookVector
                local flat = Vector3.new(v.X, 0, v.Z)

                if flat.Magnitude > 0.001 then
                    root.CFrame = CFrame.lookAt(
                        root.Position,
                        root.Position + flat.Unit
                    )
                end
            end
        end)

    elseif h then
        h.AutoRotate = oldAuto
        h.CameraOffset = oldOffset
    end
end

btn("SHIFTLOCK: OFF", function(b)
    setShift(not shift)
    b.Text = "SHIFTLOCK: " .. (shift and "ON" or "OFF")
end, 2)

p.CharacterAdded:Connect(function()
    task.wait(1)
    if shift then
        setShift(true)
    end
end)

-- BALL SCANNER
local balls = {}
local scanning = false
local scanId = 0
local target = nil
local camConn = nil

local function findBalls()
    local found = {}

    for _, v in ipairs(W:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()

            if n:find("ball")
                or n:find("soccer")
                or n:find("football")
                or n:find("bola") then
                table.insert(found, v)
            end
        end
    end

    balls = found
    return found
end

local function nearestBall()
    local found = findBalls()
    local _, root = character()
    local best, distance = nil, math.huge

    for _, v in ipairs(found) do
        if v.Parent then
            local d = root and
                (v.Position - root.Position).Magnitude or 0

            if d < distance then
                best, distance = v, d
            end
        end
    end

    return best
end

local function stopCamera()
    if camConn then
        camConn:Disconnect()
        camConn = nil
    end

    target = nil

    local cam = W.CurrentCamera
    local hum = character()

    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if hum then
            cam.CameraSubject = hum
        end
    end
end

local function startCamera()
    target = nearestBall()

    if not target or not W.CurrentCamera then
        return false
    end

    if camConn then
        camConn:Disconnect()
        camConn = nil
    end

    W.CurrentCamera.CameraType = Enum.CameraType.Scriptable

    camConn = R.RenderStepped:Connect(function()
        local cam = W.CurrentCamera
        local _, root = character()

        if not cam or not root then return end

        if not target or not target.Parent then return end

        local origin = root.Position
            - root.CFrame.LookVector * 8
            + Vector3.new(0, 4, 0)

        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = CFrame.lookAt(origin, target.Position)
    end)

    return true
end

btn("SCAN BALL / CAMERA: OFF", function(b)
    scanning = not scanning
    scanId += 1
    local id = scanId

    if not scanning then
        stopCamera()
        b.Text = "SCAN BALL / CAMERA: OFF"
        return
    end

    print("Bola ditemukan:", #findBalls())

    if not startCamera() then
        scanning = false
        b.Text = "BALL NOT FOUND"
        return
    end

    b.Text = "CHARACTER POV: ON"

    task.spawn(function()
        while scanning and scanId == id do
            task.wait(2)

            if not scanning or scanId ~= id then break end

            local nextBall = nearestBall()

            if not target or not target.Parent then
                target = nextBall
            end

            b.Text = target and "CHARACTER POV: ON"
                or "BALL NOT FOUND"
        end
    end)
end, 2)

-- BALL SLOW MOTION DETECTOR
-- Tidak mengubah kamera atau fisika bola
local slowVisual = false
local slowConn = nil
local slowTarget = nil

btn("BALL SLOW MOTION: OFF", function(b)
    slowVisual = not slowVisual

    if slowConn then
        slowConn:Disconnect()
        slowConn = nil
    end

    if not slowVisual then
        slowTarget = nil
        b.Text = "BALL SLOW MOTION: OFF"
        return
    end

    slowTarget = target and target.Parent and target or nearestBall()

    if not slowTarget then
        slowVisual = false
        b.Text = "BALL NOT FOUND"
        return
    end

    b.Text = "BALL SLOW MOTION: ON"

    slowConn = R.RenderStepped:Connect(function()
        if not slowVisual then return end

        if not slowTarget or not slowTarget.Parent then
            slowTarget = target and target.Parent and target or nearestBall()

            if not slowTarget then
                b.Text = "BALL NOT FOUND"
                return
            end
        end

        local airborne =
            math.abs(slowTarget.AssemblyLinearVelocity.Y) > 3

        b.Text = airborne
            and "BALL AIRBORNE: DETECTED"
            or "BALL SLOW MOTION: ON"
    end)
end, 2)

-- FLOATING K BUTTON
local tg = Instance.new("ScreenGui")
tg.Name = "KSVIPXXToggle"
tg.ResetOnSpawn = false
tg.DisplayOrder = 999
tg.IgnoreGuiInset = true
tg.Parent = g

local k = Instance.new("TextButton")
k.Size = UDim2.fromOffset(48, 48)
k.Position = UDim2.new(0, 15, 0.45, 0)
k.Text = "K"
k.TextSize = 22
k.Font = Enum.Font.GothamBold
k.TextColor3 = Color3.new(1, 1, 1)
k.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
k.Active = true
k.Parent = tg
Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

local drag, moved, start, pos, active =
    false, false, nil, nil, nil

k.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then

        drag = true
        moved = false
        start = i.Position
        pos = k.Position
        active = i.UserInputType == Enum.UserInputType.Touch
            and i or nil
    end
end)

U.InputChanged:Connect(function(i)
    if not drag or not start then return end

    if i.UserInputType == Enum.UserInputType.MouseMovement
        or (i.UserInputType == Enum.UserInputType.Touch
        and (not active or i == active)) then

        local d = i.Position - start

        if d.Magnitude > 8 then moved = true end

        if moved then
            k.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset + d.X,
                pos.Y.Scale, pos.Y.Offset + d.Y
            )
        end
    end
end)

U.InputEnded:Connect(function(i)
    if not drag then return end

    if i.UserInputType == Enum.UserInputType.MouseButton1
        or (i.UserInputType == Enum.UserInputType.Touch
        and (not active or i == active)) then

        drag = false
        active = nil

        if not moved then
            gui.Enabled = not gui.Enabled
        end

        start = nil
        pos = nil
    end
end)

-- FPS TRACKER
local labelFPS = Instance.new("TextLabel")
labelFPS.Size = UDim2.fromOffset(100, 24)
labelFPS.Position = UDim2.new(0, 15, 0, 300)
labelFPS.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
labelFPS.TextColor3 = Color3.fromRGB(0, 255, 160)
labelFPS.Font = Enum.Font.GothamBold
labelFPS.TextSize = 13
labelFPS.Text = "FPS: ..."
labelFPS.Parent = tg

local frames, last = 0, os.clock()

R.RenderStepped:Connect(function()
    frames += 1
    local now = os.clock()

    if now - last >= 1 then
        labelFPS.Text = "FPS: " .. frames
        frames = 0
        last = now
        showBright()
    end
end)

setPage(1)
showBright()

print("K.S VIP XX Compact Edition 2 Page loaded!")
