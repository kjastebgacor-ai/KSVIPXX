local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")

if getgenv().KSChatBypassLoaded then return end
getgenv().KSChatBypassLoaded = true

local LocalPlayer = Players.LocalPlayer
local SERVER_URL = "wss://alkekchat.alwaysdata.net"
local ws = nil

local activeTab = "Here"
local E2E_SECRET_KEY = "AlkekSecretKey_" .. tostring(game.PlaceId)

local tabColors = {
    Alkek = Color3.fromRGB(255, 75, 75),
    Here = Color3.fromRGB(255, 255, 255),
    Global = Color3.fromRGB(255, 200, 50)
}

local CONFIG_FILE = "KS-chat-bypass-config.json"

local function loadConfig()
    if readfile and pcall(readfile, CONFIG_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(data) == "table" then
            for tab, hex in pairs(data) do
                if type(hex) == "string" then
                    local r = tonumber(hex:sub(1, 2), 16)
                    local g = tonumber(hex:sub(3, 4), 16)
                    local b = tonumber(hex:sub(5, 6), 16)
                    if r and g and b then
                        tabColors[tab] = Color3.fromRGB(r, g, b)
                    end
                end
            end
        end
    end
end

local function saveConfig()
    if writefile then
        local data = {}
        for tab, color in pairs(tabColors) do
            local r = math.floor(color.R * 255 + 0.5)
            local g = math.floor(color.G * 255 + 0.5)
            local b = math.floor(color.B * 255 + 0.5)
            data[tab] = string.format("%02X%02X%02X", r, g, b)
        end
        pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(data))
    end
end

loadConfig()

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64lookup = {}
for i = 1, #b64chars do
    b64lookup[b64chars:sub(i, i)] = i - 1
end

local function toBase64(data)
    local result = {}
    local len = #data
    for i = 1, len, 3 do
        local a = data:byte(i)
        local b = i + 1 <= len and data:byte(i + 1) or 0
        local c = i + 2 <= len and data:byte(i + 2) or 0

        local b1 = bit32.rshift(a, 2)
        local b2 = bit32.lshift(bit32.band(a, 3), 4) + bit32.rshift(b, 4)
        local b3 = bit32.lshift(bit32.band(b, 15), 2) + bit32.rshift(c, 6)
        local b4 = bit32.band(c, 63)

        table.insert(result, b64chars:sub(b1 + 1, b1 + 1))
        table.insert(result, b64chars:sub(b2 + 1, b2 + 1))
        if i + 1 <= len then
            table.insert(result, b64chars:sub(b3 + 1, b3 + 1))
        else
            table.insert(result, '=')
        end
        if i + 2 <= len then
            table.insert(result, b64chars:sub(b4 + 1, b4 + 1))
        else
            table.insert(result, '=')
        end
    end
    return table.concat(result)
end

local function fromBase64(data)
    data = data:gsub('[^' .. b64chars .. '=]', '')
    local result = {}
    local len = #data
    for i = 1, len, 4 do
        local c1 = b64lookup[data:sub(i, i)] or 0
        local c2 = b64lookup[data:sub(i + 1, i + 1)] or 0
        local c3 = b64lookup[data:sub(i + 2, i + 2)]
        local c4 = b64lookup[data:sub(i + 3, i + 3)]

        local b1 = bit32.lshift(c1, 2) + bit32.rshift(c2, 4)
        table.insert(result, string.char(b1))

        if c3 then
            local b2 = bit32.lshift(bit32.band(c2, 15), 4) + bit32.rshift(c3, 2)
            table.insert(result, string.char(b2))
        end
        if c4 then
            local b3 = bit32.lshift(bit32.band(c3, 3), 6) + c4
            table.insert(result, string.char(b3))
        end
    end
    return table.concat(result)
end

