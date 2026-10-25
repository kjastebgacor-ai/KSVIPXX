-- ============================================================
-- FFS ASHUM MOBILE | GACOR EDITION V5.0 | By ASHUM
-- ✅ GACOR = FPS Naik + Bola Nyala + Nendang Enteng
-- Paste 1x aja, jangan ditumpuk sama script lama!
-- ============================================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Hapus GUI lama biar ga numpuk
for _, v in ipairs(PlayerGui:GetChildren()) do
    if string.find(v.Name, "FFS") or string.find(v.Name, "ASHUM") or string.find(v.Name, "TES") then
        v:Destroy()
    end
end

local GACOR = {
    On = true,
    WarnaBola = "Pelangi", -- Ganti: Cyan / Merah / Pelangi / Jarak
    Beam = true,
    Trail = true,
}

local PROTECT = {"ball","bola","soccer","football","goal","gawang","net","jaring","keeper","crossbar","post"}
local function hasWord(n, list) for _, w in ipairs(list) do if string.find(n, w, 1, true) then return true end end return false end
local function isBall(o)
    if not o:IsA("BasePart") then return false end
    if hasWord(string.lower(o.Name), {"ball","bola","soccer","football"}) then return true end
    return o.Shape == Enum.PartType.Ball
end
local function isGoalNet(o)
    if hasWord(string.lower(o.Name), {"net","jaring","goal","gawang"}) then return true end
    local p = o.Parent for i=1,3 do if not p then break end if hasWord(string.lower(p.Name), {"goal","gawang","net","jaring"}) then return true end p = p.Parent end return false
end
local function isProtected(o) if o:IsDescendantOf(Players) then return true end if hasWord(string.lower(o.Name), PROTECT) then return true end if isBall(o) then return true end if isGoalNet(o) then return true end return false end

-- ================= UI GACOR - SIMPLE, 1 TOMBOL =================
local Gui = Instance.new("ScreenGui")
Gui.Name = "FFS_ASHUM_GACOR"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

-- TOMBOL A - GEDE, DITENGAH KANAN, GAMPANG DIPENCET
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 65, 0, 65)
OpenBtn.Position = UDim2.new(1, -78, 0.5, -32)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
OpenBtn.Text = "A"
OpenBtn.TextSize = 32
OpenBtn.TextColor3 = Color3.fromRGB(0,0,0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.BorderSizePixel = 0
OpenBtn.Active = true
OpenBtn.ZIndex = 999
OpenBtn.Parent = Gui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)
local S = Instance.new("UIStroke"); S.Thickness = 3; S.Color = Color3.fromRGB(255,255,255); S.Parent = OpenBtn

-- Label FPS + Bola di atas (selalu keliatan, ga perlu buka panel)
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 200, 0, 32)
HUD.Position = UDim2.new(0.5, -100, 0, 8)
HUD.BackgroundColor3 = Color3.fromRGB(0,0,0)
HUD.BackgroundTransparency = 0.3
HUD.Text = "⚽ GACOR MODE ON"
HUD.TextColor3 = Color3.fromRGB(0,255,120)
HUD.Font = Enum.Font.GothamBlack
HUD.TextSize = 13
HUD.ZIndex = 100
HUD.Parent = Gui
Instance.new("UICorner", HUD).CornerRadius = UDim.new(0, 20)

-- PANEL - KECIL AJA, GA RIBET
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 340)
Main.Position = UDim2.new(0.5, -120, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(10,10,22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 500
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)
local MS = Instance.new("UIStroke"); MS.Thickness = 2; MS.Color = Color3.fromRGB(0,255,120); MS.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40); Title.Position = UDim2.new(0,0,0,5)
Title.BackgroundTransparency = 1; Title.Text = "👑 ASHUM GACOR"; Title.TextColor3 = Color3.fromRGB(0,255,120)
Title.Font = Enum.Font.GothamBlack; Title.TextSize = 18; Title.ZIndex = 501; Title.Parent = Main

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1,0,0,16); Sub.Position = UDim2.new(0,0,0,38)
Sub.BackgroundTransparency = 1; Sub.Text = "FPS Naik • Bola Nyala • Nendang Enteng"; Sub.TextColor3 = Color3.fromRGB(180,180,180)
Sub.Font = Enum.Font.Gotham; Sub.TextSize = 10; Sub.ZIndex = 501; Sub.Parent = Main

local function makeGacorBtn(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,44); b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.BorderSizePixel = 0; b.ZIndex = 501; b.Parent = Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    return b
end

