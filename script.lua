-- MakerCS - Universal Executor Script with AI
-- Auto-detects executor, mobile-friendly, works on any executor

-- Detect executor
local executor = "Unknown"
local isMobile = false
local currentGame = game.Name or "Unknown"
local placeId = game.PlaceId or 0

-- Executor detection
local function detectExecutor()
    if syn then executor = "Synapse X" 
    elseif krnl then executor = "Krnl" 
    elseif scriptware then executor = "ScriptWare" 
    elseif fluxus then executor = "Fluxus" 
    elseif electron then executor = "Electron" 
    elseif delta then executor = "Delta" 
    elseif arceus then executor = "Arceus X" 
    elseif hydrogen then executor = "Hydrogen" 
    elseif vega then executor = "Vega X" 
    elseif valyse then executor = "Valyse" 
    elseif oxygen then executor = "Oxygen U" 
    elseif kiwi then executor = "Kiwi X" 
    elseif comet then executor = "Comet" 
    elseif swift then executor = "Swift" 
    elseif nihon then executor = "Nihon" 
    elseif athena then executor = "Athena" 
    elseif solara then executor = "Solara" 
    end
    
    if game:GetService("UserInputService").TouchEnabled then
        isMobile = true
    end
    
    local success, name = pcall(function()
        return getexecutorname()
    end)
    if success and name and name ~= "" then
        executor = name
    end
end

detectExecutor()

-- Safe notification function
local function notify(msg, duration)
    duration = duration or 3
    pcall(function()
        if syn and syn.notify then
            syn.notify(msg, duration)
        elseif notify then
            notify(msg, duration)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "MakerCS [" .. executor .. "]",
                Text = msg,
                Duration = duration
            })
        end
    end)
    print("[MakerCS] " .. msg)
end

-- Wait for game load
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local espOn = false
local invisible = false
local discoOn = false
local flySpeed = 50
local cons = {}
local esps = {}
local aiChatHistory = {}

-- ============ AI API FUNCTIONS ============

-- Free AI APIs (no API key required)
local AI_APIS = {
    {
        name = "GPT4Free",
        url = "https://api.g4f.icu/gpt",
        format = function(prompt) 
            return {
                messages = {{role = "user", content = prompt}},
                model = "gpt-3.5-turbo"
            }
        end,
        parse = function(response)
            local decoded = HttpService:JSONDecode(response)
            return decoded.choices and decoded.choices[1].message.content or "API Error"
        end
    },
    {
        name = "Koala AI",
        url = "https://api.koala.sh/v1/chat/completions",
        format = function(prompt)
            return {
                messages = {{role = "user", content = prompt}},
                model = "koala-7b"
            }
        end,
        parse = function(response)
            local decoded = HttpService:JSONDecode(response)
            return decoded.choices and decoded.choices[1].message.content or "API Error"
        end
    },
    {
        name = "ChatBot",
        url = "https://chatbot.theb.ai/api/chat-process",
        format = function(prompt)
            return {
                prompt = prompt,
                options = {}
            }
        end,
        parse = function(response)
            local decoded = HttpService:JSONDecode(response)
            return decoded.text or decoded.message or "API Error"
        end
    }
}

local currentAPI = 1
local function callAIAPI(prompt)
    local api = AI_APIS[currentAPI]
    local success, result = pcall(function()
        local body = api.format(prompt)
        local response = syn and syn.request or request or http_request
        if response then
            local res = response({
                Url = api.url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(body)
            })
            if res and res.Body then
                return api.parse(res.Body)
            end
        end
        return nil
    end)
    
    if success and result then
        return result
    else
        return getLocalResponse(prompt)
    end
end