local function cryptTransform(text, key, iv)
    local result = {}
    local keyBytes = { string.byte(key, 1, #key) }
    local ivBytes = { string.byte(iv, 1, #iv) }

    local state = 0
    for i = 1, #keyBytes do state = bit32.bxor(state, keyBytes[i]) end
    for i = 1, #ivBytes do state = bit32.bxor(state, ivBytes[i]) end

    for i = 1, #text do
        state = bit32.arshift(bit32.band(state * 1103515245 + 12345, 0x7FFFFFFF), 16)
        local keyByte = bit32.band(state, 0xFF)
        local charByte = string.byte(text, i, i)
        table.insert(result, string.char(bit32.bxor(charByte, keyByte)))
    end

    return table.concat(result)
end

local function encryptE2E(plainText, key)
    local iv = ""
    for _ = 1, 8 do
        iv = iv .. string.char(math.random(0, 255))
    end
    local cipher = cryptTransform(plainText, key, iv)
    return toBase64(iv .. cipher)
end

local function decryptE2E(cipherBase64, key)
    local ok, raw = pcall(fromBase64, cipherBase64)
    if not ok or #raw < 9 then return nil end

    local iv = string.sub(raw, 1, 8)
    local cipher = string.sub(raw, 9)
    return cryptTransform(cipher, key, iv)
end

pcall(function()
    TextChatService.ChatWindowConfiguration.Enabled = false
    TextChatService.ChatInputBarConfiguration.Enabled = false
end)

local function sanitizeText(str)
    if type(str) ~= "string" then return "" end
    str = string.gsub(str, "&", "&amp;")
    str = string.gsub(str, "<", "&lt;")
    str = string.gsub(str, ">", "&gt;")
    str = string.gsub(str, '"', "&quot;")
    str = string.gsub(str, "'", "&apos;")
    return str
end

local function getWebSocketConnect()
    if WebSocket and WebSocket.connect then return WebSocket.connect
    elseif WebSocket and WebSocket.Connect then return WebSocket.Connect
    elseif syn and syn.websocket and syn.websocket.connect then return syn.websocket.connect
    end
    return nil
end

local parentGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KS-chat-bypass"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 260)
mainFrame.Position = UDim2.new(0, 8, 0, 4)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

-- Tombol tutup panel dan tombol CHAT saat panel disembunyikan.
local closePanelBtn = Instance.new("TextButton")
closePanelBtn.Name = "ClosePanelBtn"
closePanelBtn.Size = UDim2.new(0, 24, 0, 24)
closePanelBtn.Position = UDim2.new(1, -58, 0, 6)
closePanelBtn.BackgroundColor3 = Color3.fromRGB(55, 58, 62)
closePanelBtn.BackgroundTransparency = 0.15
closePanelBtn.BorderSizePixel = 0
closePanelBtn.Text = "X"
closePanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closePanelBtn.TextSize = 14
closePanelBtn.Font = Enum.Font.GothamBold
closePanelBtn.ZIndex = 5
closePanelBtn.Parent = mainFrame
Instance.new("UICorner", closePanelBtn).CornerRadius = UDim.new(0, 6)

local reopenChatBtn = Instance.new("TextButton")
reopenChatBtn.Name = "ReopenChatBtn"
reopenChatBtn.Size = UDim2.new(0, 76, 0, 32)
reopenChatBtn.Position = UDim2.new(0, 10, 0, 10)
reopenChatBtn.BackgroundColor3 = Color3.fromRGB(35, 120, 210)
reopenChatBtn.BorderSizePixel = 0
reopenChatBtn.Text = "CHAT"
reopenChatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenChatBtn.TextSize = 14
reopenChatBtn.Font = Enum.Font.GothamBold
reopenChatBtn.Visible = false
reopenChatBtn.ZIndex = 100
reopenChatBtn.Parent = screenGui
Instance.new("UICorner", reopenChatBtn).CornerRadius = UDim.new(0, 8)

closePanelBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

reopenChatBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
end)

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    reopenChatBtn.Visible = not mainFrame.Visible
    if not mainFrame.Visible then
        settingsMenu.Visible = false
        safeChatMenu.Visible = false
    end
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local channelBar = Instance.new("Frame")
channelBar.Name = "ChannelBar"
channelBar.Size = UDim2.new(1, -36, 0, 36)
channelBar.BackgroundTransparency = 1
channelBar.ZIndex = 2
channelBar.Parent = mainFrame

local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 1, 0)
tabsContainer.BackgroundTransparency = 1
tabsContainer.ZIndex = 2
tabsContainer.Parent = channelBar

local tabsList = Instance.new("UIListLayout")
tabsList.FillDirection = Enum.FillDirection.Horizontal
tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsList.SortOrder = Enum.SortOrder.LayoutOrder
tabsList.Parent = tabsContainer

local menuBtn = Instance.new("ImageButton")
menuBtn.Name = "MenuBtn"
menuBtn.Size = UDim2.new(0, 24, 0, 24)
menuBtn.Position = UDim2.new(1, -30, 0, 6)
menuBtn.BackgroundTransparency = 1
menuBtn.Image = "rbxassetid://14219516515"
menuBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
menuBtn.ZIndex = 3
menuBtn.Parent = mainFrame

local settingsMenu = Instance.new("Frame")
settingsMenu.Name = "SettingsMenu"
settingsMenu.Size = UDim2.new(0, 190, 0, 150)
settingsMenu.Position = UDim2.new(0, 210, 0, 44)
settingsMenu.BackgroundColor3 = Color3.fromRGB(35, 38, 41)
settingsMenu.BackgroundTransparency = 0.1
settingsMenu.BorderSizePixel = 0
settingsMenu.Visible = false
settingsMenu.Active = true
settingsMenu.Draggable = true
settingsMenu.ZIndex = 50
settingsMenu.Parent = screenGui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 8)
settingsCorner.Parent = settingsMenu

local settingsList = Instance.new("UIListLayout")
settingsList.SortOrder = Enum.SortOrder.LayoutOrder
settingsList.Padding = UDim.new(0, 4)
settingsList.Parent = settingsMenu

local safeChatMenu = Instance.new("Frame")
safeChatMenu.Name = "SafeChatMenu"
safeChatMenu.Size = UDim2.new(0, 240, 0, 200)
safeChatMenu.Position = UDim2.new(0, 16, 0, 15)
safeChatMenu.BackgroundColor3 = Color3.fromRGB(35, 38, 41)
safeChatMenu.BackgroundTransparency = 0.1
safeChatMenu.BorderSizePixel = 0
safeChatMenu.Visible = false
safeChatMenu.Active = true
safeChatMenu.Draggable = false
safeChatMenu.ZIndex = 50
safeChatMenu.Parent = screenGui

local safeChatCorner = Instance.new("UICorner")
safeChatCorner.CornerRadius = UDim.new(0, 8)
safeChatCorner.Parent = safeChatMenu

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not mainFrame.Visible then
        settingsMenu.Visible = false
        safeChatMenu.Visible = false
    end
end)