local btnGacor = makeGacorBtn("🔥 GACOR: ON", 62, Color3.fromRGB(0,200,100))
local btnBola = makeGacorBtn("⚽ BOLA PELANGI: ON", 112, Color3.fromRGB(255,0,150))
local btnLag = makeGacorBtn("🚀 ANTI LAG: ON", 162, Color3.fromRGB(0,150,255))
local btnTex = makeGacorBtn("🧱 NO TEXTURE: OFF", 212, Color3.fromRGB(255,140,0))
local btnTutup = makeGacorBtn("❌ TUTUP", 262, Color3.fromRGB(255,60,80))

local isOpen = false
local function toggle()
    isOpen = not isOpen
    Main.Visible = isOpen
    if isOpen then
        OpenBtn.Text = "X"; OpenBtn.BackgroundColor3 = Color3.fromRGB(255,60,80); OpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,240,0,340)}):Play()
    else
        OpenBtn.Text = "A"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0,255,120); OpenBtn.TextColor3 = Color3.fromRGB(0,0,0)
    end
    print("ASHUM GACOR - Panel: "..tostring(isOpen))
end

-- 3 CARA KLIK BIAR PASTI KENA
OpenBtn.Activated:Connect(toggle)
OpenBtn.MouseButton1Click:Connect(toggle)
OpenBtn.TouchTap:Connect(toggle)
btnTutup.Activated:Connect(toggle)
btnTutup.MouseButton1Click:Connect(toggle)

-- ================= MESIN GACOR =================
local Tracked = {}
local SavedNet = {}
for _, o in ipairs(Workspace:GetDescendants()) do if isGoalNet(o) then SavedNet[o] = true end end

local function clearBall(ball)
    for _, n in ipairs({"GACOR_HL","GACOR_BILL","GACOR_PRED","GACOR_TRAIL","GACOR_BEAM","GACOR_LIGHT","Att0","Att1"}) do local x = ball:FindFirstChild(n) if x then x:Destroy() end end
    pcall(function() ball.Material = Enum.Material.SmoothPlastic end)
end

local function setupBall(ball)
    if not GACOR.On then return end
    if not isBall(ball) then return end
    if Tracked[ball] then return end
    Tracked[ball] = true

    -- 1. BOLA JADI NEON + WARNA
    pcall(function()
        ball.Material = Enum.Material.Neon
        ball.CastShadow = false
        ball.Color = Color3.fromRGB(0,255,255)
    end)

    -- 2. HIGHLIGHT TEMBUS TEMBOK
    local hl = Instance.new("Highlight")
    hl.Name = "GACOR_HL"; hl.Adornee = ball
    hl.FillColor = Color3.fromRGB(0,255,255); hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.3; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = ball

    -- 3. BEAM KE LANGIT (Biar keliatan dari jauh)
    if GACOR.Beam then
        local beam = Instance.new("Part")
        beam.Name = "GACOR_BEAM"; beam.Anchored = true; beam.CanCollide = false; beam.CanQuery = false
        beam.Transparency = 0.4; beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(0,255,255)
        beam.Size = Vector3.new(0.5, 25, 0.5); beam.Parent = ball
        local light = Instance.new("PointLight")
        light.Name = "GACOR_LIGHT"; light.Color = Color3.fromRGB(0,255,255); light.Brightness = 3; light.Range = 30; light.Parent = ball
    end

    -- 4. LABEL JARAK + SPEED
    local bg = Instance.new("BillboardGui")
    bg.Name = "GACOR_BILL"; bg.Size = UDim2.new(0, 130, 0, 32); bg.StudsOffset = Vector3.new(0, 2.8, 0); bg.AlwaysOnTop = true; bg.Parent = ball
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundColor3 = Color3.fromRGB(0,0,0); lbl.BackgroundTransparency = 0.2
    lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 11; lbl.Text = "⚽ --"; lbl.Parent = bg
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

    -- 5. TRAIL
    if GACOR.Trail then
        local a0 = Instance.new("Attachment"); a0.Name = "Att0"; a0.Parent = ball
        local a1 = Instance.new("Attachment"); a1.Name = "Att1"; a1.Position = Vector3.new(0,0.5,0); a1.Parent = ball
        local trail = Instance.new("Trail"); trail.Name = "GACOR_TRAIL"; trail.Attachment0 = a0; trail.Attachment1 = a1
        trail.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,0,150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,200,0))}
        trail.Lifetime = 0.6; trail.Parent = ball
    end

    -- 6. PREDIKSI
    local pred = Instance.new("Part")
    pred.Name = "GACOR_PRED"; pred.Anchored = true; pred.CanCollide = false; pred.CanQuery = false
    pred.Transparency = 1; pred.Material = Enum.Material.Neon; pred.Color = Color3.fromRGB(255,255,0)
    pred.Size = Vector3.new(0.3,0.3,12); pred.Parent = ball
