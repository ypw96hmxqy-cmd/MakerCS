-- MakerCS - Complete Edition with MM2 Support
-- Execute this in Delta executor

-- Wait for game
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local espUpdateConnection = nil

-- Check if game is Murder Mystery 2
local isMM2 = game.PlaceId == 142823291 or game.Name:find("Murder Mystery 2") or game.Name:find("Murder Mystery") or false

-- Simple notification
local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {Title = "MakerCS", Text = msg, Duration = 2})
    end)
    print("[MakerCS] " .. msg)
end

-- Get player role in MM2
local function getPlayerRole(player)
    if not isMM2 then return nil, nil end
    
    -- Check if player is the murderer (has knife or special attribute)
    if player.Character then
        if player.Character:FindFirstChild("Knife") or player.Character:FindFirstChild("Murderer") then
            return "🔪 MURDERER", Color3.fromRGB(255, 50, 50)
        end
        
        -- Check for sheriff (has gun)
        if player.Character:FindFirstChild("Gun") or player.Character:FindFirstChild("Sheriff") then
            return "🔫 SHERIFF", Color3.fromRGB(50, 150, 255)
        end
    end
    
    -- Check via leaderstats
    if player:FindFirstChild("leaderstats") then
        local role = player.leaderstats:FindFirstChild("Role")
        if role then
            local roleValue = role.Value
            if roleValue == "Murderer" then
                return "🔪 MURDERER", Color3.fromRGB(255, 50, 50)
            elseif roleValue == "Sheriff" then
                return "🔫 SHERIFF", Color3.fromRGB(50, 150, 255)
            end
        end
    end
    
    -- Check via backpack/tools
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool.Name == "Knife" then
                return "🔪 MURDERER", Color3.fromRGB(255, 50, 50)
            elseif tool.Name == "Gun" then
                return "🔫 SHERIFF", Color3.fromRGB(50, 150, 255)
            end
        end
    end
    
    if player == plr then
        return "👤 YOU", Color3.fromRGB(255, 255, 100)
    end
    
    return "👤 INNOCENT", Color3.fromRGB(100, 255, 100)
end

-- Get player color based on role
local function getPlayerColor(player)
    if not isMM2 then
        return Color3.fromRGB(255, 50, 50)
    end
    
    if player.Character then
        if player.Character:FindFirstChild("Knife") or player.Character:FindFirstChild("Murderer") then
            return Color3.fromRGB(255, 50, 50)
        elseif player.Character:FindFirstChild("Gun") or player.Character:FindFirstChild("Sheriff") then
            return Color3.fromRGB(50, 150, 255)
        end
    end
    
    if player:FindFirstChild("leaderstats") then
        local role = player.leaderstats:FindFirstChild("Role")
        if role then
            if role.Value == "Murderer" then
                return Color3.fromRGB(255, 50, 50)
            elseif role.Value == "Sheriff" then
                return Color3.fromRGB(50, 150, 255)
            end
        end
    end
    
    if player == plr then
        return Color3.fromRGB(255, 255, 100)
    end
    
    return Color3.fromRGB(100, 255, 100)
end

-- Update ESP for all players
local function updateESP()
    if not espOn then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local exists = false
            local existingBG = nil
            
            for i, espData in pairs(esps) do
                if espData.player == p then
                    exists = true
                    existingBG = espData
                    break
                end
            end
            
            if not exists then
                -- Create new ESP
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(5, 0, 2.5, 0)
                bg.AlwaysOnTop = true
                bg.StudsOffset = Vector3.new(0, 2, 0)
                bg.Parent = gui
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = p.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = bg
                
                local roleLabel = Instance.new("TextLabel")
                roleLabel.Size = UDim2.new(1, 0, 0.35, 0)
                roleLabel.Position = UDim2.new(0, 0, 0.4, 0)
                roleLabel.BackgroundTransparency = 1
                roleLabel.TextScaled = true
                roleLabel.Font = Enum.Font.GothamBold
                roleLabel.Parent = bg
                
                local healthLabel = Instance.new("TextLabel")
                healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
                healthLabel.Position = UDim2.new(0, 0, 0.75, 0)
                healthLabel.BackgroundTransparency = 1
                healthLabel.TextScaled = true
                healthLabel.Font = Enum.Font.Gotham
                healthLabel.Parent = bg
                
                table.insert(esps, {bg = bg, nameLabel = nameLabel, roleLabel = roleLabel, healthLabel = healthLabel, player = p})
            end
        end
    end
    
    -- Remove ESP for players who left/disconnected
    for i = #esps, 1, -1 do
        local espData = esps[i]
        if not espData.player or not espData.player.Parent or not espData.player.Character or not espData.player.Character:FindFirstChild("Head") then
            pcall(function() espData.bg:Destroy() end)
            table.remove(esps, i)
        end
    end