-- Local AI fallback (works offline)
local function getLocalResponse(prompt)
    prompt = prompt:lower()
    
    local responses = {
        {keywords = {"fly", "how to fly"}, response = "To fly, go to the Main tab and click 'Toggle Fly'. Use WASD keys (or joystick on mobile) to move. Space = up, Ctrl = down."},
        {keywords = {"noclip", "walk through walls"}, response = "Noclip lets you walk through walls. Enable it from the Main tab. Works client-side only."},
        {keywords = {"esp", "see players"}, response = "ESP shows players through walls with names and health bars. Toggle it from the Main tab."},
        {keywords = {"speed", "walkspeed"}, response = "Change your walk speed using 'Toggle Speed' in Main tab, or use Client Scripts tab for presets (100 or 16)."},
        {keywords = {"jump", "jumppower"}, response = "Boost jump power using 'Toggle Jump' in Main tab. Default is 50, boost to 200."},
        {keywords = {"invisible", "hide"}, response = "Invisibility makes your character transparent. Toggle from Main tab. Client-side only."},
        {keywords = {"disco", "rainbow"}, response = "Disco mode creates rainbow lighting. Toggle from Main tab for ambient effects."},
        {keywords = {"executor", "execute script"}, response = "Use Executor tab to run any Lua script. Paste code and click Execute."},
        {keywords = {"scan", "scanner"}, response = "Scan Game button analyzes the game - shows players, remote events, backdoor indicators, admin scripts."},
        {keywords = {"ss", "serverside"}, response = "SS Scripts attempt server-side effects. Only work in backdoored games. Try them from SS Scripts tab."},
        {keywords = {"infinite yield", "iy"}, response = "Load Infinite Yield admin script from Client Scripts tab."},
        {keywords = {"skybox", "sky"}, response = "Change skybox using 'Custom Skybox' in Client Scripts tab. Uses decal ID 133260261393194."},
        {keywords = {"hello", "hi", "hey"}, response = "Hello! I'm your AI assistant. Ask about: fly, noclip, esp, speed, jump, invisible, disco, executor, scan, ss scripts, credits, or type 'help'."},
        {keywords = {"help", "commands"}, response = "📢 Available: Fly, Noclip, ESP, Speed, Jump, Invisible, Disco, Executor, Scan, SS Scripts, Infinite Yield, Skybox, Credits, Game Info"},
        {keywords = {"who are you", "what are you"}, response = "I'm the MakerCS AI assistant! I help you understand all features of this script."},
        {keywords = {"creator", "made by", "credits"}, response = "MakerCS was created by ThatOneScripter1234. Check the Credits tab for full details!"},
        {keywords = {"game name", "current game"}, response = "Current game: " .. game.Name .. " (Place ID: " .. placeId .. ")"},
        {keywords = {"players", "how many"}, response = "Players online: " .. #Players:GetPlayers()},
    }
    
    for _, item in pairs(responses) do
        for _, keyword in pairs(item.keywords) do
            if prompt:find(keyword) then
                return item.response
            end
        end
    end
    
    return "I'm not sure about that. Try asking about: fly, noclip, esp, speed, jump, invisible, disco, executor, scan, ss scripts, infinite yield, skybox, credits, help, or game info!"
end

-- ============ AI CHAT GUI ============
local aiFrame = nil
local chatLog = nil
local aiInput = nil

local function createAIChat()
    local aiGui = Instance.new("ScreenGui")
    aiGui.Name = "AIChat"
    aiGui.Parent = plr.PlayerGui
    
    aiFrame = Instance.new("Frame")
    if isMobile then
        aiFrame.Size = UDim2.new(0, 350, 0, 480)
        aiFrame.Position = UDim2.new(0.02, 0, 0.05, 0)
    else
        aiFrame.Size = UDim2.new(0, 380, 0, 500)
        aiFrame.Position = UDim2.new(0.02, 0, 0.08, 0)
    end
    aiFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
    aiFrame.BackgroundTransparency = 0.05
    aiFrame.Active = true
    aiFrame.Draggable = true
    aiFrame.Visible = false
    aiFrame.Parent = aiGui
    Instance.new("UICorner", aiFrame).CornerRadius = UDim.new(0, 12)
    
    local aiTitle = Instance.new("TextLabel")
    aiTitle.Size = UDim2.new(1,0,0,45)
    aiTitle.BackgroundColor3 = Color3.fromRGB(100,50,150)
    aiTitle.Text = "🤖 AI Assistant (API Powered)"
    aiTitle.TextColor3 = Color3.new(1,1,1)
    aiTitle.TextScaled = true
    aiTitle.Font = Enum.Font.GothamBold
    aiTitle.Parent = aiFrame
    Instance.new("UICorner", aiTitle).CornerRadius = UDim.new(0, 12)
    
    local apiStatus = Instance.new("TextLabel")
    apiStatus.Size = UDim2.new(0.5,0,0,15)
    apiStatus.Position = UDim2.new(0.5,0,1,-18)
    apiStatus.BackgroundTransparency = 1
    apiStatus.Text = "🌐 Using API"
    apiStatus.TextColor3 = Color3.fromRGB(100,255,100)
    apiStatus.TextScaled = true
    apiStatus.Font = Enum.Font.Gotham
    apiStatus.Parent = aiTitle
    
    local aiClose = Instance.new("TextButton")
    aiClose.Size = UDim2.new(0,35,0,35)
    aiClose.Position = UDim2.new(1,-40,0,5)
    aiClose.BackgroundColor3 = Color3.fromRGB(200,50,50)
    aiClose.Text = "✕"
    aiClose.TextColor3 = Color3.new(1,1,1)
    aiClose.TextScaled = true
    aiClose.Font = Enum.Font.GothamBold
    aiClose.Parent = aiTitle
    Instance.new("UICorner", aiClose).CornerRadius = UDim.new(0, 8)
    
    chatLog = Instance.new("ScrollingFrame")
    chatLog.Size = UDim2.new(1,0,1,-105)
    chatLog.Position = UDim2.new(0,0,0,50)
    chatLog.BackgroundColor3 = Color3.fromRGB(20,20,35)
    chatLog.CanvasSize = UDim2.new(0,0,0,0)
    chatLog.ScrollBarThickness = 6
    chatLog.Parent = aiFrame
    Instance.new("UICorner", chatLog).CornerRadius = UDim.new(0, 8)
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Parent = chatLog
    chatLayout.Padding = UDim.new(0, 8)
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1,0,0,55)
    inputFrame.Position = UDim2.new(0,0,1,-55)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30,30,45)
    inputFrame.Parent = aiFrame
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 0)
    
    aiInput = Instance.new("TextBox")
    aiInput.Size = UDim2.new(0.72, -10, 1, -10)
    aiInput.Position = UDim2.new(0.02, 0, 0.05, 0)
    aiInput.BackgroundColor3 = Color3.fromRGB(25,25,40)
    aiInput.PlaceholderText = "Ask me anything..."
    aiInput.Text = ""
    aiInput.TextColor3 = Color3.new(1,1,1)
    aiInput.TextScaled = true
    aiInput.Font = Enum.Font.Gotham
    aiInput.Parent = inputFrame
    Instance.new("UICorner", aiInput).CornerRadius = UDim.new(0, 8)
    
    local aiSend = Instance.new("TextButton")
    aiSend.Size = UDim2.new(0.23, 0, 1, -10)
    aiSend.Position = UDim2.new(0.75, 0, 0.05, 0)
    aiSend.BackgroundColor3 = Color3.fromRGB(0,150,0)
    aiSend.Text = "SEND"
    aiSend.TextColor3 = Color3.new(1,1,1)
    aiSend.TextScaled = true
    aiSend.Font = Enum.Font.GothamBold
    aiSend.Parent = inputFrame
    Instance.new("UICorner", aiSend).CornerRadius = UDim.new(0, 8)
    
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0.3,0,0,40)
    loadingFrame.Position = UDim2.new(0.35,0,0.4,0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    loadingFrame.BackgroundTransparency = 0.5
    loadingFrame.Visible = false
    loadingFrame.Parent = aiFrame
    Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 8)
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1,0,1,0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "🤔 Thinking..."
    loadingText.TextColor3 = Color3.new(1,1,1)
    loadingText.TextScaled = true
    loadingText.Font = Enum.Font.GothamBold
    loadingText.Parent = loadingFrame
    
    local function addChatMessage(sender, message, isUser)
        local msgFrame = Instance.new("Frame")
        if isUser then
            msgFrame.Size = UDim2.new(0.88, 0, 0, 0)
            msgFrame.Position = UDim2.new(0.1, 0, 0, 0)
        else
            msgFrame.Size = UDim2.new(0.88, 0, 0, 0)
            msgFrame.Position = UDim2.new(0.02, 0, 0, 0)
        end
        msgFrame.BackgroundColor3 = isUser and Color3.fromRGB(50,50,80) or Color3.fromRGB(80,50,100)
        msgFrame.BackgroundTransparency = 0.15
        msgFrame.Parent = chatLog
        Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 10)
        
        local senderLabel = Instance.new("TextLabel")
        senderLabel.Size = UDim2.new(1,0,0,22)
        senderLabel.BackgroundTransparency = 1
        senderLabel.Text = isUser and "👤 You:" : "🤖 AI:"
        senderLabel.TextColor3 = isUser and Color3.fromRGB(100,200,255) or Color3.fromRGB(255,150,100)
        senderLabel.TextScaled = true
        senderLabel.TextXAlignment = Enum.TextXAlignment.Left
        senderLabel.Font = Enum.Font.GothamBold
        senderLabel.Parent = msgFrame
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1,0,0,0)
        msgLabel.Position = UDim2.new(0,5,0,22)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = message
        msgLabel.TextColor3 = Color3.new(1,1,1)
        msgLabel.TextScaled = true
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.Parent = msgFrame
        
        local lines = math.max(1, math.ceil(#message / 45))
        local height = 45 + (lines * 18)
        msgFrame.Size = UDim2.new(0.88, 0, 0, height)
        msgLabel.Size = UDim2.new(1, -10, 0, height - 25)
        
        task.wait(0.1)
        chatLog.CanvasPosition = Vector2.new(0, chatLog.CanvasSize.Y.Offset)
    end
    
    local function updateCanvasSize()
        task.wait(0.1)
        local totalHeight = 10
        for _, child in pairs(chatLog:GetChildren()) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.Size.Y.Offset + 8
            end
        end
        chatLog.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
        chatLog.CanvasPosition = Vector2.new(0, chatLog.CanvasSize.Y.Offset)
    end
    
    local function sendToAI()
        local question = aiInput.Text
        if question == "" then return end
        
        addChatMessage("You", question, true)
        updateCanvasSize()
        aiInput.Text = ""
        
        loadingFrame.Visible = true
        
        local response = nil
        local usedAPI = false
        
        for i = 1, 3 do
            local api = AI_APIS[i]
            local success, result = pcall(function()
                local httpFunc = syn and syn.request or request or http_request
                if httpFunc then
                    local res = httpFunc({
                        Url = api.url,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = HttpService:JSONEncode(api.format(question))
                    })
                    if res and res.Body then
                        local decoded = HttpService:JSONDecode(res.Body)
                        if api.name == "GPT4Free" then
                            return decoded.choices and decoded.choices[1].message.content
                        elseif api.name == "Koala AI" then
                            return decoded.choices and decoded.choices[1].message.content
                        else
                            return decoded.text or decoded.message
                        end
                    end
                end
                return nil
            end)
            
            if success and result and result ~= "API Error" and result ~= nil then
                response = result
                usedAPI = true
                apiStatus.Text = "🌐 Using " .. api.name
                apiStatus.TextColor3 = Color3.fromRGB(100,255,100)
                break
            end
        end
        
        if not response then
            response = getLocalResponse(question)
            usedAPI = false
            apiStatus.Text = "💾 Using Local AI"
            apiStatus.TextColor3 = Color3.fromRGB(255,200,100)
        end
        
        loadingFrame.Visible = false
        addChatMessage("AI", response, false)
        updateCanvasSize()
    end
    
    aiSend.MouseButton1Click:Connect(sendToAI)
    aiInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendToAI() end
    end)
    
    aiClose.MouseButton1Click:Connect(function()
        aiFrame.Visible = false
    end)
    
    task.wait(0.5)
    addChatMessage("AI", "Hello! I'm your AI assistant powered by GPT API! I can help you with MakerCS features. Ask me anything about fly, noclip, esp, speed, jump, invisible, disco, executor, scan, ss scripts, credits, or type 'help'!", false)
    updateCanvasSize()
    
    return aiFrame
end

-- ============ CHARACTER HANDLER ============
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if noclipping then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
end)

