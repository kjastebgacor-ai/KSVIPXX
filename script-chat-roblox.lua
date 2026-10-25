-- Brookhaven Minimal Chat UI
-- UI lokal; tidak mengirim pesan ke pemain lain.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("MinimalChatUI")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "MinimalChatUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 220, 0, 250)
panel.Position = UDim2.new(1, -230, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 32)
title.Position = UDim2.new(0, 8, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Minimal Chat"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 28, 0, 28)
toggle.Position = UDim2.new(1, -32, 0, 4)
toggle.Text = "—"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.BackgroundTransparency = 1
toggle.TextSize = 18
toggle.Parent = panel

local messages = Instance.new("ScrollingFrame")
messages.Size = UDim2.new(1, -16, 1, -50)
messages.Position = UDim2.new(0, 8, 0, 40)
messages.BackgroundTransparency = 1
messages.BorderSizePixel = 0
messages.ScrollBarThickness = 3
messages.CanvasSize = UDim2.new(0, 0, 0, 0)
messages.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = messages

local function addMessage(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 30)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = messages

    task.wait()
    messages.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    messages.CanvasPosition = Vector2.new(
        0,
        math.max(0, layout.AbsoluteContentSize.Y - messages.AbsoluteWindowSize.Y)
    )
end

addMessage("Chat UI aktif.")
addMessage("Pesan di sini hanya terlihat di perangkatmu.")

local minimized = false

toggle.Activated:Connect(function()
    minimized = not minimized
    messages.Visible = not minimized
    panel.Size = minimized
        and UDim2.new(0, 220, 0, 38)
        or UDim2.new(0, 220, 0, 250)
    toggle.Text = minimized and "+" or "—"
end)