end

-- Update ESP labels (colors, roles, health)
local function updateESPLabels()
    if not espOn then return end
    
    for _, espData in pairs(esps) do
        local player = espData.player
        if player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local health = math.floor(humanoid.Health)
            
            -- Get role info
            local roleText, roleColor = getPlayerRole(player)
            local nameColor = getPlayerColor(player)
            
            -- Update labels
            espData.nameLabel.Text = player.Name
            espData.nameLabel.TextColor3 = nameColor
            
            if isMM2 and roleText then
                espData.roleLabel.Text = roleText
                espData.roleLabel.TextColor3 = roleColor
            else
                espData.roleLabel.Text = "❤️ " .. health .. " HP"
                espData.roleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            espData.healthLabel.Text = "📏 " .. math.floor((player.Character.Head.Position - plr.Character.Head.Position).Magnitude) .. "m"
            espData.healthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

-- ESP toggle function
local function toggleESP()
    espOn = not espOn
    
    if espOn then
        -- Initial update
        updateESP()
        updateESPLabels()
        
        -- Watch for new players joining
        local playerAddedConn
        playerAddedConn = Players.PlayerAdded:Connect(function(newPlayer)
            task.wait(0.5)
            updateESP()
            -- Watch for character spawn
            newPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                updateESP()
                updateESPLabels()
            end)
        end)
        table.insert(cons, playerAddedConn)
        
        -- Watch for character added for existing players
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                local charAddedConn = p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    updateESP()
                    updateESPLabels()
                end)
                table.insert(cons, charAddedConn)
            end
        end
        
        -- Continuous update for labels (health, roles, distance)
        espUpdateConnection = RS.Heartbeat:Connect(function()
            if espOn then
                updateESPLabels()
            end
        end)
        table.insert(cons, espUpdateConnection)
        
        -- Also update when character moves (for role changes)
        local roleCheckConnection = RS.Stepped:Connect(function()
            if espOn then
                updateESP()
                updateESPLabels()
            end
        end)
        table.insert(cons, roleCheckConnection)
        
        if isMM2 then
            notify("👁️ MM2 ESP ON - Shows Murderer/Sheriff/Innocent!")
        else
            notify("👁️ ESP ON")
        end
    else
        -- Remove all ESP
        for _, espData in pairs(esps) do
            pcall(function() espData.bg:Destroy() end)
        end
        esps = {}
        notify("👁️ ESP OFF")
    end
end

-- ============ FLY ============
local function toggleFly()
    if not root then notify("Wait for character!"); return end
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
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            if dir.Magnitude > 0 then bv.Velocity = dir.Unit * flySpeed else bv.Velocity = Vector3.new() end
            bg.CFrame = cam.CFrame
        end)
        table.insert(cons, con)
        notify("✈️ Fly ON")
    else
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
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
            if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
        end
    end
end)
table.insert(cons, noclipCon)

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then notify("Wait for character!"); return end
    invisible = not invisible
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then pcall(function() part.Transparency = 1 end) end
        end
        notify("👻 Invisible ON")
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then pcall(function() part.Transparency = 0 end) end
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
    if not hum then notify("Wait for character!"); return end
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
    if not hum then notify("Wait for character!"); return end
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

-- ============ INFINITE YIELD ============
local function loadInfiniteYield()
    notify("Loading Infinite Yield...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
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
    {"🌌 Custom Skybox", "local s = Instance.new('Sky'); s.Parent = game.Lighting; s.SkyboxBk = 'rbxassetid://133260261393194'; s.SkyboxDn = 'rbxassetid://133260261393194'; s.SkyboxFt = 'rbxassetid://133260261393194'; s.SkyboxLf = 'rbxassetid://133260261393194'; s.SkyboxRt = 'rbxassetid://133260261393194'; s.SkyboxUp = 'rbxassetid://133260261393194'"},
    {"🕵️ Find Murderer (MM2)", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and (v.Character:FindFirstChild("Knife") or v.Backpack:FindFirstChild("Knife")) then
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "MM2", Text = "🔪 MURDERER IS: " .. v.Name, Duration = 5})
            end
        end
    ]]},
    {"🔍 Find Sheriff (MM2)", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and (v.Character:FindFirstChild("Gun") or v.Backpack:FindFirstChild("Gun")) then
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "MM2", Text = "🔫 SHERIFF IS: " .. v.Name, Duration = 5})
            end
        end
    ]]},
}