-- ============ CREATE MAIN GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
if isMobile then
    mainFrame.Size = UDim2.new(0, 350, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -260)
else
    mainFrame.Size = UDim2.new(0, 320, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
end
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,50)
titleBar.BackgroundColor3 = Color3.fromRGB(0,120,200)
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "MakerCS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local execLabel = Instance.new("TextLabel")
execLabel.Size = UDim2.new(0,100,0,18)
execLabel.Position = UDim2.new(1,-110,0,5)
execLabel.BackgroundTransparency = 1
execLabel.Text = executor
execLabel.TextColor3 = Color3.fromRGB(100,255,100)
execLabel.TextScaled = true
execLabel.Font = Enum.Font.Gotham
execLabel.Parent = titleBar

local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.new(1,0,0,18)
gameLabel.Position = UDim2.new(0,10,0,30)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = game.Name .. " (ID: " .. placeId .. ")"
gameLabel.TextColor3 = Color3.fromRGB(200,200,200)
gameLabel.TextScaled = true
gameLabel.TextXAlignment = Enum.TextXAlignment.Left
gameLabel.Font = Enum.Font.Gotham
gameLabel.Parent = titleBar

-- AI Button
local aiButton = Instance.new("TextButton")
aiButton.Size = UDim2.new(0,45,0,40)
aiButton.Position = UDim2.new(1,-95,0,5)
aiButton.BackgroundColor3 = Color3.fromRGB(100,50,150)
aiButton.Text = "🤖"
aiButton.TextColor3 = Color3.new(1,1,1)
aiButton.TextScaled = true
aiButton.Font = Enum.Font.GothamBold
aiButton.Parent = titleBar
Instance.new("UICorner", aiButton).CornerRadius = UDim.new(0, 20)

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,35,0,35)
minBtn.Position = UDim2.new(1,-40,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,50)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 0)