local safeChatScroll = Instance.new("ScrollingFrame")
safeChatScroll.Size = UDim2.new(1, -8, 1, -8)
safeChatScroll.Position = UDim2.new(0, 4, 0, 4)
safeChatScroll.BackgroundTransparency = 1
safeChatScroll.BorderSizePixel = 0
safeChatScroll.ScrollBarThickness = 4
safeChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
safeChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
safeChatScroll.ZIndex = 51
safeChatScroll.Parent = safeChatMenu

local safeChatList = Instance.new("UIListLayout")
safeChatList.SortOrder = Enum.SortOrder.LayoutOrder
safeChatList.Padding = UDim.new(0, 6)
safeChatList.Parent = safeChatScroll

local safeCategories = {
    {
        Category = "Greetings & Polite",
        Phrases = { "Hello everyone!", "Hi there!", "Good morning!", "Good evening!", "Nice to meet you all!", "Goodbye!", "See you later!" }
    },
    {
        Category = "Teamwork & Strategy",
        Phrases = { "Let's work together.", "Follow me.", "Need help?", "Let's go!", "Wait for me.", "Defend this spot!", "Attack now!", "Watch out!" }
    },
    {
        Category = "Reactions & Praise",
        Phrases = { "Nice game!", "Awesome job!", "Great work!", "Oops, my bad!", "Don't worry!", "Good try!", "Amazing!" }
    },
    {
        Category = "Requests & Status",
        Phrases = { "Can someone help me?", "I am ready.", "Give me a second.", "Let's take a break.", "I have to go soon.", "Let's play again!" }
    }
}