end

local function clearAll() for b,_ in pairs(Tracked) do clearBall(b) end Tracked = {} end
local function refreshAll() clearAll(); for _, o in ipairs(Workspace:GetDescendants()) do if isBall(o) then setupBall(o) end end end

-- ANTI LAG GACOR - Bersihin yang berat, tapi jaga bola & jaring
local function gacorAntiLag()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
    end)
    for _, o in ipairs(Workspace:GetDescendants()) do
        if not isProtected(o) and not isGoalNet(o) then
            pcall(function()
                if o:IsA("BasePart") then o.CastShadow = false end
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Smoke") or o:IsA("Fire") then o.Enabled = false end
                if o:IsA("BasePart") and (o.Material == Enum.Material.Glass or o.Material == Enum.Material.ForceField) then o.Material = Enum.Material.SmoothPlastic end
            end)
        end
    end
end

local SavedTex = {}
local function runNoTex()
    for _, o in ipairs(Workspace:GetDescendants()) do
        if not isProtected(o) and not isGoalNet(o) then
            pcall(function()
                if o:IsA("BasePart") then if not SavedTex[o] then SavedTex[o] = o.Material end o.Material = Enum.Material.SmoothPlastic; o.CastShadow = false
                elseif o:IsA("Decal") or o:IsA("Texture") then if not SavedTex[o] then SavedTex[o] = o.Texture end o.Texture = ""; o.Transparency = 1
                elseif o:IsA("MeshPart") then if not SavedTex[o] then SavedTex[o] = o.TextureID end o.TextureID = "" end
            end)
        end
    end
    Lighting.GlobalShadows = false
end
local function restoreTex()
    for o, old in pairs(SavedTex) do pcall(function() if o:IsA("BasePart") then o.Material = old elseif o:IsA("Decal") or o:IsA("Texture") then o.Texture = old; o.Transparency = 0 elseif o:IsA("MeshPart") then o.TextureID = old end end) end
    SavedTex = {}
end

-- Tombol Panel
btnGacor.Activated:Connect(function()
    GACOR.On = not GACOR.On
    btnGacor.Text = GACOR.On and "🔥 GACOR: ON" or "🔥 GACOR: OFF"
    btnGacor.BackgroundColor3 = GACOR.On and Color3.fromRGB(0,200,100) or Color3.fromRGB(100,100,100)
    if GACOR.On then refreshAll(); gacorAntiLag() else clearAll() end
end)
btnBola.Activated:Connect(function()
    -- Ganti warna: Pelangi -> Cyan -> Merah -> Jarak -> balik Pelangi
    if GACOR.WarnaBola == "Pelangi" then GACOR.WarnaBola = "Cyan"
    elseif GACOR.WarnaBola == "Cyan" then GACOR.WarnaBola = "Merah"
    elseif GACOR.WarnaBola == "Merah" then GACOR.WarnaBola = "Jarak"
    else GACOR.WarnaBola = "Pelangi" end
    btnBola.Text = "⚽ BOLA "..string.upper(GACOR.WarnaBola)..": ON"
    refreshAll()
end)
local antiLagOn = true
btnLag.Activated:Connect(function()
    antiLagOn = not antiLagOn
    btnLag.Text = antiLagOn and "🚀 ANTI LAG: ON" or "🚀 ANTI LAG: OFF"
    Lighting.GlobalShadows = not antiLagOn
    if antiLagOn then gacorAntiLag() end
end)
local texOn = false
btnTex.Activated:Connect(function()
    texOn = not texOn
    btnTex.Text = texOn and "🧱 NO TEXTURE: ON" or "🧱 NO TEXTURE: OFF"
    if texOn then runNoTex() else restoreTex() end
end)