-- Tabs (5 tabs including Credits)
local tabs = {
    {name = "Main", color = Color3.fromRGB(0,120,200)},
    {name = "Client Scripts", color = Color3.fromRGB(45,45,65)},
    {name = "SS Scripts", color = Color3.fromRGB(65,45,45)},
    {name = "Executor", color = Color3.fromRGB(45,55,65)},
    {name = "Credits", color = Color3.fromRGB(150,100,50)}
}

local tabButtons = {}
local contentFrames = {}

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    btn.BackgroundColor3 = tab.color
    btn.Text = tab.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 0)
    tabButtons[tab.name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,-95)
    content.Position = UDim2.new(0,0,0,95)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = isMobile and 8 or 6
    content.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    contentFrames[tab.name] = content
end

-- Create button function
local function createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    if isMobile then
        btn.Size = UDim2.new(0.94, 0, 0, 55)
        btn.Position = UDim2.new(0.03, 0, 0, 0)
    else
        btn.Size = UDim2.new(0.94, 0, 0, 45)
        btn.Position = UDim2.new(0.03, 0, 0, 0)
    end
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    if isMobile then
        btn.TouchTap:Connect(function()
            pcall(callback)
        end)
    end
    return btn
end

-- ============ SCAN GAME FUNCTION ============
local function scanGame()
    notify("🔍 Scanning game...")
    
    local scanGui = Instance.new("ScreenGui")
    scanGui.Name = "ScanResults"
    scanGui.Parent = plr.PlayerGui
    
    local scanMainFrame = Instance.new("Frame")
    scanMainFrame.Size = UDim2.new(0, 400, 0, 450)
    scanMainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    scanMainFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
    scanMainFrame.Parent = scanGui
    Instance.new("UICorner", scanMainFrame).CornerRadius = UDim.new(0, 12)
    
    local scanTitle = Instance.new("TextLabel")
    scanTitle.Size = UDim2.new(1,0,0,40)
    scanTitle.BackgroundColor3 = Color3.fromRGB(0,100,200)
    scanTitle.Text = "🔍 Game Scanner Results"
    scanTitle.TextColor3 = Color3.new(1,1,1)
    scanTitle.TextScaled = true
    scanTitle.Font = Enum.Font.GothamBold
    scanTitle.Parent = scanMainFrame
    Instance.new("UICorner", scanTitle).CornerRadius = UDim.new(0, 12)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-35,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = scanTitle
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    local scanContent = Instance.new("ScrollingFrame")
    scanContent.Size = UDim2.new(1,0,1,-45)
    scanContent.Position = UDim2.new(0,0,0,45)
    scanContent.BackgroundTransparency = 1
    scanContent.CanvasSize = UDim2.new(0,0,0,0)
    scanContent.ScrollBarThickness = 6
    scanContent.Parent = scanMainFrame
    
    local scanLayout = Instance.new("UIListLayout")
    scanLayout.Parent = scanContent
    scanLayout.Padding = UDim.new(0, 5)
    
    local function addResult(category, name, value)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.96, 0, 0, 35)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,45)
        frame.Parent = scanContent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local cat = Instance.new("TextLabel")
        cat.Size = UDim2.new(0.3,0,1,0)
        cat.Position = UDim2.new(0.02,0,0,0)
        cat.BackgroundTransparency = 1
        cat.Text = category
        cat.TextColor3 = Color3.fromRGB(100,200,255)
        cat.TextScaled = true
        cat.Font = Enum.Font.GothamBold
        cat.Parent = frame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4,0,1,0)
        nameLabel.Position = UDim2.new(0.33,0,0,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255,255,150)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = frame
        
        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.23,0,1,0)
        val.Position = UDim2.new(0.74,0,0,0)
        val.BackgroundTransparency = 1
        val.Text = tostring(value)
        val.TextColor3 = Color3.fromRGB(100,255,100)
        val.TextScaled = true
        val.Font = Enum.Font.Gotham
        val.Parent = frame
    end
    
    addResult("📦 Workspace", "Objects", #Workspace:GetChildren())
    addResult("👥 Players", "Online", #Players:GetPlayers())
    addResult("📡 ReplicatedStorage", "Total Items", #ReplicatedStorage:GetChildren())
    addResult("💡 Lighting", "Brightness", math.floor(Lighting.Brightness))
    addResult("💡 Lighting", "ClockTime", math.floor(Lighting.ClockTime))
    
    local remoteEvents = 0
    local remoteFunctions = 0
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then remoteEvents = remoteEvents + 1 end
        if child:IsA("RemoteFunction") then remoteFunctions = remoteFunctions + 1 end
    end
    addResult("📡 Remotes", "RemoteEvents", remoteEvents)
    addResult("📡 Remotes", "RemoteFunctions", remoteFunctions)
    
    task.wait(0.1)
    local totalHeight = 0
    for _, child in pairs(scanContent:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + 40
        end
    end
    scanContent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
    
    closeBtn.MouseButton1Click:Connect(function()
        scanGui:Destroy()
    end)
    
    notify("✅ Scan complete!")
end

-- ============ FLY ============
local function toggleFly()
    if not root then
        notify("Wait for character to load!")
        return
    end
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bv.Parent = root
        bg.Parent = root
        
        local con = RS.RenderStepped:Connect(function()
            if not flying or not root then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            
            if isMobile then
                local moveVec = hum.MoveDirection
                if moveVec.Magnitude > 0.1 then
                    dir = (cam.CFrame.RightVector * moveVec.X) + (cam.CFrame.LookVector * -moveVec.Z)
                    dir = dir.Unit
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonA) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
                    dir = dir + Vector3.new(0, -1, 0)
                end
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            end
            
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
            bg.CFrame = cam.CFrame
        end)
        table.insert(cons, con)
        notify("✈️ Fly ON")
    else
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
        notify("✈️ Fly OFF")
    end
end

-- ============ NOCLIP ============
local function toggleNoclip()
    noclipping = not noclipping
    notify(noclipping and "🚪 Noclip ON" or "🚪 Noclip OFF")
end

local noclipCon = RS.Stepped:Connect(function()
    if noclipping and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)
table.insert(cons, noclipCon)

-- ============ ESP ============
local function updateESP()
    if not espOn then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local exists = false
            for _, bg in pairs(esps) do
                if bg.Adornee == p.Character.Head then
                    exists = true
                    break
                end
            end
            if not exists then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(4, 0, 2, 0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name .. "\n❤️ " .. math.floor(p.Character.Humanoid.Health)
                tl.TextColor3 = Color3.new(1, 0.2, 0.2)
                tl.TextScaled = true
                tl.Font = Enum.Font.GothamBold
                tl.Parent = bg
                table.insert(esps, bg)
            end
        end
    end
end

local function toggleESP()
    espOn = not espOn
    if espOn then
        updateESP()
        
        Players.PlayerAdded:Connect(function() task.wait(1) updateESP() end)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function() task.wait(1) updateESP() end)
            end
        end
        
        local healthLoop = RS.Heartbeat:Connect(function()
            if espOn then
                for _, bg in pairs(esps) do
                    if bg and bg.Adornee and bg.Adornee.Parent then
                        local char = bg.Adornee.Parent
                        if char and char:FindFirstChild("Humanoid") then
                            local tl = bg:FindFirstChild("TextLabel")
                            if tl then
                                tl.Text = char.Name .. "\n❤️ " .. math.floor(char.Humanoid.Health)
                            end
                        end
                    end
                end
            end
        end)
        table.insert(cons, healthLoop)
        
        notify("👁️ ESP ON")
    else
        for _, v in pairs(esps) do
            pcall(function() v:Destroy() end)
        end
        esps = {}
        notify("👁️ ESP OFF")
    end
end

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then
        notify("Wait for character!")
        return
    end
    invisible = not invisible
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
        notify("👻 Invisible ON")
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 0 end)
            end
        end
        notify("👻 Invisible OFF")
    end
end

-- ============ DISCO ============
local discoCon = nil
local function toggleDisco()
    discoOn = not discoOn
    if discoOn then
        discoCon = RS.Heartbeat:Connect(function()
            if discoOn then
                Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                Lighting.ColorShift_Top = Color3.fromHSV((tick() + 1) % 5 / 5, 1, 0.5)
                Lighting.ColorShift_Bottom = Color3.fromHSV((tick() + 2) % 5 / 5, 1, 0.5)
            end
        end)
        notify("🕺 Disco ON")
    else
        if discoCon then discoCon:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        notify("🕺 Disco OFF")
    end
end

-- ============ SPEED ============
local speedActive = false
local originalSpeed = 16

local function toggleSpeed()
    if not hum then
        notify("Wait for character!")
        return
    end
    speedActive = not speedActive
    if speedActive then
        originalSpeed = hum.WalkSpeed
        hum.WalkSpeed = 100
        notify("⚡ Speed 100 ON")
    else
        hum.WalkSpeed = originalSpeed
        notify("⚡ Speed OFF")
    end
end

-- ============ JUMP ============
local jumpActive = false
local originalJump = 50

local function toggleJump()
    if not hum then
        notify("Wait for character!")
        return
    end
    jumpActive = not jumpActive
    if jumpActive then
        originalJump = hum.JumpPower
        hum.JumpPower = 200
        notify("🦘 Jump 200 ON")
    else
        hum.JumpPower = originalJump
        notify("🦘 Jump OFF")
    end
end

-- ============ CLIENT SCRIPTS ============
local clientScripts = {
    {"🏃 Speed 100", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100"},
    {"🐢 Speed 16", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16"},
    {"🦘 Jump 200", "game.Players.LocalPlayer.Character.Humanoid.JumpPower = 200"},
    {"📏 Normal Jump", "game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50"},
    {"💥 Explode Self", "local p = game.Players.LocalPlayer.Character.HumanoidRootPart; local e = Instance.new('Explosion'); e.Position = p.Position; e.Parent = workspace"},
    {"🔫 Kill Others", "for _, v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer and v.Character then v.Character.Humanoid.Health = 0 end end"},
    {"🌞 Day Time", "game.Lighting.ClockTime = 14"},
    {"🌙 Night Time", "game.Lighting.ClockTime = 0"},
    {"🎨 Rainbow Character", "local c = game.Players.LocalPlayer.Character; for _, part in pairs(c:GetDescendants()) do if part:IsA('BasePart') then game:GetService('RunService').RenderStepped:Connect(function() part.Color = Color3.fromHSV(tick()%5/5,1,1) end) end end"},
    {"💪 Super Strength", "game.Players.LocalPlayer.Character.Humanoid.MaxHealth = 1000; game.Players.LocalPlayer.Character.Humanoid.Health = 1000"},
    {"📦 Infinite Yield", "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"},
    {"🌌 Custom Skybox", "local s = Instance.new('Sky'); s.Parent = game.Lighting; s.SkyboxBk = 'rbxassetid://133260261393194'; s.SkyboxDn = 'rbxassetid://133260261393194'; s.SkyboxFt = 'rbxassetid://133260261393194'; s.SkyboxLf = 'rbxassetid://133260261393194'; s.SkyboxRt = 'rbxassetid://133260261393194'; s.SkyboxUp = 'rbxassetid://133260261393194'"}
}

-- ============ SS SCRIPTS ============
local ssScripts = {
    {"🌊 Attempt Flood", [[
        for x = -200, 200, 50 do
            for z = -200, 200, 50 do
                local water = Instance.new("Part")
                water.Size = Vector3.new(50, 1, 50)
                water.Position = Vector3.new(x, -10, z)
                water.Material = Enum.Material.Water
                water.Color = Color3.fromRGB(0,100,255)
                water.Transparency = 0.5
                water.Anchored = true
                water.CanCollide = false
                water.Parent = workspace
            end
        end
    ]]},
    {"🔥 Attempt Lava Map", [[
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255,50,0)
            end
        end
    ]]},
    {"❄️ Attempt Freeze Map", [[
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Ice
                part.Color = Color3.fromRGB(100,200,255)
            end
        end
    ]]},
    {"💀 Attempt Kill All", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.Humanoid.Health = 0
            end
        end
    ]]},
    {"🚀 Attempt Launch All", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
            end
        end
    ]]},
    {"🛑 Attempt Freeze Players", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.Humanoid.WalkSpeed = 0
                v.Character.Humanoid.JumpPower = 0
            end
        end
    ]]},
    {"💨 Attempt Unfreeze", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character then
                v.Character.Humanoid.WalkSpeed = 16
                v.Character.Humanoid.JumpPower = 50
            end
        end
    ]]},
    {"🌑 Attempt Blackout", [[
        game.Lighting.Brightness = 0
        game.Lighting.ClockTime = 0
    ]]},
    {"☀️ Attempt Restore Lighting", [[
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
    ]]},
}