local function handleSendMessageExternal(text)
    if not text or text:gsub("%s+", "") == "" then return end

    if activeTab == "Alkek" or activeTab == "Global" then
        local encryptedPayload = encryptE2E(text, E2E_SECRET_KEY)
        local eventType = (activeTab == "Alkek") and "send_message" or "send_global_message"

        if ws then
            pcall(function()
                ws:Send(HttpService:JSONEncode({
                    type = eventType,
                    data = { payload = encryptedPayload }
                }))
            end)
        end
        appendMessageExternal(activeTab, LocalPlayer.DisplayName, text, nil, false)
        triggerBubbleChatExternal(LocalPlayer, text)

    elseif activeTab == "Here" then
        local rbxGeneral = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if rbxGeneral then
            rbxGeneral:SendAsync(text)
        end
    end
end

for _, cat in ipairs(safeCategories) do
    local catLabel = Instance.new("TextLabel")
    catLabel.Size = UDim2.new(1, 0, 0, 22)
    catLabel.BackgroundTransparency = 1
    catLabel.Text = "== " .. cat.Category .. " =="
    catLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
    catLabel.TextSize = 12
    catLabel.Font = Enum.Font.GothamBold
    catLabel.ZIndex = 51
    catLabel.Parent = safeChatScroll

    for _, phrase in ipairs(cat.Phrases) do
        local phraseBtn = Instance.new("TextButton")
        phraseBtn.Size = UDim2.new(1, 0, 0, 26)
        phraseBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 52)
        phraseBtn.BorderSizePixel = 0
        phraseBtn.Text = phrase
        phraseBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        phraseBtn.TextSize = 12
        phraseBtn.Font = Enum.Font.GothamMedium
        phraseBtn.ZIndex = 51
        phraseBtn.Parent = safeChatScroll

        Instance.new("UICorner", phraseBtn).CornerRadius = UDim.new(0, 4)

        phraseBtn.MouseButton1Click:Connect(function()
            safeChatMenu.Visible = false
            handleSendMessageExternal(phrase)
        end)
    end
end

local function createHexColorRow(tabName)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.ZIndex = 51
    row.Parent = settingsMenu

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (tabName == "Alkek") and "KS Chat" or tabName
    label.TextColor3 = tabColors[tabName] or Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 51
    label.Parent = row

    local hexBox = Instance.new("TextBox")
    hexBox.Size = UDim2.new(0.5, -12, 0, 26)
    hexBox.Position = UDim2.new(0.4, 0, 0.5, -13)
    hexBox.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
    hexBox.BorderSizePixel = 0
    local r = math.floor((tabColors[tabName].R * 255) + 0.5)
    local g = math.floor((tabColors[tabName].G * 255) + 0.5)
    local b = math.floor((tabColors[tabName].B * 255) + 0.5)
    hexBox.Text = string.format("%02X%02X%02X", r, g, b)
    hexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hexBox.PlaceholderText = "HEX"
    hexBox.TextSize = 12
    hexBox.Font = Enum.Font.GothamMedium
    hexBox.ClearTextOnFocus = false
    hexBox.ZIndex = 51
    hexBox.Parent = row

    Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 4)

    hexBox.FocusLost:Connect(function()
        local cleanHex = hexBox.Text:gsub("#", "")
        if #cleanHex == 6 then
            local hr = tonumber(cleanHex:sub(1, 2), 16)
            local hg = tonumber(cleanHex:sub(3, 4), 16)
            local hb = tonumber(cleanHex:sub(5, 6), 16)
            if hr and hg and hb then
                local newColor = Color3.fromRGB(hr, hg, hb)
                tabColors[tabName] = newColor
                label.TextColor3 = newColor
                saveConfig()
            end
        end
    end)