-- ============ CREATE GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 550)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS" .. (isMM2 and " [MM2 MODE]" or "")
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-35,0,5)
minBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local gameInfo = Instance.new("TextLabel")
gameInfo.Size = UDim2.new(1,0,0,20)
gameInfo.Position = UDim2.new(0,0,0,40)
gameInfo.BackgroundColor3 = Color3.fromRGB(30,30,50)
gameInfo.Text = isMM2 and "🎮 Murder Mystery 2 Mode - Role Detection Active" or "🎮 " .. game.Name
gameInfo.TextColor3 = Color3.fromRGB(200,200,200)
gameInfo.TextScaled = true
gameInfo.Font = Enum.Font.Gotham
gameInfo.Parent = mainFrame

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,60)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
tabBar.Parent = mainFrame

local tabs = {
    {name = "Main", color = Color3.fromRGB(0,120,200)},
    {name = "Client Scripts", color = Color3.fromRGB(45,45,65)},
    {name = "Executor", color = Color3.fromRGB(45,55,65)},
    {name = "Credits", color = Color3.fromRGB(150,100,50)}
}

local tabButtons = {}
local contentFrames = {}

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = tab.color
    btn.Text = tab.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 0)
    tabButtons[tab.name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,-100)
    content.Position = UDim2.new(0,0,0,100)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = 6
    content.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    contentFrames[tab.name] = content
end

local function createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.94, 0, 0, 45)
    btn.Position = UDim2.new(0.03, 0, 0, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============ POPULATE MAIN TAB ============
local mainContent = contentFrames["Main"]
createButton(mainContent, "✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton(mainContent, "🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton(mainContent, "👁️ Toggle ESP" .. (isMM2 and " (MM2 Roles)", toggleESP, Color3.fromRGB(50,50,75))
createButton(mainContent, "👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton(mainContent, "🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton(mainContent, "⚡ Toggle Speed (100)", toggleSpeed, Color3.fromRGB(60,60,85))
createButton(mainContent, "🦘 Toggle Jump (200)", toggleJump, Color3.fromRGB(60,60,85))
createButton(mainContent, "📦 Load Infinite Yield", loadInfiniteYield, Color3.fromRGB(80,50,50))

-- ============ POPULATE CLIENT SCRIPTS TAB ============
local clientContent = contentFrames["Client Scripts"]

-- Add MM2 quick scan buttons if in MM2
if isMM2 then
    createButton(clientContent, "🔪 Find Murderer (MM2)", function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= plr and v.Character and (v.Character:FindFirstChild("Knife") or (v.Backpack and v.Backpack:FindFirstChild("Knife"))) then
                notify("🔪 MURDERER IS: " .. v.Name)
            end
        end
    end, Color3.fromRGB(80,40,40))
    
    createButton(clientContent, "🔫 Find Sheriff (MM2)", function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= plr and v.Character and (v.Character:FindFirstChild("Gun") or (v.Backpack and v.Backpack:FindFirstChild("Gun"))) then
                notify("🔫 SHERIFF IS: " .. v.Name)
            end
        end
    end, Color3.fromRGB(40,80,80))
end

-- Add all client scripts
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

-- ============ EXECUTOR TAB ============
local execContent = contentFrames["Executor"]

local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(0.94, 0, 0, 120)
execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
execFrame.Parent = execContent
Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 8)

local execTitle = Instance.new("TextLabel")
execTitle.Size = UDim2.new(1,0,0,25)
execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
execTitle.Text = "📝 SCRIPT EXECUTOR"
execTitle.TextColor3 = Color3.new(1,1,1)
execTitle.TextScaled = true
execTitle.Font = Enum.Font.GothamBold
execTitle.Parent = execFrame
Instance.new("UICorner", execTitle).CornerRadius = UDim.new(0, 8)

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(0.96, 0, 0, 50)
scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
scriptBox.BackgroundColor3 = Color3.fromRGB(20,20,35)
scriptBox.PlaceholderText = "Paste Lua script here..."
scriptBox.Text = ""
scriptBox.TextColor3 = Color3.new(100,255,100)
scriptBox.TextScaled = true
scriptBox.Font = Enum.Font.Code
scriptBox.Parent = execFrame
Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 5)

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0.48, 0, 0, 32)
execBtn.Position = UDim2.new(0.02, 0, 0.7, 0)
execBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
execBtn.Text = "▶ EXECUTE"
execBtn.TextColor3 = Color3.new(1,1,1)
execBtn.TextScaled = true
execBtn.Font = Enum.Font.GothamBold
execBtn.Parent = execFrame
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 5)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, 0, 0, 32)
clearBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,0)
clearBtn.Text = "🗑 CLEAR"
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.TextScaled = true
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = execFrame
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

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