-- ============ CREATE EXECUTOR ============
local function createExecutor(parent)
    local execFrame = Instance.new("Frame")
    if isMobile then
        execFrame.Size = UDim2.new(0.94, 0, 0, 140)
    else
        execFrame.Size = UDim2.new(0.94, 0, 0, 130)
    end
    execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
    execFrame.BackgroundTransparency = 0.1
    execFrame.Parent = parent
    Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 10)
    
    local execTitle = Instance.new("TextLabel")
    execTitle.Size = UDim2.new(1,0,0,25)
    execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
    execTitle.BackgroundTransparency = 0.2
    execTitle.Text = "📝 SCRIPT EXECUTOR"
    execTitle.TextColor3 = Color3.new(1,1,1)
    execTitle.TextScaled = true
    execTitle.Font = Enum.Font.GothamBold
    execTitle.Parent = execFrame
    Instance.new("UICorner", execTitle).CornerRadius = UDim.new(0, 10)
    
    local scriptBox = Instance.new("TextBox")
    if isMobile then
        scriptBox.Size = UDim2.new(0.96, 0, 0, 60)
        scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
    else
        scriptBox.Size = UDim2.new(0.96, 0, 0, 55)
        scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
    end
    scriptBox.BackgroundColor3 = Color3.fromRGB(20,20,35)
    scriptBox.PlaceholderText = "Paste script here..."
    scriptBox.Text = ""
    scriptBox.TextColor3 = Color3.new(100,255,100)
    scriptBox.TextScaled = true
    scriptBox.Font = Enum.Font.Code
    scriptBox.Parent = execFrame
    Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 8)
    
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.48, 0, 0, 35)
    execBtn.Position = UDim2.new(0.02, 0, 0.72, 0)
    execBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    execBtn.Text = "▶ EXECUTE"
    execBtn.TextColor3 = Color3.new(1,1,1)
    execBtn.TextScaled = true
    execBtn.Font = Enum.Font.GothamBold
    execBtn.Parent = execFrame
    Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 8)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.5, 0, 0.72, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,0)
    clearBtn.Text = "🗑 CLEAR"
    clearBtn.TextColor3 = Color3.new(1,1,1)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = execFrame
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
    
    execBtn.MouseButton1Click:Connect(function()
        local code = scriptBox.Text
        if code and code ~= "" then
            local success, err = pcall(function()
                loadstring(code)()
            end)
            if success then
                notify("✅ Script executed!")
            else
                notify("❌ Error: " .. tostring(err))
            end
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        scriptBox.Text = ""
        notify("Cleared!")
    end)