end

createHexColorRow("Alkek")
createHexColorRow("Here")
createHexColorRow("Global")

menuBtn.MouseButton1Click:Connect(function()
    safeChatMenu.Visible = false
    settingsMenu.Visible = not settingsMenu.Visible
end)

local tabs = {
    { Name = "Alkek" },
    { Name = "Here" },
    { Name = "Global" }
}

local tabButtons = {}

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "MessagesScroll"
scrollFrame.Size = UDim2.new(1, -16, 1, -84)
scrollFrame.Position = UDim2.new(0, 8, 0, 38)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ZIndex = 2
scrollFrame.Parent = mainFrame

local msgList = Instance.new("UIListLayout")
msgList.SortOrder = Enum.SortOrder.LayoutOrder
msgList.Padding = UDim.new(0, 4)
msgList.Parent = scrollFrame

local inputContainer = Instance.new("Frame")
inputContainer.Name = "InputContainer"
inputContainer.Size = UDim2.new(1, -16, 0, 34)
inputContainer.Position = UDim2.new(0, 8, 1, -40)
inputContainer.BackgroundColor3 = Color3.fromRGB(15, 17, 19)
inputContainer.BackgroundTransparency = 0.3
inputContainer.BorderSizePixel = 0
inputContainer.ZIndex = 3
inputContainer.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 17)
inputCorner.Parent = inputContainer

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(60, 64, 70)
inputStroke.Thickness = 1
inputStroke.Parent = inputContainer

local safeChatBtn = Instance.new("ImageButton")
safeChatBtn.Name = "SafeChatBtn"
safeChatBtn.Size = UDim2.new(0, 20, 0, 20)
safeChatBtn.Position = UDim2.new(0, 8, 0.5, -10)
safeChatBtn.BackgroundTransparency = 1
safeChatBtn.Image = "rbxassetid://119565479686451"
safeChatBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
safeChatBtn.ZIndex = 4
safeChatBtn.Parent = inputContainer

local sendBtn = Instance.new("ImageButton")
sendBtn.Name = "SendBtn"
sendBtn.Size = UDim2.new(0, 22, 0, 22)
sendBtn.Position = UDim2.new(1, -30, 0.5, -11)
sendBtn.BackgroundTransparency = 1
sendBtn.Image = "rbxassetid://121060399555299"
sendBtn.ImageColor3 = Color3.fromRGB(85, 170, 255)
sendBtn.ZIndex = 4
sendBtn.Parent = inputContainer

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -68, 1, 0)
textBox.Position = UDim2.new(0, 34, 0, 0)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.PlaceholderText = "To chat click here or press / key"
textBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextSize = 14
textBox.Font = Enum.Font.GothamMedium
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.ClearTextOnFocus = false
textBox.ZIndex = 4
textBox.Parent = inputContainer

safeChatBtn.MouseButton1Click:Connect(function()
    settingsMenu.Visible = false
    safeChatMenu.Visible = not safeChatMenu.Visible
end)