-- ============ CREDITS TAB ============
local creditsContent = contentFrames["Credits"]

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

local versionFrame = Instance.new("Frame")
versionFrame.Size = UDim2.new(0.94, 0, 0, 40)
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

local featuresFrame = Instance.new("Frame")
featuresFrame.Size = UDim2.new(0.94, 0, 0, 130)
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
featuresList.Text = "• Fly Hack\n• Noclip\n• ESP with MM2 Role Detection\n• Invisibility\n• Disco Mode\n• Speed Hack (100)\n• Jump Hack (200)\n• Client Script Executor (13+ scripts)\n• MM2 Murderer/Sheriff Detection\n• Player Distance Tracker\n• Custom Skybox\n• Infinite Yield Loader"
featuresList.TextColor3 = Color3.fromRGB(200,200,200)
featuresList.TextScaled = true
featuresList.TextXAlignment = Enum.TextXAlignment.Left
featuresList.TextYAlignment = Enum.TextYAlignment.Top
featuresList.Font = Enum.Font.Gotham
featuresList.Parent = featuresFrame

local linksFrame = Instance.new("Frame")
linksFrame.Size = UDim2.new(0.94, 0, 0, 50)
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
linksText.Font = Enum.Font.Gotham
linksText.Parent = linksFrame

local disclaimerFrame = Instance.new("Frame")
disclaimerFrame.Size = UDim2.new(0.94, 0, 0, 50)
disclaimerFrame.BackgroundColor3 = Color3.fromRGB(50,30,30)
disclaimerFrame.Parent = creditsContent
Instance.new("UICorner", disclaimerFrame).CornerRadius = UDim.new(0, 10)

local disclaimerText = Instance.new("TextLabel")
disclaimerText.Size = UDim2.new(1, -10, 1, -10)
disclaimerText.Position = UDim2.new(0, 5, 0, 5)
disclaimerText.BackgroundTransparency = 1
disclaimerText.Text = "⚠️ DISCLAIMER: This script is for educational purposes only."
disclaimerText.TextColor3 = Color3.fromRGB(255,100,100)
disclaimerText.TextScaled = true
disclaimerText.TextWrapped = true
disclaimerText.Font = Enum.Font.Gotham
disclaimerText.Parent = disclaimerFrame

-- ============ TAB SWITCHING ============
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

-- ============ MINIMIZE ============
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0.02, 0, 0.85, 0)
icon.BackgroundColor3 = Color3.fromRGB(0,150,255)
icon.Text = "⚙️"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextScaled = true
icon.Visible = false
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 25)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    icon.Visible = false
end)

-- ============ CHARACTER RESPAWN HANDLER ============
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if noclipping then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
        end
    end
    
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
    
    if espOn then
        task.wait(1)
        updateESP()
        updateESPLabels()
    end
end)

-- ============ FINAL MESSAGE ============
notify("✅ MakerCS Loaded!")
notify(isMM2 and "🎮 MM2 Mode Active - ESP shows Murderer/Sheriff!" or "🎮 " .. game.Name)

print("========================================")
print("MakerCS - Complete Edition")
print("Game: " .. game.Name .. " (ID: " .. game.PlaceId .. ")")
print("MM2 Mode: " .. tostring(isMM2))
print("Tabs: Main, Client Scripts, Executor, Credits")
print("Client Scripts: " .. #clientScripts + (isMM2 and 2 or 0) .. " scripts available")
print("GitHub: github.com/ypw96hmxqy-cmd/MakerCS")
print("========================================")