end

-- ============ CREDITS TAB ============
local creditsContent = contentFrames["Credits"]

-- Title
local creditsTitle = Instance.new("TextLabel")
creditsTitle.Size = UDim2.new(0.94, 0, 0, 40)
creditsTitle.BackgroundColor3 = Color3.fromRGB(150,100,50)
creditsTitle.BackgroundTransparency = 0.2
creditsTitle.Text = "🎉 MAKERCS CREDITS 🎉"
creditsTitle.TextColor3 = Color3.fromRGB(255,215,0)
creditsTitle.TextScaled = true
creditsTitle.Font = Enum.Font.GothamBold
creditsTitle.Parent = creditsContent
Instance.new("UICorner", creditsTitle).CornerRadius = UDim.new(0, 10)

-- Creator
local creatorFrame = Instance.new("Frame")
creatorFrame.Size = UDim2.new(0.94, 0, 0, 70)
creatorFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
creatorFrame.Parent = creditsContent
Instance.new("UICorner", creatorFrame).CornerRadius = UDim.new(0, 10)

local creatorIcon = Instance.new("TextLabel")
creatorIcon.Size = UDim2.new(0, 50, 1, 0)
creatorIcon.BackgroundTransparency = 1
creatorIcon.Text = "👑"
creatorIcon.TextColor3 = Color3.fromRGB(255,215,0)
creatorIcon.TextScaled = true
creatorIcon.Font = Enum.Font.GothamBold
creatorIcon.Parent = creatorFrame