for _, tabData in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabData.Name
    tabBtn.Size = UDim2.new(1 / #tabs, 0, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = (tabData.Name == "Alkek") and "KS Chat" or tabData.Name
    tabBtn.TextColor3 = tabColors[tabData.Name]
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.ZIndex = 3
    tabBtn.Parent = tabsContainer

    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.Size = UDim2.new(1, 0, 0, 3)
    highlight.Position = UDim2.new(0, 0, 1, -3)
    highlight.BackgroundColor3 = tabColors[tabData.Name]
    highlight.BorderSizePixel = 0
    highlight.Visible = (tabData.Name == activeTab)
    highlight.ZIndex = 4
    highlight.Parent = tabBtn

    tabButtons[tabData.Name] = { Button = tabBtn, Highlight = highlight }

    tabBtn.MouseButton1Click:Connect(function()
        activeTab = tabData.Name
        for name, data in pairs(tabButtons) do
            data.Highlight.Visible = (name == activeTab)
            data.Button.TextColor3 = tabColors[name]
            data.Highlight.BackgroundColor3 = tabColors[name]
        end
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = (child:GetAttribute("Tab") == activeTab)
            end
        end
    end)
end

task.spawn(function()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)

    TextChatService.ChatWindowConfiguration:GetPropertyChangedSignal("Enabled"):Connect(function()
        if TextChatService.ChatWindowConfiguration.Enabled then
            TextChatService.ChatWindowConfiguration.Enabled = false
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

local robloxGui = CoreGui:WaitForChild("RobloxGui", 5)
    if robloxGui then
        local function bindChatIcon(obj)
            if not obj then return false end
            if obj:IsA("GuiButton") then
                local name = obj.Name:lower()
                if name:match("chat") or name == "textchaticon" then
                    obj.MouseButton1Click:Connect(function()
                        mainFrame.Visible = not mainFrame.Visible
                    end)
                    return true
                end
            end
            
            local btn = obj:FindFirstChildOfClass("GuiButton")
            if btn and (btn.Name:lower():match("chat") or btn.Name == "TextChatIcon") then
                btn.MouseButton1Click:Connect(function()
                    mainFrame.Visible = not mainFrame.Visible
                end)
                return true
            end
            return false
        end

        local possibleTargets = {"ChatIcon", "ToggleChatButton", "Chat", "TextChatIcon", "AppUI", "UnibarLeft"}
        for _, targetName in ipairs(possibleTargets) do
            local target = robloxGui:FindFirstChild(targetName, true)
            if bindChatIcon(target) then break end
        end

        robloxGui.DescendantAdded:Connect(function(descendant)
            local name = descendant.Name:lower()
            if name:match("chat") or name == "textchaticon" then
                bindChatIcon(descendant)
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Slash and not UserInputService:GetFocusedTextBox() then
        if not mainFrame.Visible then
            mainFrame.Visible = true
        end
        task.defer(function()
            textBox:CaptureFocus()
            textBox.Text = ""
        end)
    end
end)

textBox:GetPropertyChangedSignal("Text"):Connect(function()
    if textBox.Text == "/" then
        textBox.Text = ""
    end
end)

function triggerBubbleChatExternal(player, text)
    if player and player.Character and player.Character:FindFirstChild("Head") then
        pcall(function()
            Chat:Chat(player.Character.Head, text, Enum.ChatColor.White)
        end)
    end
end

function appendMessageExternal(tabOwner, senderName, text, colorHex, isSystemMessage)
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, 0, 0, 0)
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.BackgroundTransparency = 1
    msgFrame:SetAttribute("Tab", tabOwner)
    msgFrame.Visible = (tabOwner == activeTab)
    msgFrame.Parent = scrollFrame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 1, 0)
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.BackgroundTransparency = 1
    msgLabel.RichText = true
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextSize = 14
    msgLabel.ZIndex = 3

    local formattedText = isSystemMessage and text or sanitizeText(text)
    local safeSender = sanitizeText(senderName)

    if senderName == "" or not senderName or isSystemMessage then
        msgLabel.Text = string.format("<font color='#AAAAAA'>%s</font>", formattedText)
    elseif tabOwner == "Alkek" then
        msgLabel.Text = string.format("<font color='#FF4444'><b>[KS Chat] %s</b>: %s</font>", safeSender, formattedText)
    elseif tabOwner == "Global" then
        msgLabel.Text = string.format("<font color='#FFBB00'><b>[Global] %s</b>: %s</font>", safeSender, formattedText)
    else
        colorHex = colorHex or "#55AAFF"
        msgLabel.Text = string.format("<font color='%s'><b>%s</b></font>: <font color='#FFFFFF'>%s</font>", colorHex, safeSender, formattedText)
    end

    msgLabel.Parent = msgFrame

    task.defer(function()
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
    end)
