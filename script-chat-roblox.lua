--========================================
-- SC CHAT MOBILE V1
-- Mobile GUI | Roblox
--========================================

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Hapus GUI lama
local Old = PlayerGui:FindFirstChild("SC_CHAT_GUI")
if Old then
    Old:Destroy()
end

-- Cari channel chat Roblox
local function GetChannel()
    local Channels = TextChatService:WaitForChild("TextChannels", 10)
    if not Channels then
        return nil
    end

    return Channels:FindFirstChild("RBXGeneral")
        or Channels:FindFirstChildWhichIsA("TextChannel")
end

local Channel = GetChannel()

--========================================
-- GUI UTAMA
--========================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "SC_CHAT_GUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 310, 0, 350)
Main.Position = UDim2.new(0.5, -155, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
Main.BackgroundTransparency = 0.12
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 130, 255)
Stroke.Transparency = 0.25
Stroke.Thickness = 1.5
Stroke.Parent = Main

--========================================
-- HEADER
--========================================

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -45, 0, 42)
Header.Position = UDim2.new(0, 12, 0, 0)
Header.BackgroundTransparency = 1
Header.Text = "SC CHAT  |  MOBILE"
Header.TextColor3 = Color3.fromRGB(120, 170, 255)
Header.TextSize = 17
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 34, 0, 30)
Close.Position = UDim2.new(1, -40, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(190, 55, 65)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 15
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

--========================================
-- STATUS
--========================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.new(0, 10, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = Channel and "● CHAT CHANNEL TERSEDIA"
    or "● CHANNEL CHAT TIDAK DITEMUKAN"
Status.TextColor3 = Channel
    and Color3.fromRGB(100, 230, 150)
    or Color3.fromRGB(255, 110, 110)
Status.TextSize = 10
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--========================================
-- RIWAYAT PESAN
--========================================

local Log = Instance.new("ScrollingFrame")
Log.Name = "ChatLog"
Log.Size = UDim2.new(1, -20, 0, 220)
Log.Position = UDim2.new(0, 10, 0, 66)
Log.BackgroundColor3 = Color3.fromRGB(7, 9, 15)
Log.BackgroundTransparency = 0.15
Log.BorderSizePixel = 0
Log.ScrollBarThickness = 4
Log.CanvasSize = UDim2.new(0, 0, 0, 0)
Log.Parent = Main

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = Log

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Log

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 7)
Padding.PaddingLeft = UDim.new(0, 7)
Padding.PaddingRight = UDim.new(0, 7)
Padding.Parent = Log

local function AddMessage(Text, Color)
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -5, 0, 0)
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Top
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color or Color3.new(1, 1, 1)
    Label.Text = Text
    Label.LayoutOrder = #Log:GetChildren()
    Label.Parent = Log

    task.defer(function()
        Log.CanvasSize = UDim2.new(
            0, 0, 0, Layout.AbsoluteContentSize.Y + 15
        )
        Log.CanvasPosition = Vector2.new(
            0, math.max(0, Log.CanvasSize.Y.Offset - Log.AbsoluteWindowSize.Y)
        )
    end)
end

AddMessage("SC CHAT berhasil dibuka.", Color3.fromRGB(120, 170, 255))
AddMessage("Pesan menggunakan chat Roblox biasa.")

--========================================
-- INPUT PESAN
--========================================

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -100, 0, 38)
Input.Position = UDim2.new(0, 10, 1, -48)
Input.BackgroundColor3 = Color3.fromRGB(35, 39, 52)
Input.BorderSizePixel = 0
Input.PlaceholderText = "Tulis pesan..."
Input.PlaceholderColor3 = Color3.fromRGB(160, 160, 170)
Input.Text = ""
Input.TextColor3 = Color3.new(1, 1, 1)
Input.TextSize = 13
Input.Font = Enum.Font.Gotham
Input.ClearTextOnFocus = false
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = Input

local Send = Instance.new("TextButton")
Send.Size = UDim2.new(0, 80, 0, 38)
Send.Position = UDim2.new(1, -90, 1, -48)
Send.BackgroundColor3 = Color3.fromRGB(65, 110, 240)
Send.BorderSizePixel = 0
Send.Text = "KIRIM"
Send.TextColor3 = Color3.new(1, 1, 1)
Send.TextSize = 12
Send.Font = Enum.Font.GothamBold
Send.Parent = Main

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = Send

--========================================
-- KIRIM PESAN
--========================================

local Busy = false

local function SendMessage()
    if Busy then
        return
    end

    local Message = Input.Text

    if not Message or Message:match("^%s*$") then
        return
    end

    if not Channel then
        AddMessage("ERROR: Channel chat tidak tersedia.", Color3.fromRGB(255, 100, 100))
        return
    end

    Busy = true
    Send.Text = "..."

    local Success, ErrorMessage = pcall(function()
        Channel:SendAsync(Message)
    end)

    if Success then
        Input.Text = ""
    else
        AddMessage(
            "Gagal mengirim: " .. tostring(ErrorMessage),
            Color3.fromRGB(255, 100, 100)
        )
    end

    Send.Text = "KIRIM"
    Busy = false
end

Send.MouseButton1Click:Connect(SendMessage)

Input.FocusLost:Connect(function(EnterPressed)
    if EnterPressed then
        SendMessage()
    end
end)

--========================================
-- PESAN MASUK
--========================================

if Channel then
    Channel.MessageReceived:Connect(function(Message)
        local Prefix = Message.PrefixText or "Pemain"
        local Text = Message.Text or ""

        AddMessage(
            Prefix .. ": " .. Text,
            Color3.fromRGB(220, 230, 255)
        )
    end)
end

print("[SC CHAT MOBILE] Berhasil dimuat!")