local creatorText = Instance.new("TextLabel")
creatorText.Size = UDim2.new(1, -60, 1, 0)
creatorText.Position = UDim2.new(0, 60, 0, 0)
creatorText.BackgroundTransparency = 1
creatorText.Text = "CREATOR & DEVELOPER\nThatOneScripter1234"
creatorText.TextColor3 = Color3.new(1,1,1)
creatorText.TextScaled = true
creatorText.TextXAlignment = Enum.TextXAlignment.Left
creatorText.Font = Enum.Font.GothamBold
creatorText.Parent = creatorFrame

-- Version
local versionFrame = Instance.new("Frame")
versionFrame.Size = UDim2.new(0.94, 0, 0, 50)
versionFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
versionFrame.Parent = creditsContent
Instance.new("UICorner", versionFrame).CornerRadius = UDim.new(0, 10)

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1,0,1,0)
versionText.BackgroundTransparency = 1
versionText.Text = "📌 VERSION: 3.0.0"
versionText.TextColor3 = Color3.fromRGB(100,200,255)
versionText.TextScaled = true
versionText.Font = Enum.Font.GothamBold
versionText.Parent = versionFrame

-- Features List
local featuresFrame = Instance.new("Frame")
featuresFrame.Size = UDim2.new(0.94, 0, 0, 120)
featuresFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
featuresFrame.Parent = creditsContent
Instance.new("UICorner", featuresFrame).CornerRadius = UDim.new(0, 10)

local featuresTitle = Instance.new("TextLabel")
featuresTitle.Size = UDim2.new(1,0,0,25)
featuresTitle.BackgroundColor3 = Color3.fromRGB(100,50,150)
featuresTitle.Text = "⚡ FEATURES"
featuresTitle.TextColor3 = Color3.new(1,1,1)
featuresTitle.TextScaled = true
featuresTitle.Font = Enum.Font.GothamBold
featuresTitle.Parent = featuresFrame
Instance.new("UICorner", featuresTitle).CornerRadius = UDim.new(0, 8)

local featuresList = Instance.new("TextLabel")
featuresList.Size = UDim2.new(1, -10, 1, -30)
featuresList.Position = UDim2.new(0, 5, 0, 30)
featuresList.BackgroundTransparency = 1
featuresList.Text = "• Fly Hack\n• Noclip\n• ESP (See players)\n• Invisibility\n• Disco Mode\n• Speed Hack (100)\n• Jump Hack (200)\n• Client Script Executor\n• ServerSide Scripts\n• AI Assistant (GPT API)\n• Game Scanner\n• Custom Skybox"
featuresList.TextColor3 = Color3.fromRGB(200,200,200)
featuresList.TextScaled = true
featuresList.TextXAlignment = Enum.TextXAlignment.Left
featuresList.TextYAlignment = Enum.TextYAlignment.Top
featuresList.Font = Enum.Font.Gotham
featuresList.Parent = featuresFrame

-- Special Thanks
local thanksFrame = Instance.new("Frame")
thanksFrame.Size = UDim2.new(0.94, 0, 0, 80)
thanksFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
thanksFrame.Parent = creditsContent
Instance.new("UICorner", thanksFrame).CornerRadius = UDim.new(0, 10)

local thanksTitle = Instance.new("TextLabel")
thanksTitle.Size = UDim2.new(1,0,0,25)
thanksTitle.BackgroundColor3 = Color3.fromRGB(100,50,150)
thanksTitle.Text = "🙏 SPECIAL THANKS"
thanksTitle.TextColor3 = Color3.new(1,1,1)
thanksTitle.TextScaled = true
thanksTitle.Font = Enum.Font.GothamBold
thanksTitle.Parent = thanksFrame
Instance.new("UICorner", thanksTitle).CornerRadius = UDim.new(0, 8)

local thanksList = Instance.new("TextLabel")
thanksList.Size = UDim2.new(1, -10, 1, -30)
thanksList.Position = UDim2.new(0, 5, 0, 30)
thanksList.BackgroundTransparency = 1
thanksList.Text = "• Roblox Community\n• Open Source Contributors\n• Beta Testers"
thanksList.TextColor3 = Color3.fromRGB(200,200,200)
thanksList.TextScaled = true
thanksList.TextXAlignment = Enum.TextXAlignment.Left
thanksList.TextYAlignment = Enum.TextYAlignment.Top
thanksList.Font = Enum.Font.Gotham
thanksList.Parent = thanksFrame

-- Links
local linksFrame = Instance.new("Frame")
linksFrame.Size = UDim2.new(0.94, 0, 0, 60)
linksFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
linksFrame.Parent = creditsContent
Instance.new("UICorner", linksFrame).CornerRadius = UDim.new(0, 10)