end

local function DisplaySystemMessage(text)
    appendMessageExternal("Here", "", text, nil, true)
end

getgenv().DisplaySystemMessage = DisplaySystemMessage
_G.DisplaySystemMessage = DisplaySystemMessage

appendMessageExternal("Alkek", "", "[SYSTEM] Your messages are end-to-end encrypted and not logging.", nil, true)
appendMessageExternal("Global", "", "[SYSTEM] Your messages are end-to-end encrypted and not logging.", nil, true)

sendBtn.MouseButton1Click:Connect(function()
    local text = textBox.Text
    textBox.Text = ""
    handleSendMessageExternal(text)
end)

TextChatService.OnIncomingMessage = function(message)
    local properties = Instance.new("TextChatMessageProperties")
    
    if message.TextSource == nil then
        if message.Text and message.Text ~= "" then
            DisplaySystemMessage(message.Text)
        end
    end
    
    return properties
end

TextChatService.MessageReceived:Connect(function(message)
    if message.TextSource then
        local senderPlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
        local senderName = senderPlayer and senderPlayer.DisplayName or tostring(message.TextSource.UserId)
        local channelName = message.TextChannel and message.TextChannel.Name or ""

        if channelName == "RBXGeneral" or channelName == "RBXSystem" or channelName == "RBXWhisper" then
            appendMessageExternal("Here", senderName, message.Text, "#55AAFF", false)
        end
    end
end)

textBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = textBox.Text
    textBox.Text = ""
    handleSendMessageExternal(text)
end)

local function initWebSocket()
    local connectFn = getWebSocketConnect()
    if not connectFn then return end

    local success, connection = pcall(connectFn, SERVER_URL)

    if success and connection then
        ws = connection

        ws.OnMessage:Connect(function(msg)
            local ok, data = pcall(HttpService.JSONDecode, HttpService, msg)
            if ok then
                local senderName = tostring(data.sender or "Unknown")
                local encryptedPayload = data.payload

                if senderName ~= LocalPlayer.Name and encryptedPayload then
                    local decryptedText = decryptE2E(encryptedPayload, E2E_SECRET_KEY)
                    if decryptedText then
                        local senderPlayer = Players:FindFirstChild(senderName)

                        if data.type == "receive_message" then
                            appendMessageExternal("Alkek", senderName, decryptedText, nil, false)
                            triggerBubbleChatExternal(senderPlayer, decryptedText)
                        elseif data.type == "receive_global_message" then
                            appendMessageExternal("Global", senderName, decryptedText, "#FFBB00", false)
                            triggerBubbleChatExternal(senderPlayer, decryptedText)
                        end
                    end
                end
            end
        end)

        ws.OnClose:Connect(function()
            ws = nil
            task.wait(5)
            initWebSocket()
        end)

        local roomId = game.JobId ~= "" and game.JobId or "StudioDevRoom"
        ws:Send(HttpService:JSONEncode({
            type = "join_room",
            data = { jobid = roomId, placeId = game.PlaceId, username = LocalPlayer.Name, userId = LocalPlayer.UserId }
        }))
    else
        task.wait(5)
        initWebSocket()
    end
end

initWebSocket()