-- ================= LOOP GACOR - RINGAN, 0.25 DETIK =================
local lastTick = tick(); local frames = 0; local lastScan = 0
RunService.Heartbeat:Connect(function()
    frames += 1
    if tick() - lastScan > 2 then
        lastScan = tick()
        for _, o in ipairs(Workspace:GetDescendants()) do if isBall(o) and not Tracked[o] then setupBall(o) end end
    end
    if tick() - lastTick < 0.25 then return end
    local fps = math.floor(frames / (tick() - lastTick)); frames = 0; lastTick = tick()
    local nearest = 9999; local nearestSpeed = 0; local nearestDir = ""
    for ball,_ in pairs(Tracked) do
        if not ball.Parent then Tracked[ball] = nil else
            local hl = ball:FindFirstChild("GACOR_HL")
            local bill = ball:FindFirstChild("GACOR_BILL")
            local pred = ball:FindFirstChild("GACOR_PRED")
            local beam = ball:FindFirstChild("GACOR_BEAM")
            local light = ball:FindFirstChild("GACOR_LIGHT")
            local vel = ball.AssemblyLinearVelocity
            local speed = math.floor(vel.Magnitude * 3.6)
            if player.Character and player.Character.PrimaryPart then
                local d = (ball.Position - player.Character.PrimaryPart.Position).Magnitude
                local col
                if GACOR.WarnaBola == "Pelangi" then col = Color3.fromHSV(tick() % 1, 1, 1)
                elseif GACOR.WarnaBola == "Merah" then col = Color3.fromRGB(255,45,85)
                elseif GACOR.WarnaBola == "Cyan" then col = Color3.fromRGB(0,255,255)
                else -- Jarak
                    if d < 50 then col = Color3.fromRGB(0,255,120)
                    elseif d < 120 then col = Color3.fromRGB(0,255,255)
                    elseif d < 250 then col = Color3.fromRGB(255,45,85)
                    else col = Color3.fromRGB(255,200,0) end
                end
                pcall(function()
                    ball.Color = col
                    if hl then hl.FillColor = col end
                    if beam then beam.Color = col; beam.CFrame = CFrame.new(ball.Position + Vector3.new(0, 12, 0)) end
                    if light then light.Color = col end
                end)
                if bill then local lbl = bill:FindFirstChildOfClass("TextLabel") if lbl then lbl.Text = "⚽ "..math.floor(d).."m • "..speed.." km/h" end end
                if d < nearest then nearest = d; nearestSpeed = speed; local dir = ball.Position - player.Character.PrimaryPart.Position; if math.abs(dir.X) > math.abs(dir.Z) then nearestDir = dir.X > 0 and "KANAN ➡️" or "KIRI ⬅️" else nearestDir = dir.Z > 0 and "BELAKANG ⬇️" or "DEPAN ⬆️" end end
                if pred then if vel.Magnitude > 3 then pred.Transparency = 0.35; pred.Color = col; pred.CFrame = CFrame.new(ball.Position + vel.Unit*6, ball.Position + vel*2) else pred.Transparency = 1 end end
            end
        end
    end
    if nearest < 9999 then
        HUD.Text = "⚽ "..nearestDir.." • "..math.floor(nearest).."m • "..nearestSpeed.." km/h • FPS "..fps
        HUD.BackgroundColor3 = nearest < 20 and Color3.fromRGB(255,45,85) or Color3.fromRGB(0,0,0)
    else
        HUD.Text = "⚽ CARI BOLA... • FPS "..fps
    end
end)

-- JALANIN LANGSUNG
gacorAntiLag()
for _, o in ipairs(Workspace:GetDescendants()) do task.spawn(function() if isGoalNet(o) then return end if o:IsA("BasePart") and not isBall(o) and not isProtected(o) then o.CastShadow = false end setupBall(o) end) end
Workspace.DescendantAdded:Connect(function(o) task.defer(function() if isGoalNet(o) then return end setupBall(o) end) end)

print("🔥 [FFS ASHUM GACOR V5.0] AKTIF - SIAP GACOR!")

-- Notif masuk
task.delay(0.5, function()
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 300, 0, 52); n.Position = UDim2.new(0.5,-150,0,-70)
    n.BackgroundColor3 = Color3.fromRGB(0,200,100); n.Text = "🔥 ASHUM GACOR AKTIF!\nFPS Naik • Bola Pelangi Nyala"
    n.TextColor3 = Color3.fromRGB(255,255,255); n.Font = Enum.Font.GothamBold; n.TextSize = 13; n.ZIndex = 1000; n.Parent = Gui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0,14)
    TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5,-150,0,16)}):Play()
    task.delay(3.5, function() TweenService:Create(n, TweenInfo.new(0.4), {Position = UDim2.new(0.5,-150,0,-70)}):Play() task.delay(0.4, function() n:Destroy() end) end)
end)