local linksTitle = Instance.new("TextLabel")
linksTitle.Size = UDim2.new(1,0,0,25)
linksTitle.BackgroundColor3 = Color3.fromRGB(100,50,150)
linksTitle.Text = "🔗 LINKS"
linksTitle.TextColor3 = Color3.new(1,1,1)
linksTitle.TextScaled = true
linksTitle.Font = Enum.Font.GothamBold
linksTitle.Parent = linksFrame
Instance.new("UICorner", linksTitle).CornerRadius = UDim.new(0, 8)

local linksText = Instance.new("TextLabel")
linksText.Size = UDim2.new(1, -10, 1, -30)
linksText.Position = UDim2.new(0, 5, 0, 30)
linksText.BackgroundTransparency = 1
linksText.Text = "GitHub: github.com/ypw96hmxqy-cmd/MakerCS"
linksText.TextColor3 = Color3.fromRGB(100,200,255)
linksText.TextScaled = true
linksText.TextXAlignment = Enum.TextXAlignment.Left
linksText.TextYAlignment = Enum.TextYAlignment.Top
linksText.Font = Enum.Font.Gotham
linksText.Parent = linksFrame

-- Disclaimer
local disclaimerFrame = Instance.new("Frame")
disclaimerFrame.Size = UDim2.new(0.94, 0, 0, 60)
disclaimerFrame.BackgroundColor3 = Color3.fromRGB(50,30,30)
disclaimerFrame.Parent = creditsContent
Instance.new("UICorner", disclaimerFrame).CornerRadius = UDim.new(0, 10)

local disclaimerText = Instance.new("TextLabel")
disclaimerText.Size = UDim2.new(1, -10, 1, -10)
disclaimerText.Position = UDim2.new(0, 5, 0, 5)
disclaimerText.BackgroundTransparency = 1
disclaimerText.Text = "⚠️ DISCLAIMER: This script is for educational purposes only. Use at your own risk."
disclaimerText.TextColor3 = Color3.fromRGB(255,100,100)
disclaimerText.TextScaled = true
disclaimerText.TextWrapped = true
disclaimerText.Font = Enum.Font.Gotham
disclaimerText.Parent = disclaimerFrame

-- ============ POPULATE TABS ============

-- MAIN TAB
local mainContent = contentFrames["Main"]
createButton(mainContent, "✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton(mainContent, "🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton(mainContent, "👁️ Toggle ESP", toggleESP, Color3.fromRGB(50,50,75))
createButton(mainContent, "👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton(mainContent, "🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton(mainContent, "⚡ Toggle Speed (100)", toggleSpeed, Color3.fromRGB(60,60,85))
createButton(mainContent, "🦘 Toggle Jump (200)", toggleJump, Color3.fromRGB(60,60,85))

-- CLIENT SCRIPTS TAB
local clientContent = contentFrames["Client Scripts"]
createButton(clientContent, "🔍 SCAN GAME", scanGame, Color3.fromRGB(0,100,150))

for _, script in pairs(clientScripts) do
    createButton(clientContent, script[1], function()
        local success, err = pcall(function()
            loadstring(script[2])()
        end)
        if success then
            notify("✅ Executed: " .. script[1])
        else
            notify("❌ Error: " .. tostring(err))
        end
    end, Color3.fromRGB(55,55,80))
end

-- SS SCRIPTS TAB
local ssContent = contentFrames["SS Scripts"]

local ssWarning = Instance.new("TextLabel")
ssWarning.Size = UDim2.new(0.94, 0, 0, 40)
ssWarning.BackgroundColor3 = Color3.fromRGB(100,50,50)
ssWarning.BackgroundTransparency = 0.3
ssWarning.Text = "⚠️ SS Scripts may only work in backdoored games ⚠️"
ssWarning.TextColor3 = Color3.fromRGB(255,200,100)
ssWarning.TextScaled = true
ssWarning.Font = Enum.Font.GothamBold
ssWarning.Parent = ssContent
Instance.new("UICorner", ssWarning).CornerRadius = UDim.new(0, 10)

for _, script in pairs(ssScripts) do
    createButton(ssContent, script[1], function()
        local success, err = pcall(function()
            loadstring(script[2])()
        end)
        if success then
            notify("✅ Attempted: " .. script[1])
        else
            notify("❌ Failed: " .. tostring(err))
        end
    end, Color3.fromRGB(75,45,45))
end

-- EXECUTOR TAB
local execContent = contentFrames["Executor"]
createExecutor(execContent)

-- Tab switching
for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, content in pairs(contentFrames) do
            content.Visible = false
        end
        for _, tabBtn in pairs(tabButtons) do
            tabBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
        end
        contentFrames[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
    end)
end

-- Minimize / Restore
local icon = Instance.new("TextButton")
if isMobile then
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0.02, 0, 0.85, 0)
else
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0.02, 0, 0.87, 0)
end
icon.BackgroundColor3 = Color3.fromRGB(0,150,255)
icon.Text = "⚙️\nCS"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextScaled = true
icon.Visible = false
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 30)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    icon.Visible = false
end)

-- Create AI Chat
local aiChat = createAIChat()

-- AI Button click
aiButton.MouseButton1Click:Connect(function()
    if aiChat then
        aiChat.Visible = not aiChat.Visible
    end
end)

-- Final welcome
notify("✅ MakerCS Loaded with AI!")
notify("Executor: " .. executor)
notify("Game: " .. game.Name)
notify("🤖 Click the AI button for help!")

print("========================================")
print("MakerCS - Complete Script with AI API")
print("Executor: " .. executor)
print("Game: " .. game.Name .. " (ID: " .. placeId .. ")")
print("Mobile: " .. tostring(isMobile))
print("AI Features: Multiple API support + local fallback")
print("Tabs: Main, Client Scripts, SS Scripts, Executor, Credits")
print("GitHub: github.com/ypw96hmxqy-cmd/MakerCS")
print("========================